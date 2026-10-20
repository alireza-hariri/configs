FEATURE_NAME="VS Code keybindings"
FEATURE_DESC="F5 runs the 'uv_run' task, Shift+F5 starts the debugger"

source "$GROUP_DIR/features/_vscode.sh"
TARGET="$VSCODE_USER/keybindings.json"

apply() {
    need_cmd python3
    vscode_backup "$TARGET"
    vscode_json merge-keys "$TARGET" "$GROUP_DIR/files/vscode-keybindings.json"
}

revert() {
    vscode_json revert-keys "$TARGET" "$GROUP_DIR/files/vscode-keybindings.json"
    # Created by apply and now empty: remove it again.
    if [[ ! -f "$FEATURE_STATE/keybindings.json.orig" ]] && [[ "$(tr -d '[:space:]' < "$TARGET")" == "[]" ]]; then
        rm -f "$TARGET"
    fi
}
