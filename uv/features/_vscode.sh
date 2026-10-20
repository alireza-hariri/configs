# Shared by the vscode features.
VSCODE_USER="${VSCODE_USER_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/Code/User}"
VSCODE_BIN="${VSCODE_BIN:-code}"

vscode_json() {  # vscode_json merge-settings|revert-settings|merge-keys|revert-keys TARGET SRC
    python3 "$GROUP_DIR/files/vscode_json.py" "$1" "$2" "$3" "$FEATURE_STATE/${2##*/}.state.json"
}

# Backup of the whole file before the first merge, for manual recovery.
vscode_backup() {
    mkdir -p "$FEATURE_STATE"
    [[ -f "$1" && ! -f "$FEATURE_STATE/${1##*/}.orig" ]] && cp -a "$1" "$FEATURE_STATE/${1##*/}.orig"
    return 0
}
