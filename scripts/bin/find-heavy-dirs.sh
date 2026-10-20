#!/usr/bin/env bash
# List folders that contain at least THRESHOLD files (at any depth below
# them), looking at folders up to DEPTH levels down.
# Usage: find-heavy-dirs.sh [-t THRESHOLD] [-d DEPTH] [dir]
#   defaults: THRESHOLD=3000, DEPTH=3, dir=.
set -euo pipefail

threshold=3000 depth=3
while getopts "t:d:h" opt; do
    case "$opt" in
        t) threshold="$OPTARG" ;;
        d) depth="$OPTARG" ;;
        *) sed -n '2,6p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    esac
done
shift $((OPTIND - 1))
root="${1:-.}"

echo "Folders under '$root' (depth 1-$depth) with at least $threshold files:"
echo "----------------------------------------------------------------"

find "$root" -mindepth 1 -maxdepth "$depth" -type d -print0 |
while IFS= read -r -d '' dir; do
    # head stops reading at the threshold, so find quits early on huge trees.
    count=$(find "$dir" -type f 2>/dev/null | head -n "$threshold" | wc -l)
    if (( count >= threshold )); then
        echo "[HIGH COUNT] $dir"
    fi
done

echo "----------------------------------------------------------------"
echo "Scan complete."
