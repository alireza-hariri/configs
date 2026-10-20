# Managed by configs/shell (herdr). Bash completion for herdr, cached and
# regenerated whenever the herdr binary is updated.
if __configs_herdr="$(command -v herdr 2>/dev/null)"; then
    __configs_herdr_cache="${XDG_CACHE_HOME:-$HOME/.cache}/configs/herdr-completion.bash"
    if [ ! -s "$__configs_herdr_cache" ] || [ "$__configs_herdr" -nt "$__configs_herdr_cache" ]; then
        mkdir -p "${__configs_herdr_cache%/*}"
        herdr completion bash > "$__configs_herdr_cache" 2>/dev/null || rm -f "$__configs_herdr_cache"
    fi
    [ -s "$__configs_herdr_cache" ] && . "$__configs_herdr_cache"
fi
unset __configs_herdr __configs_herdr_cache
