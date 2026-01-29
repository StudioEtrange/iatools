if ! check_requirements "yq"; then echo " -- ERROR : yq missing, launch iatools init"; exit 1; fi;
local sub_command="$1"
shift
case "$sub_command" in
    install)

        echo "Installing CLIProxyAPI"
        $STELLA_API get_feature "cliproxyapi"
        
        echo "Configuring CLIProxyAPI"
        cpa_settings_configure

        cpa_launcher_manage
        ;;
    uninstall)

        echo "Uninstalling CLIProxyAPI (keeping all configuration unchanged. to remove configuration use reset command)"
        $STELLA_API feature_remove "cliproxyapi" "NON_DECLARED"

        cpa_launcher_manage
        ;;
    configure)
        echo "Configuring CLIProxyAPI"
        cpa_settings_configure

        cpa_launcher_manage
        ;;
    info)
        cpa_info
        ;;
    show-config)
        if [ -f "$IATOOLS_CLIPROXYAPI_CONFIG_FILE" ]; then
            echo "Current CLIProxyAPI configuration file : $IATOOLS_CLIPROXYAPI_CONFIG_FILE"
            cat "$IATOOLS_CLIPROXYAPI_CONFIG_FILE"
        else
            echo "No CLIProxyAPI configuration file found."
        fi
        ;;
    set)
        case "$3" in
            "string")
                cpa_set_config "$1" "$2" "double"
                ;;
            *)
                cpa_set_config "$1" "$2"
                ;;
        esac
        ;;
    get)
        cpa_get_config "$1"
        ;;
    reset)
        echo "Resetting CLIProxyAPI configuration"
        cpa_settings_remove

        cpa_launcher_manage
        ;;
    key)
        case "$1" in
            generate)
                cpa_settings_api_key_create
                ;;
            reset)
                cpa_settings_api_key_reset
                ;;
            delete)
                cpa_settings_api_key_del "$2"
                ;;
            list)
                cpa_settings_api_key_list
                ;;
            *)
                echo "Error: Unknown command $1 for CLIProxyAPI key"
                usage
                exit 1
                ;;
        esac
        ;;
    launch)
        cpa_launcher_manage

        local list_args=()
        local dash_found=0
        case "$1" in
            "--" | "");;
            *)
                shift
                ;;
        esac
        if [ -f "$IATOOLS_CLIPROXYAPI_CONFIG_FILE" ]; then
            list_args+=("--config" "$IATOOLS_CLIPROXYAPI_CONFIG_FILE")
        fi
        for arg in "$@"; do
            if [ "$dash_found" -eq 1 ]; then
                list_args+=("$arg")
            elif [ "$arg" = "--" ]; then
                dash_found=1
            fi
        done
       
        if [ ${#list_args[@]} -gt 0 ]; then
            cli-proxy-api "${list_args[@]}"
        else
            cli-proxy-api
        fi
        ;;
    
    *)
        echo "Error: Unknown command $sub_command for CLIProxyAPI"
        usage
        exit 1
        ;;
esac