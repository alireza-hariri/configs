#!/usr/bin/env bash
# Install features of the 'git' config group. Shows a menu, or pass names.
# Usage: install.sh [--all] [--list] [--yes] [feature ...]
main() {
    set -euo pipefail
    local group=git here=""
    [[ -f "${BASH_SOURCE[0]:-}" ]] && here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [[ -z "$here" || ! -f "$here/../lib/common.sh" ]]; then
        # Started through curl: fetch the repo and run the real copy from it.
        tmp="$(mktemp -d)"   # global: the EXIT trap runs after main returns
        trap 'rm -rf "$tmp"' EXIT
        curl -fsSL "${CONFIGS_TARBALL:-https://codeload.github.com/alireza-hariri/configs/tar.gz/${CONFIGS_REF:-main}}" \
            | tar -xz -C "$tmp" --strip-components=1
        if { : </dev/tty; } 2>/dev/null; then
            bash "$tmp/$group/install.sh" "$@" </dev/tty
        else
            bash "$tmp/$group/install.sh" "$@"
        fi
        return
    fi
    # shellcheck source=../lib/common.sh
    source "$here/../lib/common.sh"
    configs_run install "$here" "$@"
}
main "$@"
