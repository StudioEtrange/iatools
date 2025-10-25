
mcp_server_manage() {
    local mcp_server_name="$1"
    local action="$2"
    local agent_name="$3"
    local other_arg="$4"

    [ "$mcp_server_name" = "" ] && echo " -- ERROR : mcp server name missing" && exit 1
    [ "$action" = "" ] && echo " -- ERROR : action missing" && exit 1
    
    case "$mcp_server_name" in
        data-commons)
            echo " -- data-commons"
            if ! check_requirements "python"; then echo " -- ERROR : python missing, launch iatools init"; exit 1; fi;             
            case "$action" in
                "install")
                    echo "    Configuring"
                    [ ! -z "$other_arg" ] && export DC_API_KEY="$other_arg"
                    if [ -z "$DC_API_KEY" ]; then
                        echo " -- ERROR : missing Data Commons API key"
                        echo "    Provide a DC_API_KEY environment variable OR as third argument of the command"
                        echo "    You can get one from https://apikeys.datacommons.org/"
                        exit 1
                    fi
                    echo "    Provided DC_API_KEY for Data Commons API key from https://apikeys.datacommons.org/ : $DC_API_KEY"
                    case "$agent_name" in
                        "gc")gemini_merge_config "${_CURRENT_FILE_DIR}/pool/mcp-servers/data-commons/gemini-cli/settings.json";;
                        "oc")echo " -- ERROR : not supported";exit 1;;
                        *)echo " -- ERROR : missing or unknown target $agent_name";exit 1;;
                    esac
                    echo "    Configuration has been added"
                    ;;
                "uninstall")
                    echo "    Unregister mcp server from agent"
                    case "$agent_name" in
                        "gc")gemini_remove_config "mcpServers.data-commons";;
                        "oc")echo " -- ERROR : not supported";exit 1;;
                        *)echo " -- ERROR : missing or unknown target $agent_name";exit 1;;
                    esac
                    ;;
            esac
            ;;
        desktop-commander)
            echo " -- mcp-desktop-commander"
            if ! check_requirements "nodejs"; then echo " -- ERROR : nodejs missing, launch iatools init"; exit 1; fi;             
            case "$action" in
                "install")
                    echo "    Installing"
                    PATH="${IATOOLS_NODEJS_BIN_PATH}:${STELLA_ORIGINAL_SYSTEM_PATH}" npx -y @wonderwhy-er/desktop-commander@latest setup
                    echo "    Configuring"
                    export STELLA_ORIGINAL_SYSTEM_PATH
                    case "$agent_name" in
                        "gc")gemini_merge_config "${_CURRENT_FILE_DIR}/pool/mcp-servers/desktop-commander/gemini-cli/settings.json";;
                        "oc")echo " -- ERROR : not supported";exit 1;;
                        *)echo " -- ERROR : missing or unknown target $agent_name";exit 1;;
                    esac
                    echo "    Configuration has been added"
                    ;;
                "uninstall")
                    echo "    Unregister mcp server from agent"
                    rm -f "${IATOOLS_MCP_LAUNCHER_HOME}/desktop-commander"
                    case "$agent_name" in
                        "gc")gemini_remove_config "mcpServers.desktop-commander";;
                        "oc")echo " -- ERROR : not supported";exit 1;;
                        *)echo " -- ERROR : missing or unknown target $agent_name";exit 1;;
                    esac
                    echo "     Uninstalling"
                    PATH="${IATOOLS_NODEJS_BIN_PATH}:${STELLA_ORIGINAL_SYSTEM_PATH}" npx @wonderwhy-er/desktop-commander remove
                    ;;
            esac
            ;;
        calculator)
            echo " -- mcp-calculator"
            if ! check_requirements "python"; then echo " -- ERROR : python missing, launch iatools init"; exit 1; fi;
            case "$action" in
                "install")
                    echo "    Installing"
                    #${IATOOLS_PYTHON_BIN_PATH}pip install -v mcp-server-calculator
                    PATH="${IATOOLS_PYTHON_BIN_PATH}:${PATH}" uv pip install mcp-server-calculator --system
                    #${IATOOLS_PYTHON_BIN_PATH}python -m uv pip install -v mcp-server-calculator
                    echo "    Configuring"
                    case "$agent_name" in
                        "gc")gemini_merge_config "${_CURRENT_FILE_DIR}/pool/mcp-servers/calculator/gemini-cli/settings.json";;
                        "oc")opencode_merge_config "${_CURRENT_FILE_DIR}/pool/mcp-servers/calculator/opencode/opencode.json";;
                        *)echo " -- ERROR : missing or unknown target $agent_name";exit 1;;
                    esac
                    echo "    Configuration has been added"
                    ;;
                "uninstall")
                    echo "    Unregister mcp server from agent"
                    case "$agent_name" in
                        "gc")gemini_remove_config "mcpServers.calculator";;
                        "oc")opencode_remove_config "mcp.calculator";;
                        *)echo " -- ERROR : missing or unknown target $agent_name";exit 1;;
                    esac
                    echo "    Uninstalling"
                    ${IATOOLS_PYTHON_BIN_PATH}pip uninstall -y mcp-server-calculator
                    ;;
            esac
            ;;
        context7)
            # launch mcp server alternative way : using aan indirect launcher script
            echo " -- mcp-context7"
            if ! check_requirements "nodejs"; then echo " -- ERROR : nodejs missing, launch iatools init"; exit 1; fi;
            case "$action" in
                "install")
                    echo "    Configuring"
                    echo '#!/bin/sh' > "${IATOOLS_MCP_LAUNCHER_HOME}/context7"
                    echo "export PATH=\"${IATOOLS_NODEJS_BIN_PATH}:\${PATH}\"" >> "${IATOOLS_MCP_LAUNCHER_HOME}/context7"
                    echo "exec \"npx\" -y @upstash/context7-mcp --api-key \"\${CONTEXT7_API_KEY}\"" >> "${IATOOLS_MCP_LAUNCHER_HOME}/context7"
                    chmod +x "${IATOOLS_MCP_LAUNCHER_HOME}/context7"

                    [ ! -z "$other_arg" ] && export CONTEXT7_API_KEY="$other_arg"                        
                    echo "    Provided optional CONTEXT7_API_KEY : $CONTEXT7_API_KEY"
                    case "$agent_name" in
                        "gc")gemini_merge_config "${_CURRENT_FILE_DIR}/pool/mcp-servers/context7/gemini-cli/settings.json";;
                        "oc")opencode_merge_config "${_CURRENT_FILE_DIR}/pool/mcp-servers/context7/opencode/opencode.json";;
                        *)echo " -- ERROR : missing or unknown target $agent_name";exit 1;;
                    esac
                    echo "    Configuration has been added"
                    ;;
                "uninstall")
                    echo "    Unregister mcp server from agent"
                    rm -f "${IATOOLS_MCP_LAUNCHER_HOME}/context7"
                    case "$agent_name" in
                        "gc")gemini_remove_config "mcpServers.context7";;
                        "oc")opencode_remove_config "mcp.context7";;
                        *)echo " -- ERROR : missing or unknown target $agent_name";exit 1;;
                    esac
                    ;;
            esac
            ;;
        github)
            echo " -- mcp-github"
            if ! check_requirements "nodejs"; then echo " -- ERROR : nodejs missing, launch iatools init"; exit 1; fi;
            case "$action" in
                "install")
                    echo "    Configuring"
                    case "$agent_name" in
                        "gc")gemini_merge_config "${_CURRENT_FILE_DIR}/pool/mcp-servers/github/gemini-cli/settings.json";;
                        "oc")opencode_merge_config "${_CURRENT_FILE_DIR}/pool/mcp-servers/github/opencode/opencode.json";;
                        *)echo " -- ERROR : missing or unknown target $agent_name";exit 1;;
                    esac
                    echo "    Configuration has been added"
                    ;;
                "uninstall")
                    echo "    Unregister mcp server from agent"
                    case "$agent_name" in
                        "gc")gemini_remove_config "mcpServers.github";;
                        "oc")opencode_remove_config "mcp.github";;
                        *)echo " -- ERROR : missing or unknown target $agent_name";exit 1;;
                    esac
                    ;;
            esac
            ;;
        *)
            echo "Error: Unknown mcp $mcp_server_name"
            usage
            exit 1
            ;;
    esac
}
