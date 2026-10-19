#!/usr/bin/env bash
# Builds a user-level lock screen package that adds the running kernel version
# to the top-right corner, and points the KDE screen locker at it through a
# systemd drop-in that sets PLASMA_DEFAULT_SHELL for kwin / ksmserver only.
# System files are never modified. Re-run after Plasma updates to refresh the copy.
set -euo pipefail

SYSTEM_LOCKSCREEN=/usr/share/plasma/shells/org.kde.plasma.desktop/contents/lockscreen
PKG_ID=org.kde.plasma.desktop.kernellock
PKG_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/plasma/shells/$PKG_ID"
UI="$PKG_DIR/contents/lockscreen/LockScreenUi.qml"
SYSTEMD_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
# kwin launches the greeter on Wayland, ksmserver on X11.
UNITS=(plasma-kwin_wayland.service plasma-ksmserver.service)

[[ -d "$SYSTEM_LOCKSCREEN" ]] || { echo "Not found: $SYSTEM_LOCKSCREEN" >&2; exit 1; }

if grep -q "KERNEL-MOD-" "$SYSTEM_LOCKSCREEN/LockScreenUi.qml"; then
    echo "The system lock screen still has the old in-place mod. Run revert-kde-lock-mod.sh first." >&2
    exit 1
fi

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

mkdir -p "$tmpdir/contents"
cp -r "$SYSTEM_LOCKSCREEN" "$tmpdir/contents/lockscreen"
cat > "$tmpdir/metadata.json" <<JSON
{
    "KPackageStructure": "Plasma/Shell",
    "KPlugin": {
        "Id": "$PKG_ID",
        "Name": "Plasma Desktop (kernel version on lock screen)",
        "License": "GPL-2.0-or-later"
    },
    "X-Plasma-APIVersion": "2"
}
JSON

awk '
    /^import org\.kde\.kirigami/ && !imported {
        print
        print "import org.kde.plasma.plasma5support as P5Support // KERNEL-MOD-IMPORT"
        imported = 1
        next
    }
    /^        Clock \{/ { in_clock = 1 }
    { print }
    in_clock && /^        \}$/ {
        in_clock = 0
        inserted = 1
        print ""
        print "        // KERNEL-MOD-BEGIN"
        print "        P5Support.DataSource {"
        print "            id: kernelSource"
        print "            engine: \"executable\""
        print "            connectedSources: [\"uname -r\"]"
        print "        }"
        print ""
        print "        PlasmaComponents3.Label {"
        print "            text: \"Kernel \" + (kernelSource.data[\"uname -r\"]"
        print "                  ? kernelSource.data[\"uname -r\"].stdout.trim() : \"\")"
        print "            color: \"white\""
        print "            opacity: 0.8"
        print "            anchors {"
        print "                top: parent.top"
        print "                right: parent.right"
        print "                margins: Kirigami.Units.gridUnit"
        print "            }"
        print "        }"
        print "        // KERNEL-MOD-END"
    }
    END { if (!imported || !inserted) exit 2 }
' "$SYSTEM_LOCKSCREEN/LockScreenUi.qml" > "$tmpdir/contents/lockscreen/LockScreenUi.qml" || {
    echo "Could not find the expected import/Clock block; file layout changed. Nothing modified." >&2
    exit 1
}

rm -rf "$PKG_DIR"
mkdir -p "$(dirname "$PKG_DIR")"
mv "$tmpdir" "$PKG_DIR"
trap - EXIT

for unit in "${UNITS[@]}"; do
    mkdir -p "$SYSTEMD_DIR/$unit.d"
    printf '[Service]\nEnvironment=PLASMA_DEFAULT_SHELL=%s\n' "$PKG_ID" > "$SYSTEMD_DIR/$unit.d/kde-lock-mod.conf"
done
systemctl --user daemon-reload 2>/dev/null || true

echo "Override installed in $PKG_DIR"
echo "Log out and back in for the lock screen to pick it up."
echo "Test now with: PLASMA_DEFAULT_SHELL=$PKG_ID /usr/lib/kscreenlocker_greet --testing"
