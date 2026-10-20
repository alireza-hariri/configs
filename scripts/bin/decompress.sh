#!/usr/bin/env bash
# Decompress archives based on their extension.
# Usage: decompress.sh <file> [<file> ...]
# Supported: tar, tar.gz/tgz, tar.bz2, tar.xz, tar.zst, gz, bz2, xz, zst, zip, rar, 7z
set -uo pipefail

err() { echo "error: $*" >&2; }

decompress_one() {
    local f="$1" lower
    [[ -f "$f" ]] || { err "not a file: $f"; return 1; }
    lower="${f,,}"

    case "$lower" in
        *.tar.gz|*.tgz)   tar xzf "$f" ;;
        *.tar.bz2|*.tbz2) tar xjf "$f" ;;
        *.tar.xz|*.txz)   tar xJf "$f" ;;
        *.tar.zst|*.tzst) tar --zstd -xf "$f" ;;
        *.tar)            tar xf "$f" ;;
        *.gz)             gunzip -k "$f" ;;
        *.bz2)            bunzip2 -k "$f" ;;
        *.xz)             unxz -k "$f" ;;
        *.zst)            zstd -dq "$f" ;;
        *.zip)            unzip -oq "$f" -d "${f%.*}" ;;
        *.rar)            unrar x -o+ "$f" ;;
        *.7z)             7z x -y "$f" ;;
        *) err "unsupported extension: $f"; return 1 ;;
    esac || { err "failed: $f"; return 1; }
    echo "decompressed: $f"
}

(( $# )) || { echo "usage: ${0##*/} <file> [<file> ...]" >&2; exit 2; }

rc=0
for file in "$@"; do
    decompress_one "$file" || rc=1
done
exit $rc
