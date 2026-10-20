FEATURE_NAME="ssh config.d layout"
FEATURE_DESC="Include ~/.ssh/config.d/* from ~/.ssh/config: one file per host (add-ssh-server uses it)"

SSH_CONFIG="$HOME/.ssh/config"

apply() {
    install -d -m 700 "$HOME/.ssh" "$HOME/.ssh/config.d"
    # Include must come before any Host block, so the block goes on top.
    block_set "$SSH_CONFIG" ssh-config-d --top <<'TXT'
Include config.d/*
TXT
    chmod 600 "$SSH_CONFIG"
    ok "hosts in ~/.ssh/config.d/*.conf are now loaded"
}

revert() {
    local f n=0
    for f in "$HOME/.ssh/config.d"/*; do [[ -e "$f" ]] && n=$((n + 1)); done
    (( n )) && warn "$n file(s) in ~/.ssh/config.d are no longer loaded; move them into ~/.ssh/config if needed"
    run_undo
    rmdir "$HOME/.ssh/config.d" 2>/dev/null || true
}
