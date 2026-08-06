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

normalize_source_uri() {
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

source_spec_json() {
  local source=$1
  local uri=$source
  local fragment=""
  local revision=""
  local subpath=""
  local canonical
  local -a path_parts
  local path_part

  if [[ "$source" == *'#'* ]]; then
    [[ "$source" != *'#'*'#'* ]] || die "$SCRIPT_NAME: source must contain at most one #: $source"
    uri=${source%%#*}
    fragment=${source#*#}
    [[ -n "$uri" && -n "$fragment" ]] || die "$SCRIPT_NAME: invalid pinned source: $source"

    revision=${fragment%%:*}
    [[ "$revision" =~ '^[0-9a-fA-F]{40}$' ]] \
      || die "$SCRIPT_NAME: source revision must be a full commit SHA: $source"
    revision=${revision:l}

    if [[ "$fragment" == *:* ]]; then
      subpath=${fragment#*:}
      [[ -n "$subpath" ]] || die "$SCRIPT_NAME: source subdirectory must not be empty: $source"
      [[ "$subpath" != /* ]] || die "$SCRIPT_NAME: source subdirectory must be relative: $source"

      path_parts=("${(@s:/:)subpath}")
      for path_part in "${path_parts[@]}"; do
        [[ -n "$path_part" && "$path_part" != "." && "$path_part" != ".." ]] \
          || die "$SCRIPT_NAME: unsafe source subdirectory: $source"
      done
    fi
  fi

  uri=$(normalize_source_uri "$uri")
  canonical=$uri
  if [[ -n "$revision" ]]; then
    canonical+="#$revision"
    [[ -z "$subpath" ]] || canonical+=":$subpath"
  fi

  jq -cn \
    --arg source "$canonical" \
    --arg uri "$uri" \
    --arg revision "$revision" \
    --arg path "$subpath" \
    '{source: $source, uri: $uri, revision: $revision, path: $path}'
}

normalize_source() {
  source_spec_json "$1" | jq -r '.source'
}

source_spec_uri() {
  source_spec_json "$1" | jq -r '.uri'
}

source_spec_revision() {
  source_spec_json "$1" | jq -r '.revision'
}

source_spec_path() {
  source_spec_json "$1" | jq -r '.path'
}

materialize_source() {
  local destination=$1
  local source=$2
  local spec uri revision subpath clone_dir root actual_revision

  spec=$(source_spec_json "$source")
  uri=$(jq -r '.uri' <<<"$spec")
  revision=$(jq -r '.revision' <<<"$spec")
  subpath=$(jq -r '.path' <<<"$spec")

  rm -rf "$destination"
  mkdir -p "$destination"

  if [[ -d "$uri" ]]; then
    [[ -z "$revision" ]] || die "$SCRIPT_NAME: local directory source must not declare a revision: $source"
    root=$uri
  else
    clone_dir="$destination/source"
    if [[ -n "$revision" ]]; then
      git init -q "$clone_dir" \
        || die "$SCRIPT_NAME: git init failed for source: $source"
      git -C "$clone_dir" remote add origin "$uri" \
        || die "$SCRIPT_NAME: git remote failed for source: $source"
      git -C "$clone_dir" fetch -q --depth 1 origin "$revision" \
        || die "$SCRIPT_NAME: git fetch failed for pinned source: $source"
      git -C "$clone_dir" -c advice.detachedHead=false checkout -q --detach FETCH_HEAD \
        || die "$SCRIPT_NAME: git checkout failed for pinned source: $source"
      actual_revision=$(git -C "$clone_dir" rev-parse HEAD)
      [[ "$actual_revision" == "$revision" ]] \
        || die "$SCRIPT_NAME: pinned source resolved to $actual_revision instead of $revision: $source"
    else
      git clone --depth 1 "$uri" "$clone_dir" >/dev/null 2>&1 \
        || die "$SCRIPT_NAME: git clone failed for source: $source"
    fi
    rm -rf "$clone_dir/.git"
    root=$clone_dir
  fi

  if [[ -n "$subpath" ]]; then
    root="$root/$subpath"
    [[ -d "$root" ]] || die "$SCRIPT_NAME: source subdirectory not found: $source"
  fi

  print -r -- "$root"
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

skill_manifest_name() {
  local skill_file=$1
  local line label name

  line=$(ugrep -m1 '^name:[[:space:]]*[A-Za-z0-9_-]+[[:space:]]*$' "$skill_file" 2>/dev/null || true)
  [[ -n "$line" ]] || return 1
  read -r label name <<<"$line"
  [[ -n "$name" ]] || return 1
  print -r -- "$name"
}

git_find_skill_dir() {
  local root=$1 name=$2 dir root_name skill_file declared_name
  for dir in "$root/$name" "$root/skills/$name" "$root/.claude/skills/$name"; do
    [[ -f "$dir/SKILL.md" ]] && { print -r -- "$dir"; return 0; }
  done
  if [[ -f "$root/SKILL.md" ]]; then
    root_name=$(skill_manifest_name "$root/SKILL.md" 2>/dev/null || true)
    [[ "$root_name" == "$name" ]] && { print -r -- "$root"; return 0; }
  fi
  for skill_file in "${(@f)$(fd -HI -t f -g SKILL.md "$root" --exclude .git --exclude node_modules)}"; do
    [[ -n "$skill_file" ]] || continue
    dir=${skill_file:h}
    [[ "${dir:t}" == "$name" ]] && { print -r -- "$dir"; return 0; }
    declared_name=$(skill_manifest_name "$skill_file" 2>/dev/null || true)
    [[ "$declared_name" == "$name" ]] && { print -r -- "$dir"; return 0; }
  done
  return 1
}

stage_skills_git() {
  local stage_dir=$1 source=$2
  shift 2

  local source_stage="$stage_dir/source-stage"
  local clone_dir
  local dest_dir="$stage_dir/.agents/skills"

  clone_dir=$(materialize_source "$source_stage" "$source")
  mkdir -p "$dest_dir"

  local name skill_dir dir skill_file source_uri root_name
  typeset -A seen_skill_names
  seen_skill_names=()
  if (( $# )); then
    for name in "$@"; do
      skill_dir=$(git_find_skill_dir "$clone_dir" "$name") \
        || die "$SCRIPT_NAME: skill '$name' not found in $source"
      rm -rf "$dest_dir/$name"
      cp -R "$skill_dir" "$dest_dir/$name"
    done
  else
    source_uri=$(source_spec_uri "$source")
    root_name=${${source_uri:t}%.git}
    for skill_file in "${(@f)$(fd -HI -t f -g SKILL.md "$clone_dir" --exclude .git --exclude node_modules)}"; do
      [[ -n "$skill_file" ]] || continue
      dir=${skill_file:h}
      if [[ "${dir:A}" == "${clone_dir:A}" ]]; then
        name=$(skill_manifest_name "$skill_file" 2>/dev/null || print -r -- "$root_name")
      else
        name=$(skill_manifest_name "$skill_file" 2>/dev/null || print -r -- "${dir:t}")
      fi
      [[ -z ${seen_skill_names[$name]-} ]] \
        || die "$SCRIPT_NAME: duplicate skill name '$name' in source: $source"
      seen_skill_names[$name]=1
      rm -rf "$dest_dir/$name"
      cp -R "$dir" "$dest_dir/$name"
    done
  fi
}

staged_skill_paths() {
  local skills_dir="$1/.agents/skills"
  local skill_dir

  for skill_dir in "$skills_dir"/*(N-/); do
    [[ -f "$skill_dir/SKILL.md" ]] || continue
    print -r -- "${skill_dir%/}"
  done
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
