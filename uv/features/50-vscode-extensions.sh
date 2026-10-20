FEATURE_NAME="VS Code extensions"
FEATURE_DESC="Installs $(grep -c . "$GROUP_DIR/files/vscode-extensions.txt" 2>/dev/null) extensions (Python, ruff, Jupyter, Go, Rust, Docker, Remote-SSH, ...); revert removes only those it added"

source "$GROUP_DIR/features/_vscode.sh"

apply() {
    need_cmd "$VSCODE_BIN"
    local have id failed=0
    have="$("$VSCODE_BIN" --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]')"
    while read -r id; do
        [[ -z "$id" || "$id" == \#* ]] && continue
        if grep -qxF "${id,,}" <<< "$have"; then continue; fi
        if "$VSCODE_BIN" --install-extension "$id" >/dev/null 2>&1; then
            undo_once "ext:$id" "$VSCODE_BIN" --uninstall-extension "$id"
            ok "$id"
        else
            warn "could not install $id (not on this marketplace?)"; failed=1
        fi
    done < "$GROUP_DIR/files/vscode-extensions.txt"
    ok "extensions up to date"
    return $failed
}
