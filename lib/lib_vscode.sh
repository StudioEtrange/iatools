

vscode_path() {
    local target="${1:-guess}"

    # this test works on linux AND wsl AND on every other system
    [ "$TERM_PROGRAM" = "vscode" ] && echo "We are running inside a VS Code terminal"

    # this test works remote ssh on linux AND on local wsl
    [ ! -z "$VSCODE_IPC_HOOK_CLI" ] && echo "We are using VS Code remote extension (SSH, WSL, ...)"

    # vscode pecific paths
    if [ "$target" = "guess" ]; then
        # we are inside a vs code remote ssh connection, so target is "remote"
        if [ -n "$VSCODE_IPC_HOOK_CLI" ]; then
            target="remote"
        else
            # a vscode server is installed on the host, so target is "remote"
            if [ -d "$HOME/.vscode-server/bin" ] && [ "$(ls -A "$HOME/.vscode-server/bin/"* 2>/dev/null)" ]; then
                target="remote"
            else
                target="local"
            fi
        fi
    fi

    case "$target" in
        "remote")
                # "VS Code Remote - Remote SSH or WSL config file"
                export IATOOLS_VSCODE_CONFIG_FILE="$HOME/.vscode-server/data/Machine/settings.json"
                ;;

        "local")
                # https://code.visualstudio.com/docs/configure/settings
                #   Windows %APPDATA%\Code\User\settings.json
                #   macOS $HOME/Library/Application\ Support/Code/User/settings.json
                #   Linux $HOME/.config/Code/User/settings.json
                case "$STELLA_CURRENT_PLATFORM" in
                    "linux") export IATOOLS_VSCODE_CONFIG_FILE="$HOME/.config/Code/User/settings.json";;
                    "darwin") export IATOOLS_VSCODE_CONFIG_FILE="$HOME/Library/Application Support/Code/User/settings.json";;
                esac
                ;;
    esac

    # iatools path for vs
    export IATOOLS_VSCODE_LAUNCHER_HOME="${IATOOLS_LAUNCHER_HOME}/vscode"
    mkdir -p "${IATOOLS_VSCODE_LAUNCHER_HOME}"
}

# inject specific target settings for vscode
vscode_settings_configure() {
    local target="$1"

    case "$target" in
        "gemini" )
            merge_json_file "${IATOOLS_POOL}/settings/gemini-cli/settings-for-vscode.json" "$IATOOLS_VSCODE_CONFIG_FILE"
        ;;
        "opencode" )
            merge_json_file "${IATOOLS_POOL}/settings/opencode/settings-for-vscode.json" "$IATOOLS_VSCODE_CONFIG_FILE"
        ;;
    esac
}

# remove specific target settings from vscode
vscode_settings_remove() {
    local target="$1"
    # NOTHING TO DO
    case "$target" in
        "gemini");;
        "opencode" );;
    esac
}

# PATH management -----------------
# NOTE : we need to keep at least code cli binary reacheable to launch vscode extension installation
#   when "terminal.integrated.env.linux".PATH on remote is empty, vscode remote-cli code path is auto added to PATH variable in terminal
#   when "terminal.integrated.env.linux".PATH on remote is defined, vscode remote-cli code path is NOT auto added to PATH variable in terminal
#       (the value of "terminal.integrated.inheritEnv" do not change this behavior)
#   so we add it manually because this script always set "terminal.integrated.env.linux".PATH which will never be empty anymore
vscode_path_register_for_vs_terminal() {
    local target="$1"
    local path_to_add="$2"

    # A/ add ${env:PATH} --------------
    echo "- configure VS Code : add current PATH to terminal.integrated.env.linux and terminal.integrated.env.osx PATH environment variable using \${env:PATH} value"
    vscode_settings_add_path_for_vs_terminal '${env:PATH}' "POSTPEND_IF_NOT_EXISTS"
    
    # B/ REGISTER PATH in vscode settings path to local binary 'code' local OR path to remote-cli binary 'code' --------------
    # because we always want to be able to reach vscode cli, and if terminal.integrated.env.linux it overrides global PATH veriable
    # so we need to explicitly set vscode cli in PATH
    vscode_path_register_cli_for_vs_terminal

    # C/ specific cli path --------------
    echo "- configure VS Code : add ${target} PATH to terminal.integrated.env.linux and terminal.integrated.env.osx PATH environment variable "
    vscode_settings_add_path_for_vs_terminal "${path_to_add}" "ALWAYS_PREPEND"
    #vscode_settings_add_path_for_vs_terminal "${IATOOLS_NODEJS_BIN_PATH}" "ALWAYS_PREPEND"
    #vscode_settings_add_path_for_vs_terminal "$(command -v gemini | xargs dirname)" "ALWAYS_PREPEND"

}

vscode_path_unregister_for_vs_terminal() {
    local target="$1"
    local path_to_remove="$2"
    echo "- configure VS Code : remove ${target} PATH from terminal.integrated.env.linux and terminal.integrated.env.osx PATH environment variable "
    vscode_settings_remove_path_for_vs_terminal "${path_to_remove}" "REMOVE"
}


# ADD vscode cli PATH to local binary 'code' CLI OR path to remote-cli binary 'code'
#       for vscode integrated terminal
# on linux server :
#   remote-cli code is in $HOME/.vscode-server/bin/<commit>/bin/remote-cli/code
# to select the latest vscode version, pick one of these :
#       - use $HOME/.vscode-server/cli/servers/lru.json which stores the last used vscode version
#       - [MY CHOICE :] filter ls result ordered by date $HOME/.vscode-server/cli/servers/Stable-*
#       - filter value of VSCODE_GIT_ASKPASS_NODE env variable setted by the core Git extension 
# on WSL linux :
#   remote cli code is in $HOME/.vscode-server/bin/<commit>/bin/remote-cli/code
vscode_path_register_cli_for_vs_terminal() {
    local code_found=0

    echo "- configure VS Code : add current PATH to code binary to terminal.integrated.env.linux PATH environment variable"
    if [ -d "$HOME/.vscode-server" ]; then
        # on remote linux server code cli
        if [ -d "$HOME/.vscode-server/bin" ] && [ "$(ls -A "$HOME/.vscode-server/bin/"* 2>/dev/null)" ]; then
            vscode_remote_home="$(ls -1dt "$HOME/.vscode-server/bin/"* | grep -v '/legacy-mode$' | head -n 1 | xargs -I {} echo {})"
            vscode_remote_cli_path="$vscode_remote_home/bin/remote-cli"

            if [ -f "${vscode_remote_cli_path}/code" ]; then
                code_found=1
                vscode_settings_remove_path_for_vs_terminal "^$HOME/.vscode-server/bin/.*" "REMOVE_REGEXP"
                vscode_settings_add_path_for_vs_terminal "$vscode_remote_cli_path" "ALWAYS_PREPEND"
                echo "- configure VS Code : remote-cli code found in $vscode_remote_cli_path"
            fi
        fi

        # WSL only
        if grep -qi microsoft /proc/version 2>/dev/null; then
            echo "- configure VS Code : WSL detected"
            if [ -d "$HOME/.vscode-server/bin" ] && [ "$(ls -A "$HOME/.vscode-server/bin/"* 2>/dev/null)" ]; then
                vscode_remote_home="$(ls -1dt "$HOME/.vscode-server/bin/"* | grep -v '/legacy-mode$' | head -n 1 | xargs -I {} echo {})"
                vscode_remote_cli_path="$vscode_remote_home/bin/remote-cli"

                if [ -f "${vscode_remote_cli_path}/code" ]; then
                    code_found=1
                    vscode_settings_remove_path_for_vs_terminal "^$HOME/.vscode-server/bin/.*" "REMOVE_REGEXP"
                    vscode_settings_add_path_for_vs_terminal "$vscode_remote_cli_path" "ALWAYS_PREPEND"
                    echo "- configure VS Code : WSL remote-cli code found in $vscode_remote_cli_path"
                fi
            fi
        fi

    else
        # local binary "code" cli
        case "$STELLA_CURRENT_PLATFORM" in
            "linux")
                echo "- TODO NOT IMPLEMENTED configure VS Code : linux code found in ------"
                ;; # TODO code binary might not be found
            "darwin") 
                vscode_cli_path="/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
                if [ -f "${vscode_remote_cli_path}/code" ]; then
                    code_found=1
                    vscode_settings_add_path_for_vs_terminal "$vscode_cli_path" "ALWAYS_PREPEND"
                    echo "- configure VS Code : darwin code found in $vscode_cli_path"
                fi
                ;;
        esac
    fi

    if [ $code_found -ne 1 ]; then
        echo "- WARN configure VS Code : code binary not detected, it might not been found inside terminal vscode."
    fi
}

# generic config management -----------------
vscode_merge_config() {
    local file_to_merge="$1"
    merge_json_file "$file_to_merge" "$IATOOLS_VSCODE_CONFIG_FILE"
}

vscode_remove_config() {
    local key_path="$1"
    json_del_key_from_file "$IATOOLS_VSCODE_CONFIG_FILE" "$key_path"
}

vscode_set_config() {
    local key_path="$1"
    local value="$2"
    json_set_key_into_file "$IATOOLS_VSCODE_CONFIG_FILE" "$key_path" "$value"
}

# http proxy management ------------------------
vscode_settings_set_http_proxy() {
    local http_proxy="$1"
    vscode_set_config "http\.proxy" "\"$http_proxy\""
}

vscode_settings_remove_http_proxy() {
    vscode_remove_config "http.proxy"
    # vscode_remove_config "https.proxy"
    vscode_remove_config "http.noProxy"
}

# path management ------------------------
vscode_settings_add_path_for_vs_terminal() {
    local path_to_add="$1"
    # ALWAYS_PREPEND add path or move it at the beginning position
    # ALWAYS_POSTPEND add path or move it at the end position
    # PREPEND_IF_NOT_EXISTS add path at the beginning position only if not already present
    # POSTPEND_IF_NOT_EXISTS add path at the end position only if not already present
    local mode="${2:-ALWAYS_PREPEND}" 
    vscode_settings_tweak_path_for_vs_terminal "$path_to_add" "$mode"
}

vscode_settings_remove_path_for_vs_terminal() {
    local path_to_remove="$1"
    # REMOVE remove all occurences of a fix expression
    # REMOVE_REGEXP remove all occurences of an regexp expression
    local mode="${2:-REMOVE}"
    vscode_settings_tweak_path_for_vs_terminal "$path_to_remove" "$mode"
}

# add PATH variable in vs code settings about integrated terminal
# by setting PATH env var at each integrated terminal launch
vscode_settings_tweak_path_for_vs_terminal() {
    local path="$1"
    # ALWAYS_PREPEND add path or move it at the beginning position
    # ALWAYS_POSTPEND add path or move it at the end position
    # PREPEND_IF_NOT_EXISTS add path at the beginning position only if not already present
    # POSTPEND_IF_NOT_EXISTS add path at the end position only if not already present
    local mode="${2:-ALWAYS_PREPEND}" 

    local tmp_file="$(mktemp)"

    cat "$IATOOLS_VSCODE_CONFIG_FILE" \
        | jq '
            # replace ":" inside ${...} with \u0001
            # case of ${env:FOO}
            def shield:
                if (type=="string") then
                    gsub("\\$\\{env:(?<var>[^}]+)\\}"; "${env\u0001" + .var + "}")
                else
                    .
                end;
            walk(shield)' \
        | json_tweak_value_of_list '.terminal\.integrated\.env\.linux.PATH' "$path" ':' "$mode" \
        | json_tweak_value_of_list '.terminal\.integrated\.env\.osx.PATH' "$path" ':' "$mode" \
        | jq '
            # restore ":"
            def unshield:
                if (type=="string") then gsub("\u0001"; ":") else . end;
            walk(unshield)' > "$tmp_file"
        
        if [ $? -ne 0 ]; then
            echo "ERROR : vscode_settings_tweak_path processing with jq"
            rm -f "$tmp_file"
            exit 1
        else
            mv "$tmp_file" "$IATOOLS_VSCODE_CONFIG_FILE"
            rm -f "$tmp_file"
        fi
}

