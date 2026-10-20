# configs

My Linux (Arch + KDE Plasma 6) configuration, as groups you can apply and
revert. Each group has an interactive installer: pick features with a
checkbox menu, and remove them the same way.

| group | what's in it |
|---|---|
| [shell](shell/) | bash: secrets loader, PATH, shared history, prompt, aliases, tmux, proxy toggle, lazy nvm, herdr completion |
| [git](git/) | git defaults, LFS + Xet, identity, global ignore placeholder |
| [scripts](scripts/) | CLI tools: add-ssh-server, ssh config.d, archive tools, greptree, find-heavy-dirs, create-desktop, ip-guard for Claude, set-opencode |
| [uv](uv/) | Python 3.14 via uv, uv tools, VS Code settings / keybindings / extensions |
| [kde](kde/) | lock screen kernel version, behavior, virtual desktops, tiling, keyboard layouts, global shortcuts, Konsole, GTK theme |

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/alireza-hariri/configs/main/<group>/install.sh)
bash <(curl -fsSL https://raw.githubusercontent.com/alireza-hariri/configs/main/<group>/uninstall.sh)
```

## How it works

- `<group>/features/NN-<id>.sh` holds one feature: a name, a description and
  an `apply()` function. `lib/common.sh` provides the menu, the runner and
  helpers that log how to undo each change: `put_file`, `block_set`, `kset`,
  `bashrc_d_install`, `seed_text`.
- Uninstall replays that log in reverse. Backups and the log are kept in
  `~/.local/state/configs/<group>/<feature>/`.
- Run through curl, the installer downloads the repo tarball to a temp folder
  and runs from there. `CONFIGS_REF=<branch>` picks another branch.
- Secrets never go in this repo. Keys belong in `~/.secrets.env`, loaded by
  `shell` → `secrets`.
