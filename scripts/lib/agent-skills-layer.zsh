typeset -g AGENT_SKILLS_CANONICAL_DIR
typeset -g AGENT_SKILLS_CLAUDE_DIR
typeset -g AGENT_SKILLS_CODEX_DIR
typeset -ga AGENT_SKILLS_PROJECTION_DIRS
typeset -ga AGENT_SKILLS_SHARED_BUNDLE_NAMES

AGENT_SKILLS_SHARED_BUNDLE_NAMES=(
  codex-primary-runtime
)

agent_skills_layer_init() {
  local home_dir=${1:-$HOME}

  AGENT_SKILLS_CANONICAL_DIR="$home_dir/.agents/skills"
  AGENT_SKILLS_CLAUDE_DIR="$home_dir/.claude/skills"
  AGENT_SKILLS_CODEX_DIR="$home_dir/.codex/skills"
  AGENT_SKILLS_PROJECTION_DIRS=(
    "$AGENT_SKILLS_CLAUDE_DIR"
    "$AGENT_SKILLS_CODEX_DIR"
  )
}

agent_skills_log() {
  local message=$1
  local prefix=${SCRIPT_NAME:-agent-skills-layer}

  print "$prefix: $message"
}

agent_skills_migrate_shared_bundle_to_canonical() {
  local name=$1
  local source_path="$AGENT_SKILLS_CODEX_DIR/$name"
  local canonical_path="$AGENT_SKILLS_CANONICAL_DIR/$name"

  [[ -e "$source_path" || -L "$source_path" ]] || return 0
  [[ ! -e "$canonical_path" && ! -L "$canonical_path" ]] || return 0

  if [[ -L "$source_path" ]]; then
    agent_skills_log "skipping canonical migration for $name: source is already a symlink"
    return 0
  fi

  if [[ ! -d "$source_path" ]]; then
    agent_skills_log "skipping canonical migration for $name: source is not a directory"
    return 0
  fi

  mv "$source_path" "$canonical_path"
  agent_skills_log "migrated shared bundle: $name"
}

agent_skills_prune_projected_symlinks() {
  local exposed_dir=$1
  local entry_name entry_path target

  for entry_path in "$exposed_dir"/*(N); do
    [[ -L "$entry_path" ]] || continue

    entry_name=${entry_path:t}
    target=$(readlink "$entry_path")

    if [[ "$target" == "$AGENT_SKILLS_CANONICAL_DIR/"* && ! -e "$AGENT_SKILLS_CANONICAL_DIR/$entry_name" && ! -L "$AGENT_SKILLS_CANONICAL_DIR/$entry_name" ]]; then
      rm -f "$entry_path"
    fi
  done
}

agent_skills_ensure_projected_symlink() {
  local exposed_dir=$1
  local canonical_path=$2
  local exposed_path="$exposed_dir/${canonical_path:t}"
  local target

  if [[ -L "$exposed_path" ]]; then
    target=$(readlink "$exposed_path")
    if [[ "$target" == "$canonical_path" ]]; then
      return 0
    fi

    if [[ "$target" == "$AGENT_SKILLS_CANONICAL_DIR/"* ]]; then
      rm -f "$exposed_path"
    else
      agent_skills_log "skipping projection for ${canonical_path:t}: existing symlink at $exposed_path"
      return 0
    fi
  elif [[ -e "$exposed_path" ]]; then
    if [[ -d "$exposed_path" && -d "$canonical_path" ]] && diff -qr "$exposed_path" "$canonical_path" >/dev/null 2>&1; then
      rm -rf "$exposed_path"
    else
      agent_skills_log "skipping projection for ${canonical_path:t}: existing entry at $exposed_path"
      return 0
    fi
  fi

  ln -s "$canonical_path" "$exposed_path"
}

agent_skills_append_preserved_bundles() {
  local managed_names_ref=$1
  local name

  [[ "$managed_names_ref" =~ '^[A-Za-z_][A-Za-z0-9_]*$' ]] || {
    agent_skills_log "invalid managed names array: $managed_names_ref"
    return 1
  }

  for name in "${AGENT_SKILLS_SHARED_BUNDLE_NAMES[@]}"; do
    [[ -d "$AGENT_SKILLS_CANONICAL_DIR/$name" || -d "$AGENT_SKILLS_CODEX_DIR/$name" ]] || continue
    eval "$managed_names_ref+=(\"\$name\")"
  done
}

agent_skills_reconcile_layer() {
  local name projection_dir skill_path

  mkdir -p "$AGENT_SKILLS_CANONICAL_DIR" "${AGENT_SKILLS_PROJECTION_DIRS[@]}"

  for name in "${AGENT_SKILLS_SHARED_BUNDLE_NAMES[@]}"; do
    agent_skills_migrate_shared_bundle_to_canonical "$name"
  done

  for projection_dir in "${AGENT_SKILLS_PROJECTION_DIRS[@]}"; do
    agent_skills_prune_projected_symlinks "$projection_dir"
  done

  for skill_path in "$AGENT_SKILLS_CANONICAL_DIR"/*(N/); do
    for projection_dir in "${AGENT_SKILLS_PROJECTION_DIRS[@]}"; do
      agent_skills_ensure_projected_symlink "$projection_dir" "$skill_path"
    done
  done
}

agent_skills_layer_init
