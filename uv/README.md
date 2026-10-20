# uv

Python through [uv](https://docs.astral.sh/uv/), and the VS Code setup that
goes with it. Features that need uv offer to install it if it is missing.

## Features

| id | what it does |
|---|---|
| `python` | `uv python install 3.14` and pins it as the global default (`~/.config/uv/.python-version`). Uninstall removes the pin, plus the Python if this feature installed it. |
| `uv-tools` | `uv tool install` for each entry in [`files/uv-tools.txt`](files/uv-tools.txt): cookiecutter, excdump, git-filter-repo, hf, jupytext, notebook, poethepoet, pz, ruff, specify-cli (from git). Tools already installed are skipped; uninstall removes only the tools it installed. |
| `vscode-settings` | Merges [`files/vscode-settings.json`](files/vscode-settings.json) into `~/.config/Code/User/settings.json`: ruff (line length 120, uv backend), auto-save on focus change, zoom 1.2, terminal tweaks, Copilot/Continue/llama-vscode inline features off, spell-check words. Other settings are left alone. Uninstall restores the previous value of each key it set, unless you changed that key since. |
| `vscode-keybindings` | Adds F5 → run task `uv_run` and Shift+F5 → start debugging to `keybindings.json`. |
| `vscode-extensions` | Installs the extensions in [`files/vscode-extensions.txt`](files/vscode-extensions.txt) that are missing. Uninstall removes only those it installed. |

`VSCODE_USER_DIR` and `VSCODE_BIN` select a different VS Code build (for
example VSCodium). VS Code's comments in `settings.json` are dropped when it is
rewritten, but the original is saved in `~/.local/state/configs/uv/`.

## Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/alireza-hariri/configs/main/uv/install.sh)
```

A menu opens: **↑/↓** (or j/k) to move, **space** to toggle, **a** for all,
**enter** to install, **q** to quit. Features already installed are marked.
To skip the menu, name the features (`… install.sh python uv-tools`) or pass `--all`. Add
`--yes` to accept the defaults for every question, or use `--list` to see what's installed.
From a clone, run `./uv/install.sh` instead.

## Uninstall

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/alireza-hariri/configs/main/uv/uninstall.sh)
```

The same menu lists only installed features. Removing a feature puts back
exactly what it changed: files are restored from backup, marked blocks are
cut out, and old settings values are written back. If you edited a managed
file after installing it, your version is kept next to it as
`*.configs-modified.<date>`. The bookkeeping lives in
`~/.local/state/configs/uv/`.
