

vscode_path() {
    [ "$TERM_PROGRAM" = "vscode" ] && echo "We are running inside a VSCode terminal"

    # vscode pecific paths
    if [ -d "$HOME/.vscode-server/data/Machine" ]; then
        # "VSCode Remote - SSH or WSL config file"
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
    target="$1"

    case "$target" in
        "gemini" )
            merge_json_file "${_CURRENT_FILE_DIR}/pool/settings/gemini-cli/settings-for-vscode.json" "$IATOOLS_VSCODE_CONFIG_FILE"
        ;;
        "opencode" )
            merge_json_file "${_CURRENT_FILE_DIR}/pool/settings/opencode/settings-for-vscode.json" "$IATOOLS_VSCODE_CONFIG_FILE"
        ;;
    esac


    # A/ add ${env:PATH} --------------
    vscode_settings_add_path '${env:PATH}' "POSTPEND_IF_NOT_EXISTS"
    

    
    # B/ binary 'code' local and remote-cli PATH --------------
    # NOTE : we need at least code binary to launch vscode extension installation
    #   when "terminal.integrated.env.linux".PATH on remote is empty, vscode remote-cli code path is auto added to PATH variable in terminal
    #   when "terminal.integrated.env.linux".PATH on remote is defined, vscode remote-cli code path is NOT auto added to PATH variable in terminal
    #       (the value of "terminal.integrated.inheritEnv" do not change this behavior)
    #   so we add it manually because this script always set "terminal.integrated.env.linux".PATH which will never be empty anymore
    
    # remote-cli code is in $HOME/.vscode-server/cli/servers/Stable-<commit>/server/bin/remote-cli/code
    # to select the latest vscode version, pick one of these :
    #       - use $HOME/.vscode-server/cli/servers/lru.json wich stores the last used vscode version
    #       - filter ls result ordered by date $HOME/.vscode-server/cli/servers/Stable-*
    #       - filter value of VSCODE_GIT_ASKPASS_NODE env variable setted by the core Git extension 
    if [ -d "$HOME/.vscode-server/cli/servers" ] && [ "$(ls -A "$HOME/.vscode-server/cli/servers/Stable-"* 2>/dev/null)" ]; then
        vscode_remote_home="$(ls -1dt "$HOME/.vscode-server/cli/servers/Stable-"* | head -n 1 | xargs -I {} echo {}/server)"
        vscode_remote_cli_path="$vscode_remote_home/bin/remote-cli"

        vscode_settings_remove_path "^$HOME/.vscode-server/cli/servers/Stable-.*" "REMOVE_REGEXP"
        [ -d "$vscode_remote_cli_path" ] && vscode_settings_add_path "$vscode_remote_cli_path" "ALWAYS_PREPEND"
    else

        # local binary "code"
        case "$STELLA_CURRENT_PLATFORM" in
            "linux") echo "ERROR : TODO support local linux vscode";;
            "darwin") 
                vscode_cli_path="/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
                [ -d "$vscode_cli_path" ] && vscode_settings_add_path "$vscode_cli_path" "ALWAYS_PREPEND"
                ;;
        esac
    fi




    # C/ specific cli path --------------
    case "$target" in
        "gemini" )
            vscode_settings_add_path "${IATOOLS_GEMINI_LAUNCHER_HOME}" "ALWAYS_PREPEND"
            #vscode_settings_add_path "${IATOOLS_NODEJS_BIN_PATH}" "ALWAYS_PREPEND"
            #vscode_settings_add_path "$(command -v gemini | xargs dirname)" "ALWAYS_PREPEND"
        ;;
        "opencode" )
            vscode_settings_add_path "${IATOOLS_OPENCODE_LAUNCHER_HOME}" "ALWAYS_PREPEND"
            #vscode_settings_add_path "${IATOOLS_NODEJS_BIN_PATH}" "ALWAYS_PREPEND"
            #vscode_settings_add_path "$(command -v opencode | xargs dirname)" "ALWAYS_PREPEND"
        ;;
    esac
}

vscode_settings_remove() {
    target="$1"

    case "$target" in
        "gemini" )
           vscode_settings_remove_path "${IATOOLS_GEMINI_LAUNCHER_HOME}" "REMOVE"
        ;;
        "opencode" )
            vscode_settings_remove_path "${IATOOLS_OPENCODE_LAUNCHER_HOME}" "REMOVE"
        ;;
    esac
}

vscode_settings_add_path() {
    path_expression_to_add="$1"
    # ALWAYS_PREPEND add path or move it at the beginning position
    # ALWAYS_POSTPEND add path or move it at the end position
    # PREPEND_IF_NOT_EXISTS add path at the beginning position only if not already present
    # POSTPEND_IF_NOT_EXISTS add path at the end position only if not already present
    mode="${2:-ALWAYS_PREPEND}" 
    vscode_settings_set_path "$IATOOLS_VSCODE_CONFIG_FILE" "$path_expression_to_add" "$mode"
}

vscode_settings_remove_path() {
    path_expression_to_remove="$1"
    # REMOVE remove all occurences of a fix expression
    # REMOVE_REGEXP remove all occurences of an regexp expression
    mode="${2:-REMOVE}"
    vscode_settings_set_path "$IATOOLS_VSCODE_CONFIG_FILE" "$path_expression_to_remove" "$mode"
}


vscode_settings_set_path() {
    vscode_settings_file="$1"
    path_expression="$2"
    # ALWAYS_PREPEND add path or move it at the beginning position
    # ALWAYS_POSTPEND add path or move it at the end position
    # PREPEND_IF_NOT_EXISTS add path at the beginning position only if not already present
    # POSTPEND_IF_NOT_EXISTS add path at the end position only if not already present
    # REMOVE remove all occurences of a fix expression
    # REMOVE_REGEXP remove all occurences of an regexp expression
    mode="${3:-ALWAYS_PREPEND}"

    if [ ! -s "$vscode_settings_file" ]; then
        echo "Valid target file not found at $vscode_settings_file. Creating it."
        mkdir -p "$(dirname "$vscode_settings_file")"
        echo "{}" > "$vscode_settings_file"
    fi

    tmp_file=$(mktemp)

    jq --arg set_path "$path_expression" --arg mode "$mode" '

    # replace ":" inside ${...} with \u0001
    def shield:
        if (type=="string") then
            gsub("\\$\\{env:(?<var>[^}]+)\\}"; "${env\u0001" + .var + "}")
        else
            .
        end;

    # restore ":"
    def unshield:
        if (type=="string") then gsub("\u0001"; ":") else . end;

    # split by ":" but keep ${...} together
    def split_keep_vars:
        if (type!="string") or (.=="") then 
            [] 
        else 
            ( . | shield | split(":") | map(unshield) )
        end;

    
    def process:
        if ($mode | startswith("REMOVE") | not) then
            if . == null or . == "" then
                $set_path
            else
                if $mode == "ALWAYS_PREPEND" then
                    ( split_keep_vars
                        | map(select(. != "" and . != $set_path))
                        | [$set_path] + .
                        | join(":")
                    )
                elif $mode == "ALWAYS_POSTPEND" then
                    ( split_keep_vars
                        | map(select(. != "" and . != $set_path))
                        | . + [$set_path]
                        | join(":")
                    )
                 elif $mode == "PREPEND_IF_NOT_EXISTS" then
                    (split_keep_vars) as $parts |
                    if ($parts | index($set_path)) then 
                        . 
                    else 
                        ( [$set_path] + $parts | join(":") ) 
                    end
                elif $mode == "POSTPEND_IF_NOT_EXISTS" then
                    (split_keep_vars) as $parts |
                    if ($parts | index($set_path)) then 
                        . 
                    else 
                        ($parts + [$set_path] | join(":")) 
                    end
                else
                    .
                end
            end
        else
            if . == null or . == "" then
                .
            else
                if $mode == "REMOVE" then
                    ( split_keep_vars
                        | map(select(. != "" and . != $set_path))
                        | join(":")
                    )
                elif $mode == "REMOVE_REGEXP" then
                    ( split_keep_vars
                        | map(select(. != "" and (. | test($set_path) | not)))
                        | join(":")
                    )
                else
                    .
                end
            end
        end;

    # linux
    .["terminal.integrated.env.linux"] = (.["terminal.integrated.env.linux"] // {}) |
    .["terminal.integrated.env.linux"].PATH |= process
    |
    # osx
    .["terminal.integrated.env.osx"] = (.["terminal.integrated.env.osx"] // {}) |
    .["terminal.integrated.env.osx"].PATH |= process

    ' "$vscode_settings_file" > "$tmp_file"
    if [ $? -ne 0 ]; then
        echo "ERROR : processing with jq"
        rm -f "$tmp_file"
        exit 1
    else
        mv "$tmp_file" "$vscode_settings_file"
    fi
}
