FEATURE_NAME="GTK theme"
FEATURE_DESC="GTK 2/3/4 apps match Plasma: Breeze dark, breeze icons and cursor, Noto Sans 10, no animations"

CFG="${XDG_CONFIG_HOME:-$HOME/.config}"

# Settings shared by GTK 3 and 4 (gtk-xft-dpi is left out: it is per-screen).
COMMON=(
    gtk-application-prefer-dark-theme=true
    gtk-cursor-blink=true
    gtk-cursor-blink-time=1000
    gtk-cursor-theme-name=breeze_cursors
    gtk-cursor-theme-size=48
    gtk-decoration-layout=icon:minimize,maximize,close
    gtk-enable-animations=false
    "gtk-font-name=Noto Sans,  10"
    gtk-icon-theme-name=breeze-dark
    gtk-primary-button-warps-slider=true
    gtk-sound-theme-name=ocean
)
GTK3_ONLY=(
    gtk-button-images=true
    gtk-menu-images=true
    gtk-theme-name=Breeze
    gtk-toolbar-style=3
)

apply() {
    need_cmd kwriteconfig6 kreadconfig6
    local kv
    for kv in "${COMMON[@]}" "${GTK3_ONLY[@]}"; do
        kset "$CFG/gtk-3.0/settings.ini" Settings "${kv%%=*}" "${kv#*=}"
    done
    for kv in "${COMMON[@]}"; do
        kset "$CFG/gtk-4.0/settings.ini" Settings "${kv%%=*}" "${kv#*=}"
    done
    put_file "$GROUP_DIR/files/gtkrc-2.0" "$HOME/.gtkrc-2.0"
    ok "restart GTK apps to see it"
    warn "Plasma rewrites these files when you change themes in System Settings"
}
