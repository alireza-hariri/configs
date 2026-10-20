FEATURE_NAME="Misc tools"
FEATURE_DESC="greptree (matching files as a tree), find-heavy-dirs.sh, create-desktop.py (app launchers)"

source "$GROUP_DIR/features/_bin.sh"
apply() {
    command -v rg >/dev/null && command -v tree >/dev/null || warn "greptree needs ripgrep and tree"
    bin_install greptree find-heavy-dirs.sh create-desktop.py
}
