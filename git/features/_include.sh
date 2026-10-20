# Shared by the git features: add a file to ~/.gitconfig with [include].
git_include() {
    local name="$1" src="$2"
    local dest="${XDG_CONFIG_HOME:-$HOME/.config}/git/configs/$name.gitconfig"
    need_cmd git
    put_file "$src" "$dest"
    if ! git config --global --get-all include.path 2>/dev/null | grep -qxF "$dest"; then
        git config --global --add include.path "$dest"
    fi
    undo_once "include:$dest" _undo_git_include "$dest"
    ok "included $dest from ~/.gitconfig"
}

_undo_git_include() {
    git config --global --fixed-value --unset-all include.path "$1" 2>/dev/null || true
    ok "removed include of $1"
}
