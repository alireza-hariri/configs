FEATURE_NAME="tmux"
FEATURE_DESC="tmux -u alias and a private socket folder under ~/.local/state/tmux"

apply() {
    bashrc_d_install 60-tmux "$GROUP_DIR/files/tmux.sh"
}
