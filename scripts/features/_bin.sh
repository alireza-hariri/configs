# Shared by the scripts features: copy scripts from bin/ into BIN_DIR.
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"

bin_install() {
    local n
    for n in "$@"; do
        put_file "$GROUP_DIR/bin/$n" "$BIN_DIR/$n" 755
        ok "$BIN_DIR/$n"
    done
    case ":$PATH:" in
        *":$BIN_DIR:"*) ;;
        *) warn "$BIN_DIR is not on PATH (the shell group's 'paths' feature adds it)" ;;
    esac
}
