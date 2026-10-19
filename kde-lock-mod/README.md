# KDE lock screen kernel version

Shows the running kernel version (e.g. `Kernel 7.1.5-arch1-1`) in the top-right
corner of the KDE Plasma 6 lock screen.

No system files are touched: the scripts build a user-level copy of the lock
screen in `~/.local/share/plasma/shells/org.kde.plasma.desktop.kernellock/` and
point the screen locker at it with a systemd user drop-in that sets
`PLASMA_DEFAULT_SHELL` for kwin (Wayland) / ksmserver (X11) only, so the desktop
itself is unaffected. No sudo is needed, and package updates won't overwrite it.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/alireza-hariri/configs/main/kde-lock-mod/apply-kde-lock-mod.sh | bash
```

Then log out and back in, so kwin restarts with the new environment.

## Test

Preview the lock screen without locking your session (unlock with your password):

```bash
PLASMA_DEFAULT_SHELL=org.kde.plasma.desktop.kernellock /usr/lib/kscreenlocker_greet --testing
```

## After Plasma updates

The override is a snapshot of the lock screen from the Plasma version it was
built with. If a later update changes the lock screen, the locker may fall back
to its plain built-in screen (you can still unlock normally). Run the install
command again to rebuild the copy from the new files.

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/alireza-hariri/configs/main/kde-lock-mod/revert-kde-lock-mod.sh | bash
```

This removes the override and the systemd drop-ins (log out and back in afterwards). If an older version
of this mod had edited the system file directly, it also cleans that up (asks for
sudo only in that case).

## Requirements

- KDE Plasma 6 (tested on 6.7.3, Arch Linux)
- Plasma started through systemd (the default since Plasma 5.25)
