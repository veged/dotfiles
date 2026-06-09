die() {
  print -u2 "$1"
  exit 1
}

require_commands() {
  local cmd

  for cmd in "$@"; do
    command -v "$cmd" >/dev/null 2>&1 || die "$SCRIPT_NAME: missing required command: $cmd"
  done
}

make_tmpdir() {
  mktemp -d "${TMPDIR:-/tmp}/$1.XXXXXX"
}

normalize_source() {
  local source=$1

  if [[ $source == *"://"* ]]; then
    print -r -- "$source"
    return
  fi

  if [[ $source == '~' || $source == '~/'* ]]; then
    print -r -- "$HOME${source#\~}"
    return
  fi

  if [[ $source == ./* || $source == ../* ]]; then
    local base_dir=${ACQUISITION_SOURCE_BASE_DIR:-$PWD}
    local source_path="$base_dir/$source"
    print -r -- "${source_path:A}"
    return
  fi

  if [[ $source == /* ]]; then
    print -r -- "$source"
    return
  fi

  print -r -- "https://github.com/$source"
}

replace_dir() {
  local target_dir=$1
  local source_dir=$2

  [[ -d "$source_dir" ]] || die "$SCRIPT_NAME: missing directory: $source_dir"

  rm -rf "$target_dir"
  cp -R "$source_dir" "$target_dir"
}

stage_skills() {
  local stage_dir=$1
  local source=$2
  shift 2

  local command=(npx skills add "$source" -a codex -y)
  local skill
  for skill in "$@"; do
    command+=(--skill "$skill")
  done

  (
    cd "$stage_dir"
    "${command[@]}"
  )
}

git_find_skill_dir() {
  local root=$1 name=$2 dir
  for dir in "$root/$name" "$root/skills/$name"; do
    [[ -f "$dir/SKILL.md" ]] && { print -r -- "$dir"; return 0; }
  done
  return 1
}

stage_skills_git() {
  local stage_dir=$1 source=$2
  shift 2

  local clone_dir="$stage_dir/clone"
  local dest_dir="$stage_dir/.agents/skills"

  rm -rf "$clone_dir"
  git clone --depth 1 "$source" "$clone_dir" >/dev/null 2>&1 \
    || die "$SCRIPT_NAME: git clone failed for skill source: $source"
  rm -rf "$clone_dir/.git"
  mkdir -p "$dest_dir"

  local name skill_dir dir
  if (( $# )); then
    for name in "$@"; do
      skill_dir=$(git_find_skill_dir "$clone_dir" "$name") \
        || die "$SCRIPT_NAME: skill '$name' not found in $source"
      rm -rf "$dest_dir/$name"
      cp -R "$skill_dir" "$dest_dir/$name"
    done
  else
    for dir in "$clone_dir"/*(N/) "$clone_dir"/skills/*(N/); do
      [[ -f "$dir/SKILL.md" ]] || continue
      rm -rf "$dest_dir/${dir:t}"
      cp -R "$dir" "$dest_dir/${dir:t}"
    done
  fi
}

staged_skill_paths() {
  fd -td -d 1 . "$1/.agents/skills"
}

prune_dir_except() {
  local dir=$1
  shift

  typeset -A keep
  local name entry_path

  for name in "$@"; do
    keep[$name]=1
  done

  for entry_path in "$dir"/*(N); do
    [[ -n ${keep[$entry_path:t]-} ]] && continue
    rm -rf "$entry_path"
  done
}
