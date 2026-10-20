FEATURE_NAME="Archive tools"
FEATURE_DESC="decompress.sh (any format), compress-all.sh / decompress-all.sh (every folder <-> .tar.zst)"

source "$GROUP_DIR/features/_bin.sh"
apply() {
    command -v zstd >/dev/null || warn "zstd is not installed"
    bin_install decompress.sh compress-all.sh decompress-all.sh
}
