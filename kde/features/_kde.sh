# Shared by the kde features.
in_plasma() { busctl --user status org.kde.KWin >/dev/null 2>&1; }

kwin_reconfigure() {
    in_plasma && busctl --user call org.kde.KWin /KWin org.kde.KWin reconfigure >/dev/null 2>&1 || true
}
