# scripts

Small command-line tools, copied into `~/.local/bin` (override with
`BIN_DIR=…`). Uninstall deletes the copies; a copy you edited is kept aside.

## Features

| id | installs | notes |
|---|---|---|
| `add-ssh-server` | `add-ssh-server.py` | Asks for a name and a connection string such as `user@host:2222`, `user@host via jumper@jump:22`, or a pasted `ssh -J … -p …` command, then writes a `Host` entry. It uses `~/.ssh/config.d/<name>.conf` when that layout is enabled and checks for duplicates across all files. |
| `ssh-config-d` | `Include config.d/*` at the top of `~/.ssh/config` | One file per host in `~/.ssh/config.d/`. Uninstall removes the line, and warns if hosts there stop being loaded. |
| `archive-tools` | `decompress.sh`, `compress-all.sh`, `decompress-all.sh` | `decompress.sh` handles tar/gz/bz2/xz/zst/zip/rar/7z. `compress-all.sh` turns every sub-folder into `.tar.zst`, checks the archive, then deletes the folder (`-k` keeps it, `-l N` sets the level). `decompress-all.sh` reverses it. |
| `misc-tools` | `greptree`, `find-heavy-dirs.sh`, `create-desktop.py` | `greptree '*.py' [dirs]` shows matching files as a tree (needs ripgrep and tree). `find-heavy-dirs.sh [-t 3000] [-d 3] [dir]` finds folders with many files. `create-desktop.py` makes an app-menu launcher. |
| `claude-ip-guard` | `ip-guard`, plus `alias claude='ip-guard claude'` in `~/.bashrc.d/` | Starts Claude only when your public IPv4 is in `~/.config/ip-guard/allowed-ips`. Use `ip-guard --add` to allow the current IP and `ip-guard --show` to list them. The first install imports the IPs from an old `~/bin/cc_with_check`. The list is kept on uninstall. |
| `set-opencode` | `set-opencode.py` | Menu to switch opencode's OpenRouter key, base URL and model. Keys come from `OPENCODE_OPENROUTER_KEY` / `OPENROUTER_EFARDA_KEY` (put them in `~/.secrets.env`). |

## Fixed compared to the old `~/bin` copies

- **`greptree`:** a comment line was missing its `#`, so it ran as a command and printed an error every time. With no folder given it searched nothing; it now defaults to `.`. Its "no files" message printed an unset variable.
- **`find-heavy-dirs.sh`:** printed `$MAX_DEPTH`, which was never set. It only looked at exactly depth 3 instead of depths 1–3, and counted folders as files. It now takes `-t`, `-d` and a folder.
- **`decompress.sh`:** any error exited the whole loop instead of moving on to the next file. A failed extraction was still reported as success. `.7z` support added.
- **`compress-all.sh`:** deleted the folder without checking the archive (it now verifies with `zstd -t` first). With no folders it tried to compress a folder literally named `*`. It followed symlinks. It now writes to `.part` first and skips archives that already exist.
- **`create-desktop.py`:** `Exec=` was not quoted, so paths with spaces broke. Relative paths and paths starting with `~` now work. `Categories` gets its required trailing `;`. The app menu is refreshed after creating the launcher.
- **`add-ssh-server.py`:** IPv6 hosts were written as `[::1]`, which ssh rejects, and they are now written without brackets. It now supports `config.d`.
- **`ip-guard`** replaces both `cc_with_check` and `run_cc_check.sh`. The IPs moved out of the script, it falls back to a third IP provider, and it checks that the reply is really an IP address.
- **`set-opencode.py`:** a key whose environment variable wasn't set was written to `auth.json` as `null`. The `(default)` label was wrong. "Tencent Hy3" was missing its `openrouter/` prefix. Both files are now backed up as `.bak` before being rewritten.

## Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/alireza-hariri/configs/main/scripts/install.sh)
```

A menu opens: **↑/↓** (or j/k) to move, **space** to toggle, **a** for all,
**enter** to install, **q** to quit. Features already installed are marked.
To skip the menu, name the features (`… install.sh archive-tools misc-tools`) or pass `--all`. Add
`--yes` to accept the defaults for every question, or use `--list` to see what's installed.
From a clone, run `./scripts/install.sh` instead.

## Uninstall

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/alireza-hariri/configs/main/scripts/uninstall.sh)
```

The same menu lists only installed features. Removing a feature puts back
exactly what it changed: files are restored from backup, marked blocks are
cut out, and old settings values are written back. If you edited a managed
file after installing it, your version is kept next to it as
`*.configs-modified.<date>`. The bookkeeping lives in
`~/.local/state/configs/scripts/`.
