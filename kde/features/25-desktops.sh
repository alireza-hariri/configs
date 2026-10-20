FEATURE_NAME="Virtual desktops"
FEATURE_DESC="Two virtual desktops in one row, the second named 'IDE'"

source "$GROUP_DIR/features/_kde.sh"
VDM=(org.kde.KWin /VirtualDesktopManager org.kde.KWin.VirtualDesktopManager)
WANT=2 NAME2=IDE

# Prints "position<TAB>id<TAB>name" per desktop.
desktops() {
    busctl --user --json=short get-property "${VDM[@]}" desktops |
        python3 -c 'import json,sys
for p,i,n in json.load(sys.stdin)["data"]: print(f"{p}\t{i}\t{n}")'
}

apply() {
    if ! in_plasma; then
        # Not in a Plasma session: write the config KWin reads at startup.
        kset kwinrc Desktops Number "$WANT"
        kset kwinrc Desktops Rows 1
        kset kwinrc Desktops Name_2 "$NAME2"
        ok "written to kwinrc; takes effect at next login"
        return
    fi
    need_cmd python3
    local count rows id name
    count="$(busctl --user get-property "${VDM[@]}" count | cut -d' ' -f2)"
    while (( count < WANT )); do
        busctl --user call "${VDM[@]}" createDesktop us "$count" "Desktop $((count + 1))"
        id="$(desktops | awk -F'\t' -v p="$count" '$1 == p {print $2}')"
        undo_once "desktop:$id" busctl --user call "${VDM[@]}" removeDesktop s "$id"
        count=$((count + 1))
    done
    IFS=$'\t' read -r _ id name < <(desktops | awk -F'\t' '$1 == 1')
    if [[ "$name" != "$NAME2" ]]; then
        undo_once "desktop-name:$id" busctl --user call "${VDM[@]}" setDesktopName ss "$id" "$name"
        busctl --user call "${VDM[@]}" setDesktopName ss "$id" "$NAME2"
    fi
    rows="$(busctl --user get-property "${VDM[@]}" rows | cut -d' ' -f2)"
    if [[ "$rows" != 1 ]]; then
        undo_once "desktop-rows" busctl --user set-property "${VDM[@]}" rows u "$rows"
        busctl --user set-property "${VDM[@]}" rows u 1
    fi
    ok "$WANT desktops, second one named '$NAME2'"
}
