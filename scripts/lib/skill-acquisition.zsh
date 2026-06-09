acquisition_json_array_from_args() {
  jq -n --args '$ARGS.positional' "$@"
}

acquisition_skill_specs() {
  local registry_path=$1
  local entry source value_type value install_all skills_json

  [[ -f "$registry_path" ]] || return 0

  for entry in "${(@f)$(jq -c 'to_entries[]' "$registry_path")}"; do
    source=$(normalize_source "$(jq -r '.key' <<<"$entry")")
    value_type=$(jq -r '.value | type' <<<"$entry")
    install_all=false
    skills_json='[]'

    case "$value_type" in
      string)
        value=$(jq -r '.value' <<<"$entry")
        if [[ "$value" == "*" ]]; then
          install_all=true
        else
          skills_json=$(acquisition_json_array_from_args "$value")
        fi
        ;;
      array)
        skills_json=$(jq -c '.value' <<<"$entry")
        ;;
      *)
        die "$SCRIPT_NAME: invalid skill source spec: $source"
        ;;
    esac

    if [[ "$install_all" == false ]] && ! jq -e 'length > 0' <<<"$skills_json" >/dev/null; then
      die "$SCRIPT_NAME: empty skill list for source: $source"
    fi

    jq -cn \
      --arg source "$source" \
      --argjson install_all "$install_all" \
      --argjson skills "$skills_json" \
      '{source: $source, install_all: $install_all, skills: $skills}'
  done
}

acquisition_plugin_specs() {
  local registry_path=$1
  local entry name value_type source source_spec kind skills_type value install_all skills_json

  [[ -f "$registry_path" ]] || die "$SCRIPT_NAME: missing plugin registry: $registry_path"

  for entry in "${(@f)$(jq -c 'to_entries[]' "$registry_path")}"; do
    name=$(jq -r '.key' <<<"$entry")
    value_type=$(jq -r '.value | type' <<<"$entry")
    kind=skills
    install_all=false
    skills_json='[]'

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
            string)
              value=$(jq -r '.value.skills' <<<"$entry")
              if [[ "$value" == "*" ]]; then
                install_all=true
              else
                skills_json=$(acquisition_json_array_from_args "$value")
              fi
              ;;
            array)
              skills_json=$(jq -c '.value.skills' <<<"$entry")
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
      '{name: $name, source: $source, kind: $kind, install_all: $install_all, skills: $skills}'
  done
}

acquisition_spec_skills() {
  local spec_json=$1

  jq -r '.skills[]' <<<"$spec_json"
}

acquisition_stage_skills() {
  local stage_dir=$1
  local source=$2
  shift 2

  mkdir -p "$stage_dir"
  stage_skills "$stage_dir" "$source" "$@"
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
