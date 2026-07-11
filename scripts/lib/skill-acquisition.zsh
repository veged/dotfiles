acquisition_json_array_from_args() {
  jq -n --args '$ARGS.positional' "$@"
}

acquisition_skill_selection_json() {
  local value_json=$1
  local label=$2
  local value_type value install_all skills_json exclude_json negative_count positive_count

  value_type=$(jq -r 'type' <<<"$value_json")
  install_all=false
  skills_json='[]'
  exclude_json='[]'

  case "$value_type" in
    string)
      value=$(jq -r '.' <<<"$value_json")
      if [[ "$value" == "*" ]]; then
        install_all=true
      elif [[ "$value" == !* ]]; then
        [[ "$value" != "!" ]] || die "$SCRIPT_NAME: empty excluded skill name for $label"
        install_all=true
        exclude_json=$(acquisition_json_array_from_args "${value#!}")
      else
        skills_json=$(acquisition_json_array_from_args "$value")
      fi
      ;;
    array)
      jq -e 'all(.[]; type == "string")' <<<"$value_json" >/dev/null \
        || die "$SCRIPT_NAME: invalid skill list for $label"

      negative_count=$(jq '[.[] | select(startswith("!"))] | length' <<<"$value_json")
      positive_count=$(jq '[.[] | select(startswith("!") | not)] | length' <<<"$value_json")

      if (( negative_count && positive_count )); then
        die "$SCRIPT_NAME: cannot mix included and excluded skills for $label"
      fi

      if (( negative_count )); then
        jq -e 'all(.[]; . != "!")' <<<"$value_json" >/dev/null \
          || die "$SCRIPT_NAME: empty excluded skill name for $label"
        install_all=true
        exclude_json=$(jq -c 'map(.[1:])' <<<"$value_json")
      else
        skills_json=$(jq -c '.' <<<"$value_json")
      fi
      ;;
    *)
      die "$SCRIPT_NAME: invalid skill selection for $label"
      ;;
  esac

  jq -cn \
    --argjson install_all "$install_all" \
    --argjson skills "$skills_json" \
    --argjson exclude "$exclude_json" \
    '{install_all: $install_all, skills: $skills, exclude: $exclude}'
}

acquisition_skill_specs() {
  local registry_path=$1
  local entry source selection_json install_all skills_json exclude_json

  [[ -f "$registry_path" ]] || return 0

  for entry in "${(@f)$(jq -c 'to_entries[]' "$registry_path")}"; do
    source=$(normalize_source "$(jq -r '.key' <<<"$entry")")
    selection_json=$(acquisition_skill_selection_json "$(jq -c '.value' <<<"$entry")" "source: $source")
    install_all=$(jq -r '.install_all' <<<"$selection_json")
    skills_json=$(jq -c '.skills' <<<"$selection_json")
    exclude_json=$(jq -c '.exclude' <<<"$selection_json")

    if [[ "$install_all" == false ]] && ! jq -e 'length > 0' <<<"$skills_json" >/dev/null; then
      die "$SCRIPT_NAME: empty skill list for source: $source"
    fi

    jq -cn \
      --arg source "$source" \
      --argjson install_all "$install_all" \
      --argjson skills "$skills_json" \
      --argjson exclude "$exclude_json" \
      '{source: $source, install_all: $install_all, skills: $skills, exclude: $exclude}'
  done
}

acquisition_plugin_specs() {
  local registry_path=$1
  local entry name value_type source source_spec kind skills_type install_all skills_json exclude_json selection_json

  [[ -f "$registry_path" ]] || die "$SCRIPT_NAME: missing plugin registry: $registry_path"

  for entry in "${(@f)$(jq -c 'to_entries[]' "$registry_path")}"; do
    name=$(jq -r '.key' <<<"$entry")
    value_type=$(jq -r '.value | type' <<<"$entry")
    kind=skills
    install_all=false
    skills_json='[]'
    exclude_json='[]'

    case "$value_type" in
      string)
        source=$(normalize_source "$(jq -r '.value' <<<"$entry")")
        install_all=true
        ;;
      object)
        source_spec=$(jq -er '.value.source' <<<"$entry" 2>/dev/null) || die "$SCRIPT_NAME: missing source for plugin: $name"
        source=$(normalize_source "$source_spec")
        kind=$(jq -r '.value.kind // "skills"' <<<"$entry")
        [[ "$kind" == "skills" || "$kind" == "plugin" ]] || die "$SCRIPT_NAME: invalid plugin kind for $name: $kind"

        if [[ "$kind" == "plugin" ]]; then
          if jq -e '.value | has("skills")' <<<"$entry" >/dev/null; then
            die "$SCRIPT_NAME: plugin kind must not declare skills: $name"
          fi

          install_all=true
        else
          skills_type=$(jq -r 'if .value.skills == null then "null" else (.value.skills | type) end' <<<"$entry")
          case "$skills_type" in
            null)
              install_all=true
              ;;
            string|array)
              selection_json=$(acquisition_skill_selection_json "$(jq -c '.value.skills' <<<"$entry")" "plugin: $name")
              install_all=$(jq -r '.install_all' <<<"$selection_json")
              skills_json=$(jq -c '.skills' <<<"$selection_json")
              exclude_json=$(jq -c '.exclude' <<<"$selection_json")
              ;;
            *)
              die "$SCRIPT_NAME: invalid skills spec for plugin: $name"
              ;;
          esac
        fi
        ;;
      *)
        die "$SCRIPT_NAME: invalid plugin source spec: $name"
        ;;
    esac

    if [[ "$install_all" == false ]] && ! jq -e 'length > 0' <<<"$skills_json" >/dev/null; then
      die "$SCRIPT_NAME: empty skill list for plugin: $name"
    fi

    jq -cn \
      --arg name "$name" \
      --arg source "$source" \
      --arg kind "$kind" \
      --argjson install_all "$install_all" \
      --argjson skills "$skills_json" \
      --argjson exclude "$exclude_json" \
      '{name: $name, source: $source, kind: $kind, install_all: $install_all, skills: $skills, exclude: $exclude}'
  done
}

acquisition_spec_skills() {
  local spec_json=$1

  jq -r '.skills[]' <<<"$spec_json"
}

acquisition_spec_excluded_skills() {
  local spec_json=$1

  jq -r '.exclude[]?' <<<"$spec_json"
}

acquisition_stage_skills() {
  local stage_dir=$1
  local source=$2
  shift 2

  mkdir -p "$stage_dir"
  # Clone explicit git URLs directly; GitHub shorthands go through the skills CLI.
  if [[ "$source" == *.git || ( "$source" == *://* && "$source" != https://github.com/* ) ]]; then
    stage_skills_git "$stage_dir" "$source" "$@"
  else
    stage_skills "$stage_dir" "$source" "$@"
  fi
}

acquisition_staged_skill_paths() {
  local stage_dir=$1

  staged_skill_paths "$stage_dir"
}

acquisition_has_selected_skills() {
  local skills_root=$1
  shift

  local skill_name

  for skill_name in "$@"; do
    [[ -d "$skills_root/$skill_name" ]] || return 1
  done

  return 0
}
