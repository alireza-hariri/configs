# Managed by configs/shell (tmux). UTF-8 by default, sockets in a private
# folder under ~/.local/state instead of /tmp.
alias tmux='tmux -u'
export TMUX_TMPDIR="${XDG_STATE_HOME:-$HOME/.local/state}/tmux"
[ -d "$TMUX_TMPDIR" ] || install -d -m 700 "$TMUX_TMPDIR"
