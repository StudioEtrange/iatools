#!/bin/sh
# patch VS Code server interpreter/rpath with patchelf

set -eu

# --- Config ---
# NOTE : there also might be ${HOME}/.vscode-server-insiders"
VSCODE_SERVER_ROOT="${HOME}/.vscode-server"
VSCODE_SERVER_PATCH_ROOT="${VSCODE_SERVER_ROOT}-patch"
EXPECTED_INTERPRETER="${VSCODE_SERVER_CUSTOM_GLIBC_LINKER:-/opt/custom-glibc228-runtime/lib/ld-linux-x86-64.so.2}"
EXPECTED_RPATH="${VSCODE_SERVER_CUSTOM_GLIBC_PATH:-/opt/custom-glibc228-runtime/lib:/opt/custom-glibc228-runtime/rtlib}"


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

if [ ! -d "${VSCODE_SERVER_ROOT}" ]; then
    echo "VS Code server home do not exist, vs code server might not be installed" >&2
    exit 0
fi

# LOCK for multiple remote ssh connection
LOCK_DIR="${VSCODE_SERVER_PATCH_ROOT}/vscode-server-patch.lock.d"
mkdir -p "$VSCODE_SERVER_PATCH_ROOT"
# purge old lock (>1 day)
[ -d "$LOCK_DIR" ] && find "$LOCK_DIR" -maxdepth 0 -mtime +0 -exec rm -rf {} \; 2>/dev/null || true
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
    exit 0
fi
trap 'rm -rf "$LOCK_DIR" 2>/dev/null || true' EXIT INT HUP TERM QUIT PIPE

# install patchelf
PATCHELF="$VSCODE_SERVER_PATCH_ROOT/patchelf/bin/patchelf"
PATH="$VSCODE_SERVER_PATCH_ROOT/patchelf/bin:$PATH"
if [ -x "$PATCHELF" ]; then
    echo "patchelf is already installed."
else
    mkdir -p "$VSCODE_SERVER_PATCH_ROOT/patchelf"
    cd "$VSCODE_SERVER_PATCH_ROOT/patchelf"
    wget --no-check-certificate "https://github.com/NixOS/patchelf/releases/download/0.18.0/patchelf-0.18.0-x86_64.tar.gz" || exit 0
    tar -zxvf "patchelf-0.18.0-x86_64.tar.gz" 1>/dev/null || exit 0
    rm -f "patchelf-0.18.0-x86_64.tar.gz"
fi
# check patchelf exists and is executable
if ! command -v "patchelf" >/dev/null 2>&1; then
    echo "ERROR: patchelf not found" >&2
    exit 0
fi

echo "disable vs code server requirements check"
touch /tmp/vscode-skip-server-requirements-check

# check expected interpreter exists
if [ ! -f "${EXPECTED_INTERPRETER}" ]; then
    echo "ERROR: expected interpreter not found: ${EXPECTED_INTERPRETER}" >&2
    exit 0
fi

# find node binary
find "$VSCODE_SERVER_ROOT" -type f -executable -size +0c -name node -print0 |
while IFS= read -r -d '' f; do
    commit_dir="$(dirname "$f")"
    stamp="$commit_dir/.patched"
    # already patched
    [ -f "$stamp" ] && continue
    if patch "$f"; then
        touch "$stamp" 2>/dev/null || true
    fi
done


exit 0

