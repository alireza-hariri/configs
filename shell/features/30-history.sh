FEATURE_NAME="Shared history"
FEATURE_DESC="100k/500k lines, timestamps, no duplicates, shared live between open terminals"

apply() {
    bashrc_d_install 30-history "$GROUP_DIR/files/history.sh"
}
