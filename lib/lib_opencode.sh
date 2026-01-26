
opencode_path() {
    # oc specific paths
    export IATOOLS_OPENCODE_LOCAL_SHARE_HOME="$HOME/.local/share/opencode"
    export IATOOLS_OPENCODE_CONFIG_HOME="$HOME/.config/opencode"
    #You can also specify a custom config file path using the OPENCODE_CONFIG environment variable. This takes precedence over the global and project configs.
    [ "$OPENCODE_CONFIG" = "" ] && export IATOOLS_OPENCODE_CONFIG_FILE="$IATOOLS_OPENCODE_CONFIG_HOME/opencode.json" || export IATOOLS_OPENCODE_CONFIG_FILE="$OPENCODE_CONFIG"

    # iatools path for oc
    export IATOOLS_OPENCODE_LAUNCHER_HOME="${IATOOLS_LAUNCHER_HOME}/opencode"
    mkdir -p "${IATOOLS_OPENCODE_LAUNCHER_HOME}"


}

opencode_launcher_manage() {
    if [ -f "${IATOOLS_NODEJS_BIN_PATH}opencode" ]; then
        # launcher based on a symbolic link :
        # link doest not exist OR is not valid
        if [ ! -L "${IATOOLS_OPENCODE_LAUNCHER_HOME}/opencode" ] || [ ! -e "${IATOOLS_OPENCODE_LAUNCHER_HOME}/opencode" ]; then
            echo "Create an opencode launcher"
            ln -fsv "${IATOOLS_NODEJS_BIN_PATH}opencode" "${IATOOLS_OPENCODE_LAUNCHER_HOME}/opencode"
        fi
    else
        rm -f "${IATOOLS_OPENCODE_LAUNCHER_HOME}/opencode"
    fi
}

opencode_settings_configure() {
    merge_json_file "${_CURRENT_FILE_DIR}/pool/settings/opencode/opencode.json" "$IATOOLS_OPENCODE_CONFIG_FILE"
}

opencode_settings_remove() {
    rm -Rf "$IATOOLS_OPENCODE_LOCAL_SHARE_HOME"
    rm -Rf "$IATOOLS_OPENCODE_CONFIG_HOME"
}

opencode_merge_config() {
    file_to_merge="$1"
    merge_json_file "$file_to_merge" "$IATOOLS_OPENCODE_CONFIG_FILE"
}

opencode_remove_config() {
    key_path="$1"
    json_del_key_from_file "$key_path" "$IATOOLS_OPENCODE_CONFIG_FILE"
}