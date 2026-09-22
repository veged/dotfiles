#!/usr/bin/env zsh

emulate -LR zsh
set -euo pipefail

source_repo=${0:A:h:h:h}
fixture_root=$(mktemp -d "${TMPDIR:-/tmp}/skill-projection-migration.XXXXXX")
trap 'rm -rf "$fixture_root"' EXIT
repo_root="$fixture_root/repo"
fixture_home="$fixture_root/home"
source "$source_repo/scripts/lib/install-common.zsh"
source "$source_repo/scripts/lib/agent-skills-layer.zsh"
agent_skills_layer_init "$fixture_home"
mkdir -p "$repo_root/ai/skills" "$AGENT_SKILLS_CANONICAL_DIR" "${AGENT_SKILLS_PROJECTION_DIRS[@]}"

# Полные копии, старый псевдоним и одинаковая инструкция с разными ресурсами.
for pair in arc:arc intrasearch:community-intrasearch customized:customized; do
  legacy_name=${pair%%:*}
  canonical_name=${pair#*:}
  source_path="$fixture_home/old sources/$legacy_name"
  canonical_path="$AGENT_SKILLS_CANONICAL_DIR/$canonical_name"
  mkdir -p "$source_path/references" "$canonical_path"
  printf -- '---\nname: %s\n---\nИнструкция\n' "$canonical_name" > "$source_path/SKILL.md"
  print -r -- "Ресурс" > "$source_path/references/reference.md"
  cp -R "$source_path/." "$canonical_path/"
  for projection_dir in "${AGENT_SKILLS_PROJECTION_DIRS[@]}"; do
    ln -s "$source_path" "$projection_dir/$legacy_name"
  done
done
print -r -- "Другой ресурс" > "$AGENT_SKILLS_CANONICAL_DIR/customized/references/reference.md"

jq -n --arg arc "$fixture_home/old sources/arc" --arg custom "$fixture_home/old sources/customized" \
  '{($arc): "*", "~/old sources/intrasearch": "*", ($custom): "*"}' > "$repo_root/ai/skills/skills.json"

agent_skills_reconcile_layer
agent_skills_reconcile_layer
for projection_dir in "${AGENT_SKILLS_PROJECTION_DIRS[@]}"; do
  [[ $(readlink "$projection_dir/arc") == "$AGENT_SKILLS_CANONICAL_DIR/arc" ]]
  [[ $(readlink "$projection_dir/community-intrasearch") == "$AGENT_SKILLS_CANONICAL_DIR/community-intrasearch" ]]
  [[ ! -e "$projection_dir/intrasearch" && ! -L "$projection_dir/intrasearch" ]]
  [[ $(readlink "$projection_dir/customized") == "$fixture_home/old sources/customized" ]]
done
for legacy_name in arc intrasearch customized; do
  [[ -f "$fixture_home/old sources/$legacy_name/SKILL.md" ]]
  [[ $(<"$fixture_home/old sources/$legacy_name/references/reference.md") == 'Ресурс' ]]
done
print 'test-skill-projection-migration: ok'
