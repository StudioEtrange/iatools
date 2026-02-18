


iatools_path() {
    export IATOOLS_POOL="${STELLA_APP_ROOT}/pool"
    
    export IATOOLS_LAUNCHER_HOME="${STELLA_APP_WORK_ROOT}/launcher"
    mkdir -p "${IATOOLS_LAUNCHER_HOME}"

    export IATOOLS_MCP_LAUNCHER_HOME="${IATOOLS_LAUNCHER_HOME}/mcp"
    mkdir -p "${IATOOLS_MCP_LAUNCHER_HOME}"

    export IATOOLS_ISOLATED_DEPENDENCIES_ROOT="${STELLA_APP_WORK_ROOT}/isolated_dependencies"
    mkdir -p "${IATOOLS_ISOLATED_DEPENDENCIES_ROOT}"

    gemini_path
    opencode_path
    vscode_path
    cpa_path
}


runtime_path() {
    # add launchers to current path
    export PATH="${IATOOLS_GEMINI_LAUNCHER_HOME}:${IATOOLS_OPENCODE_LAUNCHER_HOME}:${PATH}"

    # NOTE : we do not permanently add runtime paths (nodejs, python, ...)  to current system path to not override eventually existing runtime
    # used by gemini, opencode and several MCP local server
    if check_requirements "nodejs" "VERBOSE"; then
        export IATOOLS_NODEJS_BIN_PATH="${IATOOLS_ISOLATED_DEPENDENCIES_ROOT}/nodejs/bin/"
    else
        # we use an already installed nodejs, not iatools nodejs
        export IATOOLS_NODEJS_BIN_PATH=""
    fi
    
    # used by MCP local server
    if check_requirements "python" "VERBOSE"; then
        export IATOOLS_PYTHON_BIN_PATH="${IATOOLS_ISOLATED_DEPENDENCIES_ROOT}/miniforge3/bin/"
    else
        # we use an already installed python, not iatools python
        export IATOOLS_PYTHON_BIN_PATH=""
    fi

}



iatools_install_dependencies() {

    echo "- Install internal dependencies for iatools (which will be added to iatools PATH while running)"
    $STELLA_API get_feature "jq"
    $STELLA_API get_feature "yq"

    echo "- Install other dependencies (for mcp servers and other commands) in an isolated way. (None of those will never been added to any PATH)"
    for f in $STELLA_APP_FEATURE_LIST; do
        case "$f" in
            yq*|jq*|patchelf*|cliproxyapi*);;
            nodejs)
                if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
                    if [ "$STELLA_CURRENT_CPU_FAMILY" = "intel" ]; then
                        _ldd_version="$(ldd --version 2>/dev/null | awk '/ldd/{print $NF}')"
                        if [ "${_ldd_version}" = "2.17" ]; then
                            f="nodejs#23_7_0_glibc_217"
                            echo "-- detected glibc 2.17 switch to nodejs special build for it"
                        fi
                    fi
                fi
            # this notation do not stop case statement workflow and continue to next pattern without testing any match
            ;&
            *)
                _feature=""
                _feature_name=""

                $STELLA_API select_official_schema "$f" "_feature" "_feature_name"
                if [ ! "$_feature" = "" ]; then
                    echo "-- install $_feature"
                    mkdir -p "${IATOOLS_ISOLATED_DEPENDENCIES_ROOT}/${_feature_name}"
                    $STELLA_API feature_install "$f" "EXPORT ${IATOOLS_ISOLATED_DEPENDENCIES_ROOT}/${_feature_name}"
                else
                    echo "!! WARN : $f is not a valid feature for stella framework"
                fi
            # this notation do not stop case statement workflow and continue to next pattern by testing next pattern
            ;;&
            miniforge3)
                echo "-- install python pipx and uv package/project manager"
                ${IATOOLS_PYTHON_BIN_PATH}mamba install -y pipx uv
            ;;
        esac
    done
}


iatools_remove_dependencies() {
    # remove isolated dependencies and runtime
    rm -Rf "${IATOOLS_ISOLATED_DEPENDENCIES_ROOT}"
    # remove dependencies
    rm -Rf "${STELLA_APP_FEATURE_ROOT}"
}


iatools_init() {
    iatools_remove_dependencies
    iatools_install_dependencies
}



# add a path at PATH env variable list when a shell launch
path_register_for_shell() {
    local name="$1"
    local shell_name="$2"
    local path_to_add="$3"

    local rc_file

    local BEGIN_MARK="# >>> iatools-${name}-path >>>"
    local END_MARK="# <<< iatools-${name}-path <<<"

    [ "$shell_name" = "bash" ] && rc_file="$HOME/.bashrc"
    [ "$shell_name" = "zsh" ] && rc_file="$HOME/.zshrc"
    [ "$shell_name" = "fish" ] && rc_file="$HOME/.config/fish/config.fish"

    case "$shell_name" in
        "bash"|"zsh")
            [ -f "$rc_file" ] && path_unregister_for_shell "$name" "$shell_name" || touch "$rc_file"
            if ! grep -Fq "$BEGIN_MARK" "$rc_file"; then
                {
                    echo "$BEGIN_MARK"
                    echo "export PATH=\"${path_to_add}:\$PATH\""
                    echo "$END_MARK"
                } >> "$rc_file"
            fi
            ;;
        "fish")
            mkdir -p "$(dirname "$rc_file")"
            [ -f "$rc_file" ] && path_unregister_for_shell "$name" "$shell_name" || touch "$rc_file"
            if ! grep -Fq "$BEGIN_MARK" "$rc_file"; then
                {
                    echo "$BEGIN_MARK"
                    echo "set -gx PATH \"${path_to_add}\" \$PATH"
                    echo "$END_MARK"
                } >> "$rc_file"
            fi
            ;;
         *) 
            echo "error : unsupported shell $shell_name"
            ;;
    esac

}

# remove path
# use 'all' shell_name to unregister to all known shell
path_unregister_for_shell() {
    local name="$1"
    local shell_name="$2"
    local rc_file

    local BEGIN_MARK="# >>> iatools-${name}-path >>>"
    local END_MARK="# <<< iatools-${name}-path <<<"

    local shell_list
    [ "$shell_name" = "all" ] && shell_list="bash zsh fish" || shell_list="$shell_name"

    for s in $shell_list; do
        [ "$s" = "bash" ] && rc_file="$HOME/.bashrc"
        [ "$s" = "zsh" ] && rc_file="$HOME/.zshrc"
        [ "$s" = "fish" ] && rc_file="$HOME/.config/fish/config.fish"

        case "$s" in
            "bash"|"zsh"|"fish")
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

# check availability
check_requirements() {
    feature="$1"
    mode="$2"
    [ "$mode" = "" ] && mode="SILENT"
    case "$feature" in
        "yq")
            if command -v yq >/dev/null 2>&1; then
                [ "$mode" = "VERBOSE" ] && echo "-- yq detected in $(command -v yq)"
                return 0
            else
                return 1
            fi
            ;;
        "jq")
            if command -v jq >/dev/null 2>&1; then
                [ "$mode" = "VERBOSE" ] && echo "-- jq detected in $(command -v jq)"
                return 0
            else
                return 1
            fi
            ;;
        "nodejs") 
            if [ -f "${IATOOLS_ISOLATED_DEPENDENCIES_ROOT}/nodejs/bin/node" ]; then
                [ "$mode" = "VERBOSE" ] && echo "-- nodejs detected in ${IATOOLS_ISOLATED_DEPENDENCIES_ROOT}/nodejs/bin/node"
                return 0
            else
                if command -v node >/dev/null 2>&1; then
                    [ "$mode" = "VERBOSE" ] && echo "-- nodejs detected in $(command -v node)"
                    return 0
                fi
            fi
            return 1
            ;;
        
        "python")
            if [ -f "${IATOOLS_ISOLATED_DEPENDENCIES_ROOT}/miniforge3/bin/python" ]; then
                [ "$mode" = "VERBOSE" ] && echo "-- python detected in ${IATOOLS_ISOLATED_DEPENDENCIES_ROOT}/miniforge3/bin/python"
                return 0
            else
                if command -v python >/dev/null 2>&1; then
                    [ "$mode" = "VERBOSE" ] && echo "-- python detected in $(command -v python)"
                    return 0
                fi
            fi
            return 1
            ;;
        *)
            ;;
    esac
}

require() {
    local feature="$1"

    case "$feature" in
        "json5")
            if ! PATH="${IATOOLS_NODEJS_BIN_PATH}:${PATH}" type json5 >/dev/null 2>&1; then
                # install json5 nodejs package (to correct invalid json)
                # https://github.com/json5/json5
                PATH="${IATOOLS_NODEJS_BIN_PATH}:${PATH}" npm install -g json5 1>/dev/null
                [ $? -ne 0 ] && {
                    echo "ERROR : installing json5 nodejs package"
                    return 1
                }
            fi
            ;;
        *)
            echo "ERROR : unknown require $feature"
            return 1
            ;;
    esac
}


process_kill_by_port() {
    local port="$1"
    local pid

    if command -v lsof >/dev/null 2>&1; then
        pid=$(lsof -t -i:"$port" 2>/dev/null)
        if $? -ne 0; then
            pid=""
        fi
    fi
    if [ "$pid" = "" ]; then
        if command -v netstat >/dev/null 2>&1; then
            # WARN to get PID or process name with netstat, we need to be root user
            pid=$(netstat -ltnp 2>/dev/null | awk -v port=":$port$" '$4 ~ port {split($7, a, "/"); print a[1]; exit}')
        fi
    fi

    if [ -n "$pid" ]; then
        # lsof can return multiple PIDs (as a newline-separated string), so we loop
        for p in $pid; do
            echo "Killing process on port $port with PID $p"
            kill -9 "$p"
        done
    else
        echo "Error: lsof nor netstat able to find process."
        return 1
    fi
}