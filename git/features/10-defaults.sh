FEATURE_NAME="Defaults"
FEATURE_DESC="main as default branch, submodule-aware status/diff/push, ignore file-mode changes"

source "$GROUP_DIR/features/_include.sh"
apply() { git_include defaults "$GROUP_DIR/files/defaults.gitconfig"; }
