# Managed by configs/shell (paths). Adds tool folders to PATH once each,
# and only if they exist.
__configs_path_add() {  # __configs_path_add DIR [append]
    [ -d "$1" ] || return 0
    case ":$PATH:" in *":$1:"*) return 0 ;; esac
    if [ "${2:-}" = append ]; then PATH="$PATH:$1"; else PATH="$1:$PATH"; fi
}
__configs_path_add "$HOME/.local/bin"
__configs_path_add "$HOME/.npm-global/bin"
__configs_path_add /usr/local/go/bin append
__configs_path_add "$HOME/go/bin" append
__configs_path_add "$HOME/.config/orca/linux-orca-cli-shim" append
export PATH
unset -f __configs_path_add
