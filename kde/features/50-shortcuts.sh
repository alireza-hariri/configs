FEATURE_NAME="Global shortcuts"
FEATURE_DESC="Meta+Space layout switch, Ctrl+F1..F4 desktops, Alt+,/Alt+. prev/next desktop, Meta+Up/Down max/min, ..."

KGA=(org.kde.kglobalaccel /kglobalaccel org.kde.KGlobalAccel)

# kglobalaccel reads every key sequence as exactly 4 ints and aborts KWin
# (it runs inside kwin_wayland) if it gets fewer, so every sequence sent is
# padded to 4. A shortcut is stored as "k1:k2:k3:k4", several separated by spaces.

# get_keys COMP ACTION CF AF -> "k1:k2:k3:k4 ..." (empty if none)
get_keys() {
    local out; out="$(busctl --user call "${KGA[@]}" shortcutKeys as 4 "$@")" || return 1
    # Text form: a(ai) N  L k..  L k..
    set -- $out
    shift   # signature
    local n="$1" res=() i l seq; shift
    for (( i = 0; i < n; i++ )); do
        l="$1"; shift
        seq="$(printf '%s:' "${@:1:l}")"; shift "$l"
        res+=("${seq%:}")
    done
    printf '%s' "${res[*]}"
}

# set_keys COMP ACTION CF AF "k1:k2:k3:k4 ..."
set_keys() {
    local comp="$1" action="$2" cf="$3" af="$4" seq parts args=()
    local seqs=($5)
    for seq in "${seqs[@]}"; do
        IFS=: read -ra parts <<< "$seq"
        while (( ${#parts[@]} < 4 )); do parts+=(0); done
        (( ${#parts[@]} == 4 )) || die "bad key sequence '$seq' for $action"
        for p in "${parts[@]}"; do [[ "$p" =~ ^-?[0-9]+$ ]] || die "bad key code '$p' for $action"; done
        args+=(4 "${parts[@]}")
    done
    busctl --user call "${KGA[@]}" setForeignShortcutKeys 'asa(ai)' \
        4 "$comp" "$action" "$cf" "$af" "${#seqs[@]}" "${args[@]}"
}

has_action() {  # has_action COMP ACTION
    busctl --user call "${KGA[@]}" allActionsForComponent as 1 "$1" 2>/dev/null | grep -qF "\"$2\""
}

_undo_shortcut() { set_keys "$@" && ok "restored shortcut: $2"; }

apply() {
    busctl --user status org.kde.kglobalaccel >/dev/null 2>&1 || die "run this inside a Plasma session"
    local comp action cf af keys label old n=0
    while IFS='|' read -r comp action cf af keys label; do
        [[ -z "$comp" || "$comp" == \#* ]] && continue
        if ! has_action "$comp" "$action"; then
            warn "skipped '$action': $comp has not registered it on this system"
            continue
        fi
        [[ "$keys" == - ]] && keys=""
        old="$(get_keys "$comp" "$action" "$cf" "$af")"
        undo_once "sc:$comp:$action" _undo_shortcut "$comp" "$action" "$cf" "$af" "$old"
        set_keys "$comp" "$action" "$cf" "$af" "$keys"
        n=$((n + 1))
    done < "$GROUP_DIR/files/shortcuts.tsv"
    ok "$n shortcuts set (live, no logout needed)"
}
