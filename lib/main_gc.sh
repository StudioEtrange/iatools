if ! check_requirements "jq"; then echo " -- ERROR : jq missing, launch iatools init"; exit 1; fi;
local sub_command="$1"
shift
case "$sub_command" in
    install)
        if ! check_requirements "nodejs"; then echo " -- ERROR : nodejs missing, launch iatools init"; exit 1; fi;

        local version="$1"
        [ -z "${version}" ] && version="@latest"

        echo "Installing Gemini CLI ${version}"
        # available versions : https://www.npmjs.com/package/@google/gemini-cli-core
        # latest is stable version
        # 2025/09/13 : cannot install behind a http proxy : https://github.com/google-gemini/gemini-cli/issues/7795
        PATH="${IATOOLS_NODEJS_BIN_PATH}:${STELLA_ORIGINAL_SYSTEM_PATH}" npm install --verbose -g @google/gemini-cli${version}
        
        echo "Configuring Gemini CLI"
        gemini_settings_configure
        vscode_settings_configure "gemini"

        gemini_launcher_manage
        ;;
    uninstall)
        if ! check_requirements "nodejs"; then echo " -- ERROR : nodejs missing, launch iatools init"; exit 1; fi;

        echo "Uninstalling Gemini CLI (keeping all configuration unchanged. to remove configuration use reset command)"
        PATH="${IATOOLS_NODEJS_BIN_PATH}:${STELLA_ORIGINAL_SYSTEM_PATH}" npm uninstall -g @google/gemini-cli

        gemini_launcher_manage
        ;;
    configure)
        echo "Configuring Gemini CLI"
        gemini_settings_configure
        vscode_settings_configure "gemini"

        gemini_launcher_manage
        ;;
    show-config)
        if [ -f "$IATOOLS_GEMINI_CONFIG_FILE" ]; then
            echo "Current Gemini CLI configuration file : $IATOOLS_GEMINI_CONFIG_FILE"
            cat "$IATOOLS_GEMINI_CONFIG_FILE"
        else
            echo "No Gemini CLI configuration file found."
        fi
        ;;
    reset)
        echo "Resetting Gemini CLI configuration"
        gemini_settings_remove
        vscode_settings_remove "gemini"

        gemini_launcher_manage
        ;;
    launch)
        gemini_launcher_manage

        local folder=
        local list_args=()
        local dash_found=0
        case "$1" in
            "--" | "");;
            *)
                folder="$1"
                shift
                ;;
        esac
        for arg in "$@"; do
            if [ "$dash_found" -eq 1 ]; then
                list_args+=("$arg")
            elif [ "$arg" = "--" ]; then
                dash_found=1
            fi
        done
        if [ ! -z "$folder" ]; then
            if [ -d "$folder" ]; then
                cd "$folder"
            else
                echo "Error: Directory '$folder' not found"
                exit 1
            fi
        fi
        if [ ${#list_args[@]} -gt 0 ]; then
            gemini "${list_args[@]}"
        else
            gemini
        fi
        ;;
    cmd-plan)
        case "$1" in
            "install")
                gemini_add_command "${_CURRENT_FILE_DIR}/pool/cmd/plan/plan.toml"
                ;;
            "uninstall")
                gemini_remove_command "plan.toml"
                ;;
        esac
        ;;
    mcp)
        mcp_server_manage "$1" "$2" "$command" "$3"
        ;;
    *)
        echo "Error: Unknown command $sub_command for gc"
        usage
        exit 1
        ;;
esac