#!/usr/bin/env bash
# Extract every *.tar.zst in the current folder, then delete the archive.
# Usage: decompress-all.sh [-k|--keep]
set -euo pipefail
shopt -s nullglob

keep=0
[[ "${1:-}" == -k || "${1:-}" == --keep ]] && keep=1

archives=(*.tar.zst)
(( ${#archives[@]} )) || { echo "No .tar.zst files here."; exit 0; }

rc=0
for archive in "${archives[@]}"; do
    echo "Extracting '$archive'..."
    if tar -I zstd -xf "$archive"; then
        (( keep )) || rm -f -- "$archive"
    else
        echo "  failed, '$archive' kept" >&2
        rc=1
    fi
done
exit $rc
