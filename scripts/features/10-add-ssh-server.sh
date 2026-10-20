FEATURE_NAME="add-ssh-server"
FEATURE_DESC="Add an SSH host interactively from 'user@host:port via jump' or a pasted ssh command"

source "$GROUP_DIR/features/_bin.sh"
apply() { need_cmd python3; bin_install add-ssh-server.py; }
