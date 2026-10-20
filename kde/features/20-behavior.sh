FEATURE_NAME="Desktop behavior"
FEATURE_DESC="Animations off, fast key repeat (500ms/50Hz), cursor size 48, desktop-switch OSD on, slide effect off"

source "$GROUP_DIR/features/_kde.sh"

apply() {
    need_cmd kwriteconfig6 kreadconfig6
    kset kdeglobals KDE AnimationDurationFactor 0
    kset kcminputrc Keyboard RepeatDelay 500
    kset kcminputrc Keyboard RepeatRate 50
    kset kcminputrc Mouse cursorSize 48
    kset kwinrc Plugins slideEnabled false
    kset kwinrc Plugins desktopchangeosdEnabled true
    kset kwinrc Script-desktopchangeosd PopupHideDelay 4
    kset kwinrc Script-desktopchangeosd TextOnly true
    kwin_reconfigure
    ok "applied; key repeat and cursor size fully apply after logging out and in"
}

revert() { run_undo; kwin_reconfigure; }
