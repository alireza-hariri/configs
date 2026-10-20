# Terminal multiselect menu. Reads keys from /dev/tty, draws on /dev/tty.
#
#   MENU_LABELS=(...)     one line per item
#   MENU_DESCS=(...)      shown under the list for the highlighted item
#   MENU_SELECTED=(0 1 ...)  initial state, updated in place
#   menu_select "Title" || echo "cancelled"

_menu_cleanup() {
    printf '\033[?25h' >/dev/tty   # show cursor
    stty "$_menu_stty" </dev/tty 2>/dev/null || true
}

menu_select() {
    local title="$1" n=${#MENU_LABELS[@]} cur=0 i key rest lines cols mark label
    (( n > 0 )) || return 1
    _menu_stty="$(stty -g </dev/tty)"
    trap '_menu_cleanup; exit 130' INT TERM
    stty -echo </dev/tty
    printf '\033[?25l' >/dev/tty   # hide cursor
    cols=$(stty size </dev/tty 2>/dev/null | cut -d' ' -f2)
    [[ "$cols" =~ ^[0-9]+$ ]] && (( cols >= 20 )) || cols=80   # unknown size reports 0
    lines=0

    while true; do
        # Redraw in place: move up over the previous frame and clear it.
        (( lines > 0 )) && printf '\033[%dA' "$lines" >/dev/tty
        printf '\033[J' >/dev/tty
        {
            printf '\033[1m%s\033[0m\n' "$title"
            for (( i = 0; i < n; i++ )); do
                mark=' '; (( MENU_SELECTED[i] )) && mark='x'
                label="[$mark] ${MENU_LABELS[i]}"
                label="${label:0:cols-4}"
                if (( i == cur )); then
                    printf '\033[7m> %s\033[0m\n' "$label"
                else
                    printf '  %s\n' "$label"
                fi
            done
            printf '\033[2m  %s\033[0m\n' "${MENU_DESCS[cur]:0:cols-4}"
            printf '\033[2m  up/down move · space toggle · a all · enter confirm · q quit\033[0m\n'
        } >/dev/tty
        lines=$(( n + 3 ))

        IFS= read -rsn1 key </dev/tty || key=q
        if [[ "$key" == $'\033' ]]; then
            rest=""
            IFS= read -rsn2 -t 0.05 rest </dev/tty || true
            case "$rest" in
                '[A') key=up ;;
                '[B') key=down ;;
                '') key=q ;;
                *) key="" ;;
            esac
        fi
        case "$key" in
            up|k) (( cur = (cur - 1 + n) % n )) ;;
            down|j) (( cur = (cur + 1) % n )) ;;
            ' ') (( MENU_SELECTED[cur] = !MENU_SELECTED[cur] )) ;;
            a|A)
                local all=1
                for (( i = 0; i < n; i++ )); do (( MENU_SELECTED[i] )) || all=0; done
                for (( i = 0; i < n; i++ )); do MENU_SELECTED[i]=$(( !all )); done
                ;;
            '') _menu_cleanup; trap - INT TERM; return 0 ;;
            q|Q) _menu_cleanup; trap - INT TERM; return 1 ;;
        esac
    done
}
