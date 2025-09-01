

merge_json_file() {
    file_to_merge="$1"
    target_file="$2"

    if [ ! -f "$file_to_merge" ]; then
        echo "Error: file to merge not found $file_to_merge"
        exit 1
    fi

    if [ ! -s "$target_file" ]; then
        echo "Valid target file not found at $target_file. Creating it."
        mkdir -p "$(dirname "$target_file")"
        echo "{}" > "$target_file"
    fi

    tmp_file=$(mktemp)
    tmp_merge=$(mktemp)

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
        echo "Error: expanding environment variables in $file_to_merge" >&2
        rm -f "$tmp_file" "$tmp_merge"
        exit 1
    fi


    # Merge the two json files
    jq -s '.[0] * .[1]' "$target_file" "$tmp_merge" > "$tmp_file"
    
    if [ $? -ne 0 ]; then
        echo "Error processing with jq"
        rm -f "$tmp_file"
        exit 1
    else
        mv "$tmp_file" "$target_file"
    fi
}


json_remove_key() {
    key_path="$1"
    target_file="$2"

    if [ -z "$key_path" ]; then
        echo "Error: json key path to remove empty"
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

    tmp_file=$(mktemp)

    jq "del(.${key_path})" "$target_file" > "$tmp_file"

    if [ $? -ne 0 ]; then
        echo "Error processing with jq"
        rm -f "$tmp_file"
        exit 1
    else
        mv "$tmp_file" "$target_file"
    fi
}