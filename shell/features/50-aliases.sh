FEATURE_NAME="Aliases"
FEATURE_DESC="Colored ls/grep/diff, ll, df1, pz shortcuts, and 'act' to activate the nearest .venv"

apply() {
    bashrc_d_install 50-aliases "$GROUP_DIR/files/aliases.sh"
}
