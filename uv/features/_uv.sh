# Shared by the uv features: make sure uv is available.
ensure_uv() {
    command -v uv >/dev/null && return 0
    [[ -x "$HOME/.local/bin/uv" ]] && { PATH="$HOME/.local/bin:$PATH"; return 0; }
    ask_yn "uv is not installed. Install it now with the official installer (astral.sh)?" Y \
        || die "uv is required"
    need_cmd curl
    curl -LsSf https://astral.sh/uv/install.sh | sh
    PATH="$HOME/.local/bin:$PATH"
    command -v uv >/dev/null || die "uv install failed"
}
