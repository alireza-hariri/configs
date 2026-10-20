FEATURE_NAME="uv tools"
FEATURE_DESC="CLI tools via 'uv tool install': ruff, jupytext, notebook, poe, hf, cookiecutter, git-filter-repo, specify, ..."

source "$GROUP_DIR/features/_uv.sh"

apply() {
    ensure_uv
    local installed name src failed=0
    installed="$(uv tool list 2>/dev/null | awk '!/^-/ {print $1}')"
    while read -r name src; do
        [[ -z "$name" || "$name" == \#* ]] && continue
        if grep -qxF "$name" <<< "$installed"; then
            ok "$name (already installed)"
            continue
        fi
        if uv tool install --quiet "${src:-$name}"; then
            undo_once "tool:$name" uv tool uninstall "$name"
            ok "$name"
        else
            warn "could not install $name"; failed=1
        fi
    done < "$GROUP_DIR/files/uv-tools.txt"
    return $failed
}
