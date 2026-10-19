#!/usr/bin/env bash
# Removes the user-level lock screen override made by apply-kde-lock-mod.sh,
# and cleans up the older in-place mod of the system file if it is still there.
set -euo pipefail

PKG_ID=org.kde.plasma.desktop.kernellock
PKG_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/plasma/shells/$PKG_ID"
SYSTEMD_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
UNITS=(plasma-kwin_wayland.service plasma-ksmserver.service)
SYSTEM_UI=/usr/share/plasma/shells/org.kde.plasma.desktop/contents/lockscreen/LockScreenUi.qml

for unit in "${UNITS[@]}"; do
    rm -f "$SYSTEMD_DIR/$unit.d/kde-lock-mod.conf"
    rmdir "$SYSTEMD_DIR/$unit.d" 2>/dev/null || true
done
systemctl --user daemon-reload 2>/dev/null || true

# Older versions of the apply script set this (unused) key.
if [[ "$(kreadconfig6 --file kscreenlockerrc --group Greeter --key Theme)" == "$PKG_ID" ]]; then
    kwriteconfig6 --file kscreenlockerrc --group Greeter --key Theme --delete
fi

if [[ -d "$PKG_DIR" ]]; then
    rm -rf "$PKG_DIR"
    echo "Removed $PKG_DIR"
else
    echo "Override not installed"
fi

# Older versions of the apply script edited the system file in place.
if grep -q "KERNEL-MOD-" "$SYSTEM_UI" 2>/dev/null; then
    echo "Removing old in-place mod from $SYSTEM_UI (needs sudo)"
    tmp="$(mktemp)"
    awk '
        /KERNEL-MOD-IMPORT/ { next }
        /KERNEL-MOD-BEGIN/ { held = 0; skip = 1; next }
        /KERNEL-MOD-END/ { skip = 0; next }
        skip { next }
        /^$/ { if (held) print ""; held = 1; next }
        { if (held) print ""; held = 0; print }
        END { if (held) print "" }
    ' "$SYSTEM_UI" > "$tmp"
    sudo sh -c 'cat "$1" > "$2" && rm -f "$2.bak"' sh "$tmp" "$SYSTEM_UI"
    rm -f "$tmp"
fi
