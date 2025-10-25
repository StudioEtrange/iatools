
gemini_path() {
    # gc specific paths
    export IATOOLS_GEMINI_CONFIG_HOME="${HOME}/.gemini"
    export IATOOLS_GEMINI_CONFIG_CMD_HOME="${IATOOLS_GEMINI_CONFIG_HOME}/commands"
    export IATOOLS_GEMINI_CONFIG_FILE="${IATOOLS_GEMINI_CONFIG_HOME}/settings.json"

    # iatools path for gc
    export IATOOLS_GEMINI_LAUNCHER_HOME="${IATOOLS_LAUNCHER_HOME}/gemini-cli"
    mkdir -p "${IATOOLS_GEMINI_LAUNCHER_HOME}"

}


gemini_launcher_manage() {
    if [ -f "${IATOOLS_NODEJS_BIN_PATH}gemini" ]; then
        echo '#!/bin/sh' > "${IATOOLS_GEMINI_LAUNCHER_HOME}/gemini"
        echo "${IATOOLS_NODEJS_BIN_PATH}node ${IATOOLS_NODEJS_BIN_PATH}/gemini \$@" >> "${IATOOLS_GEMINI_LAUNCHER_HOME}/gemini"
        chmod +x "${IATOOLS_GEMINI_LAUNCHER_HOME}/gemini"

        # launcher based on symbolic link :
        # link doest not exist OR is not valid
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
    cat "${_CURRENT_FILE_DIR}/pool/settings/gemini-cli/settings.json"
    printf "\n"
    merge_json_file "${_CURRENT_FILE_DIR}/pool/settings/gemini-cli/settings.json" "$IATOOLS_GEMINI_CONFIG_FILE"
}

gemini_settings_remove() {
    rm -Rf "$IATOOLS_GEMINI_CONFIG_HOME"
}

gemini_merge_config() {
    file_to_merge="$1"
    merge_json_file "$file_to_merge" "$IATOOLS_GEMINI_CONFIG_FILE"
}

gemini_remove_config() {
    key_path="$1"
    json_remove_key "$key_path" "$IATOOLS_GEMINI_CONFIG_FILE"
}

gemini_add_command() {
    command_file="$1"

     if [ ! -f "${command_file}" ]; then
        echo "ERROR : command file not found ${command_file}"
        exit 1
    fi

    mkdir -p "${IATOOLS_GEMINI_CONFIG_CMD_HOME}"

    cp -f "${command_file}" "${IATOOLS_GEMINI_CONFIG_CMD_HOME}/"
}

gemini_remove_command() {
    command_file="$1"

    rm -f "${IATOOLS_GEMINI_CONFIG_CMD_HOME}/${command_file}"
}