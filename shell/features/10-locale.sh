FEATURE_NAME="Locale"
FEATURE_DESC="Exports LANG=en_US.UTF-8"

apply() {
    locale -a 2>/dev/null | grep -qiE '^en_US\.utf-?8$' \
        || warn "en_US.UTF-8 is not generated; enable it in /etc/locale.gen and run locale-gen"
    bashrc_d_install 10-locale "$GROUP_DIR/files/locale.sh"
}
