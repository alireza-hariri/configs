FEATURE_NAME="nvm (lazy)"
FEATURE_DESC="Default Node on PATH instantly, nvm itself loads on first use (saves ~100ms per shell)"

apply() {
    bashrc_d_install 80-nvm "$GROUP_DIR/files/nvm.sh"
}
