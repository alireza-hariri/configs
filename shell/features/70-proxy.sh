FEATURE_NAME="Proxy toggle"
FEATURE_DESC="proxy [on ADDR|off|status]: sets http(s)/ftp/all_proxy, remembers the address in ~/.proxyaddr"

apply() {
    bashrc_d_install 70-proxy "$GROUP_DIR/files/proxy.sh"
}
