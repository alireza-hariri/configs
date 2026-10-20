FEATURE_NAME="Lock screen kernel version"
FEATURE_DESC="Shows the running kernel (e.g. Kernel 7.1.5-arch1-1) on the lock screen; no system files touched"

PKG_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/plasma/shells/org.kde.plasma.desktop.kernellock"

is_applied() { [[ -d "$PKG_DIR" ]]; }
apply() { bash "$GROUP_DIR/lock-mod/apply-kde-lock-mod.sh"; }
revert() { bash "$GROUP_DIR/lock-mod/revert-kde-lock-mod.sh"; }
