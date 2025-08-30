

vscode_files() {
    # vscode files
    if [ -d "$HOME/.vscode-server/data/Machine" ]; then
        echo "Detected VSCode Server environment. You are likely using VSCode Remote - SSH or WSL."
        export VSCODE_CONFIG_FILE="$HOME/.vscode-server/data/Machine/settings.json"
    else
        # https://code.visualstudio.com/docs/configure/settings
        #   Windows %APPDATA%\Code\User\settings.json
        #   macOS $HOME/Library/Application\ Support/Code/User/settings.json
        #   Linux $HOME/.config/Code/User/settings.json
        export VSCODE_CONFIG_FILE="$HOME/.config/Code/User/settings.json"
    fi
}

vscode_settings_configure() {
    merge_json_file "${_CURRENT_FILE_DIR}/pool/settings/gemini-cli/vscode-settings.json" "$VSCODE_CONFIG_FILE"

    # add env:PATH
    vscode_settings_add_path '${env:PATH}' "POSTPEND_IF_NOT_EXISTS"
    # gemini cli path
    vscode_settings_add_path "$(command -v gemini | xargs dirname)" "ALWAYS_PREPEND"
}

vscode_settings_remove() {
    # remove gemini cli path
    vscode_settings_remove_path "$(command -v gemini | xargs dirname)"
}

vscode_settings_set_path() {
    vscode_settings_file="$1"
    path_expression="$2"
    # ALWAYS_PREPEND add path or move it at the beginning position
    # ALWAYS_POSTPEND add path or move it at the end position
    # PREPEND_IF_NOT_EXISTS add path at the beginning position only if not already present
    # POSTPEND_IF_NOT_EXISTS add path at the end position only if not already present
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
        gsub("\\$\\{env:(?<var>[^}]+)\\}"; "${env\u0001" + .var + "}");

    # restore ":"
    def unshield:
        gsub("\u0001"; ":");

    # split by ":" but keep ${...} together
    def split_keep_vars:
        ( . | shield | split(":") | map(unshield) );
    
    def process:
        if $mode != "REMOVE" then
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
                    if (index($set_path) == null) then
                        ( split_keep_vars
                            | map(select(. != "" and . != $set_path))
                            | [$set_path] + .
                            | join(":")
                        )
                    end
                elif $mode == "POSTPEND_IF_NOT_EXISTS" then
                    if (index($set_path) == null) then
                        ( split_keep_vars
                            | map(select(. != "" and . != $set_path))
                            | . + [$set_path]
                            | join(":")
                        )
                    end
                end
            end
        else
            if (index($set_path) != null) then
                ( split_keep_vars
                    | map(select(. != "" and . != $set_path))
                    | join(":")
                )
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
    mv "$tmp_file" "$vscode_settings_file"
}

vscode_settings_add_path() {
    path_expression_to_add="$1"
    # ALWAYS_PREPEND add path or move it at the beginning position
    # ALWAYS_POSTPEND add path or move it at the end position
    # PREPEND_IF_NOT_EXISTS add path at the beginning position only if not already present
    # POSTPEND_IF_NOT_EXISTS add path at the end position only if not already present
    mode="${2:-ALWAYS_PREPEND}" 
    vscode_settings_set_path "$VSCODE_CONFIG_FILE" "$path_expression_to_add" "$mode"
}


vscode_settings_remove_path() {
    path_expression_to_remove="$1"
    vscode_settings_set_path "$VSCODE_CONFIG_FILE" "$path_expression_to_remove" "REMOVE"
}