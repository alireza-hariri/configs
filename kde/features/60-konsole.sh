FEATURE_NAME="Konsole profile"
FEATURE_DESC="'Configs' profile with Hack 11 font, set as Konsole's default"

apply() {
    fc-list 2>/dev/null | grep -qi 'Hack' || warn "Hack font not found (pacman -S ttf-hack)"
    put_file "$GROUP_DIR/files/konsole.profile" "${XDG_DATA_HOME:-$HOME/.local/share}/konsole/Configs.profile"
    kset konsolerc "Desktop Entry" DefaultProfile Configs.profile
    ok "new Konsole windows use the 'Configs' profile"
}
