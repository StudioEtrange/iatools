




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
                [ "$mode" = "VERBOSE" ] && echo "-- python detected in ${IATOOLS_ISOLATED_DEPENDENCIES_ROOT}/mambaforge/bin/python"
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
                PATH="${IATOOLS_NODEJS_BIN_PATH}:${PATH}" npm install -g json5
            fi
            ;;

    esac
}

iatools_remove_dependencies() {
    # remove isolated dependencies and runtime
    rm -Rf "${IATOOLS_ISOLATED_DEPENDENCIES_ROOT}"
    # remove dependencies
    rm -Rf "${STELLA_APP_FEATURE_ROOT}"
}

merge_json_file() {
    file_to_merge="$1"
    target_file="$2"

    if [ ! -f "$file_to_merge" ]; then
        echo "ERROR : file to merge not found $file_to_merge"
        exit 1
    fi

    test_and_fix_json_file "$file_to_merge"

    if [ ! -s "$target_file" ]; then
        echo "Valid target file not found at $target_file. Creating it."
        mkdir -p "$(dirname "$target_file")"
        echo "{}" > "$target_file"
    fi

    test_and_fix_json_file "$target_file"

    local tmp_merge="$(mktemp)"
    # Replace ${VAR} with environnement variable if it exists or keep ${VAR} as is 
    # if VAR exists but empty, ${VAR} is replaced with an empty string
    if ! jq \
            'def expand_env:
                walk(
                    if type=="string" then
                        gsub("\\$\\{(?<k>[A-Za-z_][A-Za-z0-9_]*)\\}"; (env[.k] // ("${"+.k+"}")))
                    else 
                        . 
                    end
                    );
            expand_env
    ' "$file_to_merge" > "$tmp_merge"; then
        echo "ERROR : expanding environment variables in $file_to_merge" >&2
        exit 1
    fi

    test_and_fix_json_file "$tmp_merge"

    local tmp_file="$(mktemp)"
    # Merge the two json files
    jq -s '.[0] * .[1]' "${target_file}" "$tmp_merge" > "$tmp_file"
    
    if [ $? -ne 0 ]; then
        rm -f "$tmp_file" "$tmp_merge"
        exit 1
    else
        mv "$tmp_file" "$target_file"
        rm -f "$tmp_file" "$tmp_merge"
    fi
}


json_remove_key() {
    key_path="$1"
    target_file="$2"

    if [ -z "$key_path" ]; then
        echo "ERROR : json key path to remove empty"
        exit 1
    fi

    if [ ! -s "$target_file" ]; then
        echo "WARN : file not found $target_file" >&2
        return
    fi

    if ! jq -e ".${key_path}" "$target_file" >/dev/null 2>&1; then
        # key not found
        return
    fi

    local tmp_file="$(mktemp)"

    jq "del(.${key_path})" "$target_file" > "$tmp_file"

    if [ $? -ne 0 ]; then
        echo "ERROR : processing with jq"
        rm -f "$tmp_file"
        exit 1
    else
        mv "$tmp_file" "$target_file"
        rm -f "$tmp_file"
    fi
}

# format and fix invalid json (i.e: remove last comma at the end of a json object)
# can be used in a stream :
#       echo '{ "to" :"",}' | sanitize_json
#       sanitize_json - < file.json 
# or if a file is passed as argument 1, the file will be sanitize itself
#       sanitize_json "file.json"
#
# json5 options
#   -s : size of indentation
#   -c : convert inplace without making output file https://github.com/json5/json5/blob/main/lib/cli.js#L87
sanitize_json() {
    file="$1"

    require "json5"
    
    if [ -n "$file" ] && [ "$file" != "-" ]; then
        if [ ! -f "$file" ]; then
            echo "ERROR : file not found: $file"
            return 1
        fi

        local tmp_file="$(mktemp)"

        PATH="${IATOOLS_NODEJS_BIN_PATH}:${PATH}" json5 -s 2 "$file" 2>/dev/null >"$tmp_file" 
        if [ $? -ne 0 ]; then
            echo "ERROR : failed to sanitize json from $file"
            rm -f "$tmp_file"
            return 1
        else
            mv "$tmp_file" "$file"
            return 0
        fi
    fi

    # parse sream
    PATH="${IATOOLS_NODEJS_BIN_PATH}:${PATH}" json5 -s 2
}

test_and_fix_json_file() {
    file_to_test="$1"

    if [ ! -f "$file_to_test" ]; then
        echo "ERROR : file not found $file_to_test"
        exit 1
    fi

    if ! jq -e . "$file_to_test" >/dev/null 2>&1; then
        echo "WARN : invalid json file : $file_to_test"
        echo "       try to sanitize it"
        sanitize_json "$file_to_test"
        if ! jq -e . "$file_to_test" >/dev/null 2>&1; then
            echo "ERROR : invalid json file : $file_to_test"
            exit 1
        else
        echo "       it should be a valid json file now"
        fi
    fi

}
