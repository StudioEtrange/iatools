
gemini_path() {
    # gc specific paths
    export IATOOLS_GEMINI_CONFIG_HOME="${HOME}/.gemini"
    export IATOOLS_GEMINI_CONFIG_CMD_HOME="${IATOOLS_GEMINI_CONFIG_HOME}/commands"
    export IATOOLS_GEMINI_CONFIG_FILE="${IATOOLS_GEMINI_CONFIG_HOME}/settings.json"

    # iatools path for gc
    export IATOOLS_GEMINI_LAUNCHER_HOME="${IATOOLS_LAUNCHER_HOME}/gemini-cli"
    mkdir -p "${IATOOLS_GEMINI_LAUNCHER_HOME}"

}

# add gemini launcher in path for shell
gemini_path_register_for_shell() {
    local shell_name="$1"
    path_register_for_shell "gemini" "$shell_name" "${IATOOLS_GEMINI_LAUNCHER_HOME}"
}
gemini_path_unregister_for_shell() {
    local shell_name="$1"
    path_unregister_for_shell "gemini" "$shell_name"
}
gemini_path_register_for_vs_terminal() {
    vscode_path_register_for_vs_terminal "gemini" "${IATOOLS_GEMINI_LAUNCHER_HOME}"
}
gemini_path_unregister_for_vs_terminal() {
    vscode_path_unregister_for_vs_terminal "gemini" "${IATOOLS_GEMINI_LAUNCHER_HOME}"
}



gemini_launcher_manage() {
    if [ -f "${IATOOLS_NODEJS_BIN_PATH}gemini" ]; then
        echo '#!/bin/sh' > "${IATOOLS_GEMINI_LAUNCHER_HOME}/gemini"
        echo "${IATOOLS_NODEJS_BIN_PATH}node ${IATOOLS_NODEJS_BIN_PATH}/gemini \$@" >> "${IATOOLS_GEMINI_LAUNCHER_HOME}/gemini"
        chmod +x "${IATOOLS_GEMINI_LAUNCHER_HOME}/gemini"

        # launcher based on symbolic link :
        # link does not exist OR is not valid
        # if [ ! -L "${IATOOLS_GEMINI_LAUNCHER_HOME}/gemini" ] || [ ! -e "${IATOOLS_GEMINI_LAUNCHER_HOME}/gemini" ]; then
        #     echo "Create a gemini launcher"
        #     ln -fsv "${IATOOLS_NODEJS_BIN_PATH}/gemini" "${IATOOLS_GEMINI_LAUNCHER_HOME}/gemini"
        # fi
    else
        rm -f "${IATOOLS_GEMINI_LAUNCHER_HOME}/gemini"
    fi
}


gemini_settings_configure() {
    echo "add some default settings :"
    echo " - disable statistics usage data send"
    echo " - support for autoloading AGENTS.md file"
    cat "${IATOOLS_POOL}/settings/gemini-cli/settings.json"
    printf "\n"
    merge_json_file "${IATOOLS_POOL}/settings/gemini-cli/settings.json" "$IATOOLS_GEMINI_CONFIG_FILE"
}

gemini_settings_remove() {
    rm -Rf "$IATOOLS_GEMINI_CONFIG_HOME"
}

gemini_merge_config() {
    local file_to_merge="$1"
    merge_json_file "$file_to_merge" "$IATOOLS_GEMINI_CONFIG_FILE"
}

gemini_remove_config() {
    local key_path="$1"
    json_del_key_from_file "$IATOOLS_GEMINI_CONFIG_FILE" "$key_path"
}

gemini_add_command() {
    local command_file="$1"

     if [ ! -f "${command_file}" ]; then
        echo "ERROR : command file not found ${command_file}"
        exit 1
    fi

    mkdir -p "${IATOOLS_GEMINI_CONFIG_CMD_HOME}"

    cp -f "${command_file}" "${IATOOLS_GEMINI_CONFIG_CMD_HOME}/"
}

gemini_remove_command() {
    local command_file="$1"

    rm -f "${IATOOLS_GEMINI_CONFIG_CMD_HOME}/${command_file}"
}