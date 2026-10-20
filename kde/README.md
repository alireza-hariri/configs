# kde

KDE Plasma 6 settings. Everything goes through `kwriteconfig6`, KDE's D-Bus
APIs or user-level files. No sudo, and no system files are touched. Each old
value is recorded before it is changed, so uninstall writes back exactly what
was there before.

## Features

| id | what it does | takes effect |
|---|---|---|
| `lock-mod` | Kernel version in the top-right corner of the lock screen ([details](lock-mod/README.md)). | next login |
| `behavior` | Animations off, key repeat 500ms delay / 50 per second, cursor size 48, desktop-switch OSD (text only, 4s), slide effect off. | now (key repeat and cursor: next login) |
| `desktops` | Two virtual desktops in one row; the second is named `IDE`. | now |
| `tiling` | Custom tile layout 25% \| 50% \| 25% with 4px gaps, for every desktop × screen KWin knows about (Meta+T to edit). Re-run it after connecting a new screen. | next login |
| `keyboard` | Layouts: English (US) + Persian. | now |
| `shortcuts` | Global shortcuts that differ from Plasma defaults ([list](files/shortcuts.tsv)), summarised below. | now |
| `konsole` | A `Configs` profile (Hack 11) set as Konsole's default. | new windows |
| `gtk-theme` | GTK 2/3/4 apps follow Plasma: Breeze (dark), breeze icons and cursor (48), Noto Sans 10, no animations. | restart the app |

The `shortcuts` feature sets:

- Meta+Space switches to the next layout; Meta+Alt+1 and Meta+Alt+2 select US and Persian directly.
- Ctrl+F1…F4 switch desktops, and the Meta+F1…F4 alternatives are removed.
- Meta+Left / Meta+Right / Alt+, / Alt+. move one desktop left or right.
- Meta+Up / Meta+Down maximize and minimize windows, so quick-tile has no shortcut.
- Alt+Tab and Alt+\` switch windows; the Meta variants are removed.
- Present Windows uses Ctrl+F7 / F9 / F10.
- Meta+A / Meta+Shift+A walk through activities.

Shortcuts are changed live through kglobalaccel's D-Bus API, because editing
`kglobalshortcutsrc` while Plasma runs gets overwritten. It needs a running
Plasma session.

Not included: power settings, default apps (`mimeapps.list`) and autostart
entries. `~/.fonts.conf` is also left out: `~/.local/share/fonts` is already a
default font folder.

## Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/alireza-hariri/configs/main/kde/install.sh)
```

A menu opens: **↑/↓** (or j/k) to move, **space** to toggle, **a** for all,
**enter** to install, **q** to quit. Features already installed are marked.
To skip the menu, name the features (`… install.sh behavior shortcuts`) or pass `--all`. Add
`--yes` to accept the defaults for every question, or use `--list` to see what's installed.
From a clone, run `./kde/install.sh` instead.

## Uninstall

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/alireza-hariri/configs/main/kde/uninstall.sh)
```

The same menu lists only installed features. Removing a feature puts back
exactly what it changed: files are restored from backup, marked blocks are
cut out, and old settings values are written back. If you edited a managed
file after installing it, your version is kept next to it as
`*.configs-modified.<date>`. The bookkeeping lives in
`~/.local/state/configs/kde/`.
