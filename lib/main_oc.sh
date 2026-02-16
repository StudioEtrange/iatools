if ! check_requirements "jq"; then echo " -- ERROR : jq missing, launch iatools init"; exit 1; fi;
local sub_command="$1"
shift
case "$sub_command" in
    install)
        if ! check_requirements "nodejs"; then echo " -- ERROR : nodejs missing, launch iatools init"; exit 1; fi;

        echo "Installing Opencode CLI"
        PATH="${IATOOLS_NODEJS_BIN_PATH}:${STELLA_ORIGINAL_SYSTEM_PATH}" npm install --verbose -g opencode-ai@latest
    
        echo "Configuring Opencode CLI"
        opencode_settings_configure
        vscode_settings_configure "opencode"
        
        opencode_launcher_manage

        echo "You could now register it's path in shell OR vscode terminal"
        echo "$0 oc register bash|zsh|fish"
        echo "   OR"
        echo "$0 oc register vs"
        ;;
    uninstall)
        if ! check_requirements "nodejs"; then echo " -- ERROR : nodejs missing, launch iatools init"; exit 1; fi;

        echo "Uninstalling Opencode and unregister Opencode PATH (keep all configuration unchanged, to remove configuration use reset command)"
        
        PATH="${IATOOLS_NODEJS_BIN_PATH}:${STELLA_ORIGINAL_SYSTEM_PATH}" npm uninstall -g opencode-ai
        opencode_path_unregister_for_shell "all"
        opencode_path_unregister_for_vs_terminal

        opencode_launcher_manage
        ;;
    configure)
        echo "Configuring Opencode CLI"
        opencode_settings_configure
        vscode_settings_configure "opencode"

        opencode_launcher_manage
        ;;
    register)
        echo "Registering Gemini CLI launcher in PATH for $1"
        case "$1" in
            "vs")
                opencode_path_register_for_vs_terminal
                ;;
            *)
                opencode_path_register_for_shell "$1"
                ;;
        esac
        ;;
    unregister)
        echo "Unegistering Opencode launcher PATH from $1"
        case "$1" in
            "vs")
                opencode_path_unregister_for_vs_terminal
                ;;
            *)
                opencode_path_unregister_for_shell "$1"
                ;;
        esac
        ;;
    show-config)
        if [ -f "$IATOOLS_OPENCODE_CONFIG_FILE" ]; then
            echo "Current Opencode configuration file : $IATOOLS_OPENCODE_CONFIG_FILE"
            cat "$IATOOLS_OPENCODE_CONFIG_FILE"
        else
            echo "No Opencode configuration file found."
        fi
        ;;
    reset)
        echo "Resetting Opencode configuration"
        opencode_settings_remove
        vscode_settings_remove "opencode"

        opencode_launcher_manage
        ;;
    launch)
        opencode_launcher_manage

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
        case "$folder" in
            "")
                if [ ${#list_args[@]} -gt 0 ]; then
                    opencode "${list_args[@]}"
                else
                    opencode
                fi
                ;;
            *)
                if [ -d "$folder" ]; then
                    if [ ${#list_args[@]} -gt 0 ]; then
                        opencode "$folder" "${list_args[@]}"
                    else
                        opencode "$folder"
                    fi
                    else
                    echo "Error: Directory '$folder' not found"
                    exit 1
                fi
                ;;
        esac
        ;;
    mcp)
        mcp_server_manage "$1" "$2" "$command" "$3"
        ;;
    *)
        echo "Error: Unknown command $sub_command for oc"
        usage
        exit 1
        ;;
esac