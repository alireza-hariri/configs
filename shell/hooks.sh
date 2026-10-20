# Group hooks for configs/shell, called by the runner.
group_after() {
    [[ "$1" == install ]] || return 0
    if grep -qE '^[^#]*\.bashrc_shared' "$HOME/.bashrc" 2>/dev/null; then
        warn "~/.bashrc still sources ~/.bashrc_shared, which sets the same things."
        warn "Remove that line (and keys from it, see the secrets feature) to avoid running both."
    fi
    log "Open a new terminal (or run: source ~/.bashrc) to use the changes."
}
