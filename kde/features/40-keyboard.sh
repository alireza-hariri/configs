FEATURE_NAME="Keyboard layouts"
FEATURE_DESC="English (US) + Persian layouts (switch with Meta+Space when the shortcuts feature is on)"

reload_layouts() {
    dbus-send --session --type=signal /Layouts org.kde.keyboard.reloadConfig 2>/dev/null || true
}

apply() {
    need_cmd kwriteconfig6 kreadconfig6
    kset kxkbrc Layout Use true
    kset kxkbrc Layout ResetOldOptions true
    kset kxkbrc Layout LayoutList us,ir
    kset kxkbrc Layout VariantList ,
    kset kxkbrc Layout DisplayNames ,
    reload_layouts
    ok "layouts: us, ir"
}

revert() { run_undo; reload_layouts; }
