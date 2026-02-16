
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

# add opencode launcher in path for shell
opencode_path_register_for_shell() {
    local shell_name="$1"
    path_register_for_shell "opencode" "$shell_name" "${IATOOLS_OPENCODE_LAUNCHER_HOME}"
}
opencode_path_unregister_for_shell() {
    local shell_name="$1"
    path_unregister_for_shell "opencode" "$shell_name"
}
opencode_path_register_for_vs_terminal() {
    vscode_path_register_for_vs_terminal "opencode" "${IATOOLS_OPENCODE_LAUNCHER_HOME}"
}
opencode_path_unregister_for_vs_terminal() {
    vscode_path_unregister_for_vs_terminal "opencode" "${IATOOLS_OPENCODE_LAUNCHER_HOME}"
}

opencode_launcher_manage() {
    if [ -f "${IATOOLS_NODEJS_BIN_PATH}opencode" ]; then
        # launcher based on a symbolic link :
        # link does not exist OR is not valid
        if [ ! -L "${IATOOLS_OPENCODE_LAUNCHER_HOME}/opencode" ] || [ ! -e "${IATOOLS_OPENCODE_LAUNCHER_HOME}/opencode" ]; then
            echo "Create an opencode launcher"
            ln -fsv "${IATOOLS_NODEJS_BIN_PATH}opencode" "${IATOOLS_OPENCODE_LAUNCHER_HOME}/opencode"
        fi
    else
        rm -f "${IATOOLS_OPENCODE_LAUNCHER_HOME}/opencode"
    fi
}

opencode_settings_configure() {
    merge_json_file "${IATOOLS_POOL}/settings/opencode/opencode.json" "$IATOOLS_OPENCODE_CONFIG_FILE"
}

opencode_settings_remove() {
    rm -Rf "$IATOOLS_OPENCODE_LOCAL_SHARE_HOME"
    rm -Rf "$IATOOLS_OPENCODE_CONFIG_HOME"
}

opencode_merge_config() {
    local file_to_merge="$1"
    merge_json_file "$file_to_merge" "$IATOOLS_OPENCODE_CONFIG_FILE"
}

opencode_remove_config() {
    local key_path="$1"
    json_del_key_from_file "$IATOOLS_OPENCODE_CONFIG_FILE" "$key_path" 
}