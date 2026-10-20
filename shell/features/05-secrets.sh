FEATURE_NAME="Secrets loader"
FEATURE_DESC="Loads API keys from ~/.secrets.env (chmod 600), so keys stay out of .bashrc and out of git"

apply() {
    bashrc_d_install 05-secrets "$GROUP_DIR/files/secrets.sh"
    seed_text "$HOME/.secrets.env" 600 <<'TXT'
# API keys and tokens, one KEY=value per line. Loaded by ~/.bashrc.d/05-secrets.sh.
# Keep this file private (chmod 600) and never commit it.
# EXAMPLE_API_KEY=...
TXT
    chmod 600 "$HOME/.secrets.env"
    ok "put your keys in ~/.secrets.env (it is kept on uninstall)"
}
