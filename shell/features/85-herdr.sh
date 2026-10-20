FEATURE_NAME="herdr completion"
FEATURE_DESC="Bash completion for herdr, cached and refreshed when herdr updates"

apply() {
    bashrc_d_install 85-herdr "$GROUP_DIR/files/herdr.sh"
}
