
opencode_files() {
    export OPENCODE_LOCAL_SHARE_HOME="$HOME/.local/share/opencode"
    export OPENCODE_CONFIG_HOME="$HOME/.config/opencode"
    #You can also specify a custom config file path using the OPENCODE_CONFIG environment variable. This takes precedence over the global and project configs.
    [ "$OPENCODE_CONFIG" == "" ] && export OPENCODE_CONFIG_FILE="$OPENCODE_CONFIG_HOME/opencode.json" || export OPENCODE_CONFIG_FILE="$OPENCODE_CONFIG"
}


opencode_settings_configure() {
    merge_json_file "${_CURRENT_FILE_DIR}/pool/settings/opencode/opencode.json" "$OPENCODE_CONFIG_FILE"
}

opencode_settings_remove() {
    rm -Rf "$OPENCODE_LOCAL_SHARE_HOME"
    rm -Rf "$OPENCODE_CONFIG"
}

opencode_merge_config() {
    file_to_merge="$1"
    merge_json_file "$file_to_merge" "$OPENCODE_CONFIG_FILE"
}

opencode_remove_config() {
    key_path="$1"
    json_remove_key "$key_path" "$OPENCODE_CONFIG_FILE"
}