#!/bin/sh
# patch a binary interpreter/rpath with patchelf

set -eu

# --- Config ---

BINARY_TO_PATCH="${1:-}"
FOLDER_TO_PATCH_ROOT="${2:-}"

EXPECTED_INTERPRETER="${CUSTOM_GLIBC_LINKER:-/opt/custom-glibc228-runtime/lib/ld-linux-x86-64.so.2}"
EXPECTED_RPATH="${CUSTOM_GLIBC_PATH:-/opt/custom-glibc228-runtime/lib:/opt/custom-glibc228-runtime/rtlib}"

PATCH_WORKSPACE="$HOME/.patch-workspace/$(basename "${FOLDER_TO_PATCH_ROOT}")"

if [ -z "$BINARY_TO_PATCH" ]; then
    echo "missing first argument : binary name to patch"
    exit 0
fi

if [ -z "$FOLDER_TO_PATCH_ROOT" ]; then
    echo "missing second argument : folder where to find binary to patch"
    exit 0
fi

print_info() {
    f="$1"
    echo "Current interpreter : $("${PATCHELF}" --print-interpreter "${f}" 2>/dev/null || true)"
    echo "Current rpath : $( "${PATCHELF}" --print-rpath "${f}" 2>/dev/null || true)"
}

patch() {
    f="$1"
    [ -f "${f}" ] || return 0
        
    echo "----------------------------"
    echo "Analyse file : ${f}"
    print_info "${f}"

    interpreter="$("${PATCHELF}" --print-interpreter "${f}" 2>/dev/null || true)"
    if [ "${interpreter}" != "${EXPECTED_INTERPRETER}" ]; then
        # Apply rpath then interpreter

        # force legacy RPATH instead of RUNPATH because RUNPATH is not reliably used to resolve transitive dependencies loaded via dlopen() 
        # (e.g., native modules like node-pty) 
        if "${PATCHELF}" --force-rpath --set-rpath "${EXPECTED_RPATH}" "${f}" 2>/dev/null && \
            "${PATCHELF}" --set-interpreter "${EXPECTED_INTERPRETER}" "${f}" 2>/dev/null; then
            
            echo "Patch applied on ${f}"
            print_info "${f}"
        else
            echo "ERROR: failed to patch: ${f}" >&2
            print_info "${f}"
            return 1
        fi
    fi
    echo "----------------------------"
    return 0
}

if [ ! -d "${FOLDER_TO_PATCH_ROOT}" ]; then
    echo "VS Code server home do not exist, vs code server might not be installed" >&2
    exit 0
fi

# LOCK for multiple remote ssh connection
LOCK_DIR="${PATCH_WORKSPACE}/vscode-server-patch.lock.d"
mkdir -p "$PATCH_WORKSPACE"
# purge old lock (>1 day)
[ -d "$LOCK_DIR" ] && find "$LOCK_DIR" -maxdepth 0 -mtime +0 -exec rm -rf {} \; 2>/dev/null || true
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
    exit 0
fi
trap 'rm -rf "$LOCK_DIR" 2>/dev/null || true' EXIT INT HUP TERM QUIT PIPE

# install patchelf
PATCHELF="$PATCH_WORKSPACE/patchelf/bin/patchelf"
PATH="$PATCH_WORKSPACE/patchelf/bin:$PATH"
if [ -x "$PATCHELF" ]; then
    echo "patchelf is already installed."
else
    mkdir -p "$PATCH_WORKSPACE/patchelf"
    cd "$PATCH_WORKSPACE/patchelf"
    wget --no-check-certificate "https://github.com/NixOS/patchelf/releases/download/0.18.0/patchelf-0.18.0-x86_64.tar.gz" || exit 0
    tar -zxvf "patchelf-0.18.0-x86_64.tar.gz" 1>/dev/null || exit 0
    rm -f "patchelf-0.18.0-x86_64.tar.gz"
fi
# check patchelf exists and is executable
if ! command -v "patchelf" >/dev/null 2>&1; then
    echo "ERROR: patchelf not found" >&2
    exit 0
fi

# check expected interpreter exists
if [ ! -f "${EXPECTED_INTERPRETER}" ]; then
    echo "ERROR: expected interpreter not found: ${EXPECTED_INTERPRETER}" >&2
    exit 0
fi

# find binary
echo "try to find $BINARY_TO_PATCH in $FOLDER_TO_PATCH_ROOT"

find "$FOLDER_TO_PATCH_ROOT" -type f -executable -size +0c -name "$BINARY_TO_PATCH" -print0 L
while IFS= read -r -d '' f; do
    echo "found $f"
    commit_dir="$(dirname "$f")"
    stamp="$commit_dir/.patched"
    # already patched
    [ -f "$stamp" ] && continue
    if patch "$f"; then
        touch "$stamp" 2>/dev/null || true
    fi
done


exit 0

