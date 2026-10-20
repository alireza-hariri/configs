FEATURE_NAME="Tiling layout"
FEATURE_DESC="25% | 50% | 25% custom tile layout with 4px gaps on every desktop and screen (Meta+T editor)"

TILES='{"layoutDirection":"horizontal","tiles":[{"width":0.25},{"width":0.5},{"width":0.25}]}'
PADDING=4
CFG="${XDG_CONFIG_HOME:-$HOME/.config}"

apply() {
    need_cmd python3 kwriteconfig6
    local desktops outputs d o n=0
    # Desktop ids KWin saved; screens it has seen (virtual screen-cast outputs skipped).
    desktops="$(grep -oP '^Id_\d+=\K.*' "$CFG/kwinrc" 2>/dev/null || true)"
    outputs="$(python3 - "$CFG/kwinoutputconfig.json" <<'PY' 2>/dev/null || true
import json, sys
for entry in json.load(open(sys.argv[1])):
    if entry.get("name") == "outputs":
        for o in entry.get("data", []):
            if o.get("uuid") and not o.get("connectorName", "").startswith("Virtual"):
                print(o["uuid"])
PY
)"
    [[ -n "$desktops" && -n "$outputs" ]] || die "no desktops/screens recorded yet; log in to Plasma once, then re-run"
    for d in $desktops; do
        for o in $outputs; do
            kset kwinrc "Tiling/$d/$o" tiles "$TILES"
            kset kwinrc "Tiling/$d/$o" padding "$PADDING"
            n=$((n + 1))
        done
    done
    ok "layout set for $n desktop/screen pairs; log out and in to load it"
    warn "screens connected later get it when you re-run this feature"
}
