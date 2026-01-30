


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

    echo "- Install other dependencies (for mcp servers and other commands) in an isolated way. (None of those will never been added to any PATH)"
    for f in $STELLA_APP_FEATURE_LIST; do
        case "$f" in
            jq*|patchelf*);;
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

# check availability
check_requirements() {
    feature="$1"
    mode="$2"
    [ "$mode" = "" ] && mode="SILENT"
    case "$feature" in
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
    feature="$1"

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

    esac
}
