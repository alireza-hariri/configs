FEATURE_NAME="Python (uv)"
FEATURE_DESC="Install Python $(cat "$GROUP_DIR/files/python-version" 2>/dev/null) with uv and pin it as the global default"

source "$GROUP_DIR/features/_uv.sh"

apply() {
    ensure_uv
    local ver; ver="$(cat "$GROUP_DIR/files/python-version")"
    if compgen -G "$(uv python dir)/cpython-$ver.*" >/dev/null; then
        ok "Python $ver already installed by uv"
    else
        uv python install "$ver"
        undo_once "python:$ver" uv python uninstall "$ver"
    fi
    # Same file "uv python pin --global" writes.
    printf '%s\n' "$ver" | put_text "${XDG_CONFIG_HOME:-$HOME/.config}/uv/.python-version"
    ok "global default: Python $ver (uv run / uv venv outside projects)"
}
