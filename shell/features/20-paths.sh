FEATURE_NAME="PATH entries"
FEATURE_DESC="Adds ~/.local/bin, ~/.npm-global/bin, Go and the Orca CLI shim to PATH, once each and only if they exist"

apply() {
    bashrc_d_install 20-paths "$GROUP_DIR/files/paths.sh"
}
