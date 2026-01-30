

vscode_path() {
    [ "$TERM_PROGRAM" = "vscode" ] && echo "We are running inside a VS Code terminal"

    # vscode pecific paths
    if [ -d "$HOME/.vscode-server/data/Machine" ]; then
        # "VS Code Remote - Remote SSH or WSL config file"
        export IATOOLS_VSCODE_CONFIG_FILE="$HOME/.vscode-server/data/Machine/settings.json"
    else
        # https://code.visualstudio.com/docs/configure/settings
        #   Windows %APPDATA%\Code\User\settings.json
        #   macOS $HOME/Library/Application\ Support/Code/User/settings.json
        #   Linux $HOME/.config/Code/User/settings.json
        case "$STELLA_CURRENT_PLATFORM" in
            "linux") export IATOOLS_VSCODE_CONFIG_FILE="$HOME/.config/Code/User/settings.json";;
            "darwin") export IATOOLS_VSCODE_CONFIG_FILE="$HOME/Library/Application Support/Code/User/settings.json";;
        esac
    fi
}

vscode_settings_configure() {
    local target="$1"

    case "$target" in
        "gemini" )
            merge_json_file "${_CURRENT_FILE_DIR}/pool/settings/gemini-cli/settings-for-vscode.json" "$IATOOLS_VSCODE_CONFIG_FILE"
        ;;
        "opencode" )
            merge_json_file "${_CURRENT_FILE_DIR}/pool/settings/opencode/settings-for-vscode.json" "$IATOOLS_VSCODE_CONFIG_FILE"
        ;;
    esac


    # A/ add ${env:PATH} --------------
    echo "- configure VS Code : add current PATH to terminal.integrated.env.linux PATH environment variable using \${env:PATH} value"
    vscode_settings_add_path '${env:PATH}' "POSTPEND_IF_NOT_EXISTS"
    

    
    # B/ binary 'code' local and remote-cli PATH --------------
    # NOTE : we need at least code binary to launch vscode extension installation
    #   when "terminal.integrated.env.linux".PATH on remote is empty, vscode remote-cli code path is auto added to PATH variable in terminal
    #   when "terminal.integrated.env.linux".PATH on remote is defined, vscode remote-cli code path is NOT auto added to PATH variable in terminal
    #       (the value of "terminal.integrated.inheritEnv" do not change this behavior)
    #   so we add it manually because this script always set "terminal.integrated.env.linux".PATH which will never be empty anymore
    
    # on linux server :
    # remote-cli code is in $HOME/.vscode-server/cli/servers/Stable-<commit>/server/bin/remote-cli/code
    # to select the latest vscode version, pick one of these :
    #       - use $HOME/.vscode-server/cli/servers/lru.json which stores the last used vscode version
    #       - [MY CHOICE :] filter ls result ordered by date $HOME/.vscode-server/cli/servers/Stable-*
    #       - filter value of VSCODE_GIT_ASKPASS_NODE env variable setted by the core Git extension 
    # on WSL linux :
    # remote cli code is in $HOME/.vscode-server/bin/<commit>/bin/remote-cli/code
    local code_found=0

    echo "- configure VS Code : add current PATH to code binary to terminal.integrated.env.linux PATH environment variable"
    if [ -d "$HOME/.vscode-server" ]; then
        # remote linux server
        if [ -d "$HOME/.vscode-server/cli/servers" ] && [ "$(ls -A "$HOME/.vscode-server/cli/servers/Stable-"* 2>/dev/null)" ]; then
            vscode_remote_home="$(ls -1dt "$HOME/.vscode-server/cli/servers/Stable-"* | grep -v '/legacy-mode$' | head -n 1 | xargs -I {} echo {}/server)"
            vscode_remote_cli_path="$vscode_remote_home/bin/remote-cli"

            if [ -f "${vscode_remote_cli_path}/code" ]; then
                code_found=1
                vscode_settings_remove_path "^$HOME/.vscode-server/cli/servers/Stable-.*" "REMOVE_REGEXP"
                vscode_settings_add_path "$vscode_remote_cli_path" "ALWAYS_PREPEND"
                echo "- configure VS Code : code found in $vscode_remote_cli_path"
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
                    vscode_settings_remove_path "^$HOME/.vscode-server/bin/.*" "REMOVE_REGEXP"
                    vscode_settings_add_path "$vscode_remote_cli_path" "ALWAYS_PREPEND"
                    echo "- configure VS Code : code found in $vscode_remote_cli_path"
                fi
            fi
        fi

    else
        # local binary "code"
        case "$STELLA_CURRENT_PLATFORM" in
            "linux");; # TODO code binary might not be found
            "darwin") 
                vscode_cli_path="/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
                if [ -f "${vscode_remote_cli_path}/code" ]; then
                    code_found=1
                    vscode_settings_add_path "$vscode_cli_path" "ALWAYS_PREPEND"
                fi
                ;;
        esac
    fi


    if [ $code_found -ne 1 ]; then
        echo "- WARN configure VS Code : code binary not detected, it might not been found inside terminal vscode."
    fi

    # C/ specific cli path --------------
    case "$target" in
        "gemini" )
            echo "- configure VS Code : add gemini cli launcher PATH to terminal.integrated.env.linux PATH environment variable "
            vscode_settings_add_path "${IATOOLS_GEMINI_LAUNCHER_HOME}" "ALWAYS_PREPEND"
            #vscode_settings_add_path "${IATOOLS_NODEJS_BIN_PATH}" "ALWAYS_PREPEND"
            #vscode_settings_add_path "$(command -v gemini | xargs dirname)" "ALWAYS_PREPEND"
        ;;
        "opencode" )
            echo "- configure VS Code : add opencode cli launcher PATH to terminal.integrated.env.linux"
            vscode_settings_add_path "${IATOOLS_OPENCODE_LAUNCHER_HOME}" "ALWAYS_PREPEND"
            #vscode_settings_add_path "${IATOOLS_NODEJS_BIN_PATH}" "ALWAYS_PREPEND"
            #vscode_settings_add_path "$(command -v opencode | xargs dirname)" "ALWAYS_PREPEND"
        ;;
    esac
}

vscode_settings_remove() {
    local target="$1"

    case "$target" in
        "gemini" )
           vscode_settings_remove_path "${IATOOLS_GEMINI_LAUNCHER_HOME}" "REMOVE"
        ;;
        "opencode" )
            vscode_settings_remove_path "${IATOOLS_OPENCODE_LAUNCHER_HOME}" "REMOVE"
        ;;
    esac
}

# generic config management -----------------
vscode_merge_config() {
    local file_to_merge="$1"
    merge_json_file "$file_to_merge" "$IATOOLS_VSCODE_CONFIG_FILE"
}

vscode_remove_config() {
    local key_path="$1"
    json_del_key_from_file "$key_path" "$IATOOLS_VSCODE_CONFIG_FILE"
}

vscode_set_config() {
    local key_path="$1"
    local value="$2"
    json_set_key_into_file "$key_path" "$value" "$IATOOLS_VSCODE_CONFIG_FILE"   
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
vscode_settings_add_path() {
    local path_to_add="$1"
    # ALWAYS_PREPEND add path or move it at the beginning position
    # ALWAYS_POSTPEND add path or move it at the end position
    # PREPEND_IF_NOT_EXISTS add path at the beginning position only if not already present
    # POSTPEND_IF_NOT_EXISTS add path at the end position only if not already present
    local mode="${2:-ALWAYS_PREPEND}" 
    vscode_settings_tweak_path "$path_to_add" "$mode"
}

vscode_settings_remove_path() {
    local path_to_remove="$1"
    # REMOVE remove all occurences of a fix expression
    # REMOVE_REGEXP remove all occurences of an regexp expression
    local mode="${2:-REMOVE}"
    vscode_settings_tweak_path "$path_to_remove" "$mode"
}

vscode_settings_tweak_path() {
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

# install an alternative sysroot with glibc 2.28
vscode_server_install_sysroot_228() {

    echo "install requirement : patchelf"
    $STELLA_API get_feature "patchelf"

    echo "...downloading a linux sysroot with glibc 2.28..."
    local sysroot_url="https://github.com/microsoft/vscode-linux-build-agent/releases/download/v20260127-398091/x86_64-linux-gnu-glibc-2.28-gcc-10.5.0.tar.gz"
    $STELLA_API get_resource "sysroot" "$sysroot_url" "HTTP_ZIP" "$STELLA_APP_WORK_ROOT/sysroot228" "DEST_ERASE STRIP"

}

vscode_server_settings_for_sysroot_228() {
    # path to the dynamic linker (ld-linux.so) in the sysroot (used for --set-interpreter option with patchelf)
    export VSCODE_SERVER_CUSTOM_GLIBC_LINKER="$STELLA_APP_WORK_ROOT/sysroot228/x86_64-linux-gnu/sysroot/lib/ld-linux-x86-64.so.2"
    # path to the library locations in the sysroot (used as --set-rpath option with patchelf)
    export VSCODE_SERVER_CUSTOM_GLIBC_PATH=="$STELLA_APP_WORK_ROOT/sysroot228/x86_64-linux-gnu/sysroot/lib"
    
    # path to the patchelf binary on the remote host
    $STELLA_API feature_info "patchelf" "PATCHELF"
    export VSCODE_SERVER_PATCHELF_PATH="$PATCHELF_FEAT_INSTALL_ROOT/bin/patchelf"
}
