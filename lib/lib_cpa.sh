cpa_path() {
    # iatools path for cli proxy api
    export IATOOLS_CLIPROXYAPI_CONFIG_HOME="${HOME}/.cli-proxy-api"
    mkdir -p "${IATOOLS_CLIPROXYAPI_CONFIG_HOME}"

    export IATOOLS_CLIPROXYAPI_LAUNCHER_HOME="${IATOOLS_LAUNCHER_HOME}/cli-proxy-api"
    mkdir -p "${IATOOLS_CLIPROXYAPI_LAUNCHER_HOME}"


    # cli proxy api specific paths
    export IATOOLS_CLIPROXYAPI_CONFIG_FILE="${IATOOLS_CLIPROXYAPI_CONFIG_HOME}/config.yaml"
    
}


cpa_launcher_manage() {
    $STELLA_API feature_info "cliproxyapi" "CPA"
    if [ "${CPA_TEST_FEATURE}" = "1" ]; then
        # launcher based on a symbolic link :
        # link does not exist OR is not valid
        if [ ! -L "${IATOOLS_CLIPROXYAPI_LAUNCHER_HOME}/cli-proxy-api" ] || [ ! -e "${IATOOLS_CLIPROXYAPI_LAUNCHER_HOME}/cli-proxy-api" ]; then
            echo "Create an CLIProxyAPI launcher"
            ln -fsv "${CPA_FEAT_INSTALL_ROOT}/cli-proxy-api" "${IATOOLS_CLIPROXYAPI_LAUNCHER_HOME}/cli-proxy-api"
        fi
    else
        rm -f "${IATOOLS_CLIPROXYAPI_LAUNCHER_HOME}/cli-proxy-api"
    fi
}


cpa_settings_configure() {

    $STELLA_API feature_info "cliproxyapi" "CPA"

    [ ! -f "${IATOOLS_CLIPROXYAPI_CONFIG_FILE}" ] && cp -f "$CPA_FEAT_INSTALL_ROOT/config.example.yaml" "$IATOOLS_CLIPROXYAPI_CONFIG_FILE"
    # TODO
    echo "add some default settings :"
    cpa_settings_set_host "localhost"
    cpa_settings_api_key_reset
    cpa_settings_api_key_create
    
    cpa_settings_management_api_key_reset
    cpa_settings_management_api_key_create
}

cpa_settings_remove() {
    rm -Rf "$IATOOLS_CLIPROXYAPI_CONFIG_HOME"
}


cpa_info() {
    if [ -f "$IATOOLS_CLIPROXYAPI_CONFIG_FILE" ]; then
        echo "CLIProxyAPI configuration file : $IATOOLS_CLIPROXYAPI_CONFIG_FILE"
        echo "CLIProxyAPI API Keys list :" 
        cpa_settings_api_key_list

        local tls="$(cpa_get_config ".tls.enable")"
        local scheme="http"
        [ "$tls" = "true" ] && scheme="https"
        local api_uri="${scheme}://$(cpa_get_config ".host"):$(cpa_get_config ".port")"
        echo "CLIProxyAPI API endpoint : $api_uri" 
        echo "Management UI : ${api_uri}/management.html"
    else
        echo "No CLIProxyAPI configuration file found. $IATOOLS_CLIPROXYAPI_CONFIG_FILE"
    fi
}

# generic config management -----------------
cpa_remove_config() {
    local key_path="$1"
    yaml_del_key_from_file "$IATOOLS_CLIPROXYAPI_CONFIG_FILE" "$key_path"
}

cpa_set_config() {
    local key_path="$1"
    local value="$2"
    local string_style="$3"

    case "$key_path" in
        .*) ;;
        *)  key_path=".$key_path" ;;
    esac

    yaml_set_key_into_file "$IATOOLS_CLIPROXYAPI_CONFIG_FILE" "$key_path" "$value" "$string_style"
}

cpa_get_config() {
    local key_path="$1"

    case "$key_path" in
        .*) ;;
        *)  key_path=".$key_path" ;;
    esac

    yaml_get_key_from_file "$IATOOLS_CLIPROXYAPI_CONFIG_FILE" "$key_path"
}



# host management ------------------------
cpa_settings_set_host() {
    local host="$1"
    cpa_set_config ".host" "$host" "double"
}

cpa_settings_set_port() {
    local port="$1"
    cpa_set_config ".port" "$port"
}

# remote management ------------------------
# to fully disable management api, set secret-key to empty
cpa_settings_management_api_disable() {
    cpa_settings_management_api_key_reset
}


cpa_settings_management_api_key_reset() {
    cpa_set_config ".remote-management.secret-key" "" "double"
}

cpa_settings_management_api_key_create() {
    local key="$($STELLA_API generate_password 12 "[:alnum:]")"
    cpa_settings_management_api_key_set "$key"
    echo "New management API key created : $key"
    echo "WARN : management API key is hashed in config file, so save it now"
}

cpa_settings_management_api_key_set() {
    local key="$1"
    cpa_set_config ".remote-management.secret-key" "$key" "double"
}

# API key management ------------------------
cpa_settings_api_key_reset() {
    cpa_remove_config ".api-keys"
}

cpa_settings_api_key_create() {
    local key="$($STELLA_API generate_password 48 "[:alnum:]")"
    cpa_settings_api_key_add "$key"
    echo "New API key created: $key"
}

cpa_settings_api_key_add() {
    local key="$1"

    if ! KEY="$key" yq eval -i '.["api-keys"] += [strenv(KEY)] | .["api-keys"][] style="double"' "$IATOOLS_CLIPROXYAPI_CONFIG_FILE"; then
        echo "ERROR: Failed to add API key to configuration" >&2
        return 1
    fi
}

cpa_settings_api_key_del() {
    local key="$1"

    [ -f "$IATOOLS_CLIPROXYAPI_CONFIG_FILE" ] || { echo "ERROR: file $IATOOLS_CLIPROXYAPI_CONFIG_FILE not found" >&2; return 1; }

    KEY="$key" yq eval -i '
        .["api-keys"] |= (
        (. // [])
        | map(select(. != strenv(KEY)))
        )
    ' "$IATOOLS_CLIPROXYAPI_CONFIG_FILE"
}


cpa_settings_api_key_list() {
    yaml_get_key_from_file "$IATOOLS_CLIPROXYAPI_CONFIG_FILE" ".api-keys" 
}
