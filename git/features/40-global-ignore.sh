FEATURE_NAME="Global ignore"
FEATURE_DESC="Placeholder ~/.config/git/ignore for patterns ignored in every repo; add yours there"

apply() {
    local file excludes
    excludes="$(git config --global core.excludesFile || true)"
    file="${excludes:-${XDG_CONFIG_HOME:-$HOME/.config}/git/ignore}"
    file="${file/#\~/$HOME}"
    seed_text "$file" <"$GROUP_DIR/files/ignore"
    ok "add your global ignore patterns to: $file"
}

# Nothing to undo: the file is yours and is kept.
revert() { ok "kept your global ignore file"; }
