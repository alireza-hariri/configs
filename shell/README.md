# shell

Bash setup, split into small features. Each one is a single file in
`~/.bashrc.d/`, and `~/.bashrc` gets one marked block that loads that folder.
Nothing else in your `.bashrc` is touched.

## Features

| id | what it does |
|---|---|
| `secrets` | Loads `~/.secrets.env` (`KEY=value` lines, chmod 600) into the environment, and warns if the file is readable by others. Keeps API keys out of `.bashrc` and out of git. The file is created empty and kept on uninstall. |
| `locale` | `export LANG=en_US.UTF-8`, after checking that the locale exists. |
| `paths` | Adds `~/.local/bin`, `~/.npm-global/bin`, `/usr/local/go/bin`, `~/go/bin` and the Orca CLI shim to PATH, once each and only if they exist. |
| `history` | 100k lines in memory, 500k on disk, timestamps, no duplicates or space-prefixed lines, shared live between open terminals. |
| `prompt` | `[user@host dir]` in green, with the exit code in red after a failed command. |
| `aliases` | Colored `ls`/`grep`/`diff`, `ll`, `df1` (real disks only), `pzl`/`unixtime` (if `pz` is installed), and `act`, which activates the nearest `.venv` in this folder or a parent. |
| `tmux` | `tmux -u`, sockets in a private `~/.local/state/tmux`. |
| `proxy` | `proxy` toggles; also `proxy on [ADDR]`, `proxy off`, `proxy status`. Sets http/https/ftp/all_proxy (both cases). The address is remembered in `~/.proxyaddr`, and `socks5h://` works too. |
| `nvm` | Puts nvm's default Node on PATH without loading nvm; nvm itself loads on its first use. Shell start is ~100ms faster. Set the default once with `nvm alias default lts/*`. |
| `herdr` | Bash completion for `herdr`, cached in `~/.cache/configs/` and regenerated when the herdr binary changes. |

## Fixed compared to the old `.bashrc_shared`

- **`HISTFILESIZE` was set twice and `HISTSIZE` never**, so the in-memory history stayed at bash's default of 500 lines.
- **`PROMPT_COMMAND` was overwritten**, wiping out hooks from VS Code, Konsole and other terminals. It is now prepended to instead.
- **The whole 500k-line history file was re-read at every prompt** (`history -c; history -r`). Now only new lines are read (`history -n`).
- **`LANG`/`LC_ALL` were set but not exported**, so programs started from the shell didn't get them. `LANG` is now exported. `LC_ALL` is left alone, because it overrides every per-category setting.
- **`mkdir` + `chmod` ran on every shell start** for the tmux folder. Now that only happens when the folder doesn't exist yet.
- **PATH grew a duplicate entry each time a shell was nested.** Entries are now added only once.
- **`nvm.sh` was sourced in full by every shell.** It now loads lazily (see the `nvm` feature).
- **The herdr completion cache was never refreshed** after a herdr update, and was kept as `~/.bash_herdr` in your home folder. It now lives in `~/.cache/configs/` and is regenerated when herdr changes.
- **Proxy:** an empty address is rejected, `socks5://` addresses work, and `all_proxy` is set too.
- **API keys were hard-coded in the file.** They now go in `~/.secrets.env`, loaded by the `secrets` feature.

## Moving from `~/.bashrc_shared`

After installing, remove the `source ~/.bashrc_shared` line from `~/.bashrc`
(the installer warns while it is still there). Move your `export *_API_KEY=…`
lines into `~/.secrets.env`, dropping the `export` keyword.

## Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/alireza-hariri/configs/main/shell/install.sh)
```

A menu opens: **↑/↓** (or j/k) to move, **space** to toggle, **a** for all,
**enter** to install, **q** to quit. Features already installed are marked.
To skip the menu, name the features (`… install.sh history prompt`) or pass `--all`. Add
`--yes` to accept the defaults for every question, or use `--list` to see what's installed.
From a clone, run `./shell/install.sh` instead.

## Uninstall

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/alireza-hariri/configs/main/shell/uninstall.sh)
```

The same menu lists only installed features. Removing a feature puts back
exactly what it changed: files are restored from backup, marked blocks are
cut out, and old settings values are written back. If you edited a managed
file after installing it, your version is kept next to it as
`*.configs-modified.<date>`. The bookkeeping lives in
`~/.local/state/configs/shell/`.
