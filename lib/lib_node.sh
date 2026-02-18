
nvm_install() {

    NVM_DIR="path/to/nvm" PROFILE=/dev/null curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
}



nvm_register_for_shell() {
    local shell_name="$1"

    local name="nvm"
    local rc_file

    local BEGIN_MARK="# >>> iatools-${name}-register >>>"
    local END_MARK="# <<< iatools-${name}-register <<<"

    [ "$shell_name" = "bash" ] && rc_file="$HOME/.bashrc"
    [ "$shell_name" = "zsh" ] && rc_file="$HOME/.zshrc"

    case "$shell_name" in
        "bash"|"zsh")
            [ -f "$rc_file" ] && path_unregister_for_shell "$name" "$shell_name" || touch "$rc_file"
            if ! grep -Fq "$BEGIN_MARK" "$rc_file"; then
                {
                    echo "$BEGIN_MARK"
                    echo "# --no-use This loads nvm, without auto-using the default version"
                    echo 'export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"'
                    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use'
                    echo "$END_MARK"
                } >> "$rc_file"
            fi
            ;;
        *) 
            echo "error : unsupported shell $shell_name"
            ;;
    esac
}



# use 'all' shell_name to unregister to all known shell
nvm_unregister_for_shell() {
    local name="$1"
    local shell_name="$2"
    local rc_file

    local BEGIN_MARK="# >>> iatools-${name}-register >>>"
    local END_MARK="# <<< iatools-${name}-register <<<"

    local shell_list
    [ "$shell_name" = "all" ] && shell_list="bash zsh" || shell_list="$shell_name"

    for s in $shell_list; do
        [ "$s" = "bash" ] && rc_file="$HOME/.bashrc"
        [ "$s" = "zsh" ] && rc_file="$HOME/.zshrc"
        [ "$s" = "fish" ] && rc_file="$HOME/.config/fish/config.fish"

        case "$s" in
            "bash"|"zsh")
                if [ -f "$rc_file" ]; then
                    local tmp_file="$(mktemp)"
                    awk -v begin="$BEGIN_MARK" -v end="$END_MARK" ' 
                        $0 == begin { skip=1; next } 
                        $0 == end { skip=0; next } !skip 
                    ' "$rc_file" > "$tmp_file" && mv "$tmp_file" "$rc_file"
                    rm -f "$tmp_file"
                fi
                ;;
            *) 
                echo "error : unsupported shell : $s"
                ;;
        esac
    done
}