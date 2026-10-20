FEATURE_NAME="VS Code settings"
FEATURE_DESC="Merges ~54 settings (ruff, autosave, zoom, terminal, Copilot off, spell words, ...) into settings.json"

source "$GROUP_DIR/features/_vscode.sh"
TARGET="$VSCODE_USER/settings.json"

apply() {
    need_cmd python3
    vscode_backup "$TARGET"
    vscode_json merge-settings "$TARGET" "$GROUP_DIR/files/vscode-settings.json"
}

revert() {
    vscode_json revert-settings "$TARGET" "$GROUP_DIR/files/vscode-settings.json"
}
