FEATURE_NAME="Identity"
FEATURE_DESC="user.name / user.email, asked at install time (defaults: current values)"

source "$GROUP_DIR/features/_include.sh"
apply() {
    local name email tmp
    name="$(ask "Git user name" "$(git config --global user.name || echo a.hariri)")"
    email="$(ask "Git email" "$(git config --global user.email || echo alireza.hariri@ut.ac.ir)")"
    [[ -n "$name" && -n "$email" ]] || die "name and email are both needed"
    tmp="$(mktemp)"
    printf '# Managed by configs/git (identity). Included from ~/.gitconfig.\n[user]\n\tname = %s\n\temail = %s\n' \
        "$name" "$email" > "$tmp"
    git_include identity "$tmp"
    rm -f "$tmp"
}
