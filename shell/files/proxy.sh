# Managed by configs/shell (proxy).
#   proxy            toggle on/off
#   proxy on [ADDR]  turn on (ADDR is saved for next time)
#   proxy off        turn off
#   proxy status     show the current setting
# ADDR can be host:port, http://host:port or socks5h://host:port.
proxy() {
    local file="$HOME/.proxyaddr" addr="" v
    local vars="http_proxy https_proxy ftp_proxy all_proxy HTTP_PROXY HTTPS_PROXY FTP_PROXY ALL_PROXY"
    local cmd="${1:-toggle}"
    if [ "$cmd" = toggle ]; then
        if [ -n "${http_proxy:-}" ]; then cmd=off; else cmd=on; fi
    fi
    case "$cmd" in
        off)
            for v in $vars no_proxy NO_PROXY; do unset "$v"; done
            echo "Proxy is OFF"
            ;;
        status)
            if [ -n "${http_proxy:-}" ]; then echo "Proxy is ON ($http_proxy)"; else echo "Proxy is OFF"; fi
            ;;
        on)
            addr="${2:-}"
            if [ -z "$addr" ] && [ -s "$file" ]; then
                read -r addr < "$file"
                local reply
                read -rp "Use saved proxy $addr? [Y/n] " reply
                case "$reply" in [Nn]*) addr="" ;; esac
            fi
            if [ -z "$addr" ]; then
                read -rp "Proxy address (e.g. 127.0.0.1:10801): " addr
            fi
            addr="${addr//[[:space:]]/}"
            [ -n "$addr" ] || { echo "proxy: no address given" >&2; return 1; }
            case "$addr" in *://*) ;; *) addr="http://$addr" ;; esac
            case "$addr" in
                http://*|https://*|socks5://*|socks5h://*) ;;
                *) echo "proxy: unsupported scheme in $addr" >&2; return 1 ;;
            esac
            printf '%s\n' "$addr" > "$file"
            for v in $vars; do export "$v=$addr"; done
            export no_proxy="localhost,127.0.0.1,::1" NO_PROXY="localhost,127.0.0.1,::1"
            echo "Proxy is ON ($addr)"
            ;;
        *)
            echo "usage: proxy [on [ADDR]|off|status]" >&2
            return 1
            ;;
    esac
}
