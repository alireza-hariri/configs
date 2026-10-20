# git

Git settings as separate files in `~/.config/git/configs/`, each added to
`~/.gitconfig` with an `[include]` line. Your own `~/.gitconfig` is never
rewritten; uninstall removes only the include line and the file.

## Features

| id | what it does |
|---|---|
| `defaults` | `init.defaultBranch = main`; submodule-aware `status`, `diff` and `push` (`submodule.recurse`, `diff.submodule = log`, `push.recurseSubmodules = on-demand`); `core.fileMode = false`. |
| `lfs` | git-lfs filter config, 3 parallel transfers, and the `git-xet` custom transfer for Hugging Face Xet repos. Warns if `git-lfs` / `git-xet` are missing. |
| `identity` | Asks for `user.name` / `user.email`, defaulting to the current values. |
| `global-ignore` | Creates a placeholder **`~/.config/git/ignore`** (or the file `core.excludesFile` points to) if there isn't one, and tells you where it is. **Add your own global ignore patterns there.** The file is yours and is kept on uninstall. |

Check the result with `git config --list --show-origin`.

Not included: `credential.helper = store` keeps your tokens in plaintext in
`~/.git-credentials`. Consider `libsecret` or `gh auth setup-git` instead.

## Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/alireza-hariri/configs/main/git/install.sh)
```

A menu opens: **↑/↓** (or j/k) to move, **space** to toggle, **a** for all,
**enter** to install, **q** to quit. Features already installed are marked.
To skip the menu, name the features (`… install.sh defaults identity`) or pass `--all`. Add
`--yes` to accept the defaults for every question, or use `--list` to see what's installed.
From a clone, run `./git/install.sh` instead.

## Uninstall

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/alireza-hariri/configs/main/git/uninstall.sh)
```

The same menu lists only installed features. Removing a feature puts back
exactly what it changed: files are restored from backup, marked blocks are
cut out, and old settings values are written back. If you edited a managed
file after installing it, your version is kept next to it as
`*.configs-modified.<date>`. The bookkeeping lives in
`~/.local/state/configs/git/`.
