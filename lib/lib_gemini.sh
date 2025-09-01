
gemini_files() {
    export GEMINI_CONFIG_HOME="$HOME/.gemini"
    export GEMINI_CONFIG_FILE="$GEMINI_CONFIG_HOME/settings.json"
}

gemini_settings_configure() {
    merge_json_file "${_CURRENT_FILE_DIR}/pool/settings/gemini-cli/settings.json" "$GEMINI_CONFIG_FILE"
}

gemini_settings_remove() {
    rm -Rf "$GEMINI_CONFIG_HOME"
}

gemini_merge_config() {
    file_to_merge="$1"
    merge_json_file "$file_to_merge" "$GEMINI_CONFIG_FILE"
}

gemini_remove_config() {
    key_path="$1"
    json_remove_key "$key_path" "$GEMINI_CONFIG_FILE"
}