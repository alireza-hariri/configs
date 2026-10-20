# Managed by configs/shell (secrets). Loads API keys from ~/.secrets.env,
# which stays on this machine and is never committed anywhere.
if [ -r "$HOME/.secrets.env" ]; then
    case "$(stat -c %a "$HOME/.secrets.env" 2>/dev/null)" in
        600|400) ;;
        *) echo "warning: ~/.secrets.env is readable by others; run: chmod 600 ~/.secrets.env" >&2 ;;
    esac
    set -a
    . "$HOME/.secrets.env"
    set +a
fi
