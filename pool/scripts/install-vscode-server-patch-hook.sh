#!/bin/sh
# install patch VS Code server mechanism
set -eu

# --- Config ---
VSCODE_SERVER_ROOT="${HOME}/.vscode-server"
VSCODE_SERVER_PATCH_ROOT="${VSCODE_SERVER_ROOT}-patch"
EXPECTED_INTERPRETER="${VSCODE_SERVER_CUSTOM_GLIBC_LINKER:-/opt/custom-glibc228-runtime/lib/ld-linux-x86-64.so.2}"
EXPECTED_RPATH="${VSCODE_SERVER_CUSTOM_GLIBC_PATH:-/opt/custom-glibc228-runtime/lib:/opt/custom-glibc228-runtime/rtlib}"
SCRIPT_FOLDER="$(cd -- "$(dirname -- "$0")" && pwd)"

ACTION="${1:-install}"

BEGIN_MARK="# >>> vscode-server-patch >>>"
END_MARK="# <<< vscode-server-patch <<<"
		
SSH_RC="$HOME/.ssh/rc"

install_patchelf() {
	echo "install patchelf"
	mkdir -p "$VSCODE_SERVER_PATCH_ROOT/patchelf"
	cd "$VSCODE_SERVER_PATCH_ROOT/patchelf"
	rm -f "patchelf-0.18.0-x86_64.tar.gz"
	wget --no-check-certificate "https://github.com/NixOS/patchelf/releases/download/0.18.0/patchelf-0.18.0-x86_64.tar.gz" || return 1
	tar -zxvf "patchelf-0.18.0-x86_64.tar.gz" 1>/dev/null || return 1
	rm -f "patchelf-0.18.0-x86_64.tar.gz"
}



case "$ACTION" in
	"install")
		# install patchelf
		PATCHELF="$VSCODE_SERVER_PATCH_ROOT/patchelf/bin/patchelf"
		PATH="$VSCODE_SERVER_PATCH_ROOT/patchelf/bin:$PATH"
		if [ -x "$PATCHELF" ]; then
    			echo "patchelf is already installed"
		else
			if ! install_patchelf; then
				echo "ERROR: error on patchelf install" >&2
				exit 1
			fi
		fi
		# check patchelf exists and is executable
		if ! command -v "patchelf" >/dev/null 2>&1; then
    			echo "ERROR: patchelf not found" >&2
    			exit 1
		fi

		echo "disable vs code server requirements check"
		touch /tmp/vscode-skip-server-requirements-check

		echo "install vs code patch system hook in $HOME/.ssh/rc file"
		[ -d "$HOME/.ssh" ] || { mkdir -p "$HOME/.ssh"; chmod 700 "$HOME/.ssh"; }
		[ -f "$SSH_RC" ] || { touch "$SSH_RC"; chmod 600 "$SSH_RC"; }
		if ! grep -Fq "$BEGIN_MARK" "$SSH_RC"; then
    		{
				echo "$BEGIN_MARK"
				echo "mkdir -p \"$VSCODE_SERVER_PATCH_ROOT\" 1>/dev/null 2>&1 || true"
				echo "\"$SCRIPT_FOLDER/vscode-server-patch.sh\" 1>\"$VSCODE_SERVER_PATCH_ROOT/patch.log\" 2>&1 || true"
				echo "$END_MARK" 
			} >> "$SSH_RC"
		fi

		echo "installation done"
		;;

	"uninstall")
		rm -f /tmp/vscode-skip-server-requirements-check

		if [ -f "$SSH_RC" ]; then
			tmp_file="$(mktemp)"
			awk -v begin="$BEGIN_MARK" -v end="$END_MARK" ' 
				$0 == begin { skip=1; next } 
				$0 == end { skip=0; next } !skip 
			' "$SSH_RC" > "$tmp_file" && mv "$tmp_file" "$SSH_RC"
			rm -f "$tmp_file"
		fi
		
		echo "uninstallation done"
		;;	
	*) 
		echo "Usage :"
		echo "$0 install|uninstall"	
		;;

esac


exit 0

