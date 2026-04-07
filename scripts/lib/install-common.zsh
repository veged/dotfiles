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
