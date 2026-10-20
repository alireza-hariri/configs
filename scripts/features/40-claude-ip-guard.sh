FEATURE_NAME="Claude IP guard"
FEATURE_DESC="ip-guard + alias claude='ip-guard claude': only start Claude from allowed public IPs"

source "$GROUP_DIR/features/_bin.sh"
LIST="${XDG_CONFIG_HOME:-$HOME/.config}/ip-guard/allowed-ips"

apply() {
    need_cmd curl
    bin_install ip-guard

    # Seed the allow-list, importing IPs from the old ~/bin/cc_with_check if present.
    local ips=""
    if [[ -f "$HOME/bin/cc_with_check" ]]; then
        ips="$(grep -oE '^EXPECTED_IPS=\(.*\)' "$HOME/bin/cc_with_check" | grep -oE '[0-9]+(\.[0-9]+){3}' || true)"
    fi
    seed_text "$LIST" 600 <<TXT
# Public IPv4 addresses allowed by ip-guard, one per line.
# Add the current one with: ip-guard --add
${ips}
TXT
    [[ -n "$ips" ]] && ok "imported $(wc -w <<< "$ips") IP(s) from ~/bin/cc_with_check"
    if ! grep -qE '^[0-9]' "$LIST" && ask_yn "The allow-list is empty. Add your current public IP?" Y; then
        "$BIN_DIR/ip-guard" --add || warn "could not add the current IP"
    fi

    local tmp; tmp="$(mktemp)"
    cat > "$tmp" <<'TXT'
# Managed by configs/scripts (claude-ip-guard).
alias claude='ip-guard claude'
TXT
    bashrc_d_install 90-claude-ip-guard "$tmp"
    rm -f "$tmp"
    ok "allow-list: $LIST (kept on uninstall)"
}
