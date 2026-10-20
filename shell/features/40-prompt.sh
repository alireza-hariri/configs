FEATURE_NAME="Prompt"
FEATURE_DESC="[user@host dir] in green, with the exit code in red after a failed command"

apply() {
    bashrc_d_install 40-prompt "$GROUP_DIR/files/prompt.sh"
}
