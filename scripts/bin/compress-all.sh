#!/usr/bin/env bash
# Compress every sub-folder of the current folder into NAME.tar.zst, check
# the archive, then delete the folder.
# Usage: compress-all.sh [-k|--keep] [-l LEVEL]
#   -k, --keep   keep the folders after compressing
#   -l LEVEL     zstd level, 1 (fast, default) .. 19 (small)
set -euo pipefail
shopt -s nullglob

keep=0 level=1
while (( $# )); do
    case "$1" in
        -k|--keep) keep=1 ;;
        -l) level="$2"; shift ;;
        -h|--help) sed -n '2,7p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "unknown option: $1" >&2; exit 2 ;;
    esac
    shift
done

dirs=(*/)
(( ${#dirs[@]} )) || { echo "No folders here."; exit 0; }

rc=0
for dir in "${dirs[@]}"; do
    name="${dir%/}"
    [[ -L "$name" ]] && { echo "Skipping symlink '$name'"; continue; }
    out="$name.tar.zst"
    [[ -e "$out" ]] && { echo "Skipping '$name': $out already exists"; continue; }
    echo "Compressing '$name'..."
    if tar -I "zstd -T0 -$level" -cf "$out.part" "$name" && zstd -tq "$out.part"; then
        mv "$out.part" "$out"
        if (( keep )); then
            echo "  -> $out"
        else
            rm -rf -- "$name"
            echo "  -> $out (folder removed)"
        fi
    else
        rm -f "$out.part"
        echo "  failed, '$name' kept" >&2
        rc=1
    fi
done
exit $rc
