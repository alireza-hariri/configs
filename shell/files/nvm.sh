# Managed by configs/shell (nvm). Puts nvm's default Node on PATH without
# loading nvm itself (that costs ~100ms per shell); the first "nvm" command
# loads it. Set the default once with: nvm alias default lts/*
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    __configs_nvm_default() {
        local a="default" i
        for i in 1 2 3 4 5 6; do
            case "$a" in
                v[0-9]*) break ;;
                node|stable) a="$(ls "$NVM_DIR/versions/node" 2>/dev/null | sort -V | tail -n1)"; break ;;
                [0-9]*) a="$(ls "$NVM_DIR/versions/node" 2>/dev/null | grep -E "^v${a//./\\.}(\.|$)" | sort -V | tail -n1)"; break ;;
                *) [ -r "$NVM_DIR/alias/$a" ] || return 1; read -r a < "$NVM_DIR/alias/$a" ;;
            esac
        done
        [ -n "$a" ] && [ -d "$NVM_DIR/versions/node/$a/bin" ] && printf '%s' "$a"
    }
    __configs_nvm_v="$(__configs_nvm_default)"
    if [ -n "$__configs_nvm_v" ]; then
        case ":$PATH:" in
            *":$NVM_DIR/versions/node/$__configs_nvm_v/bin:"*) ;;
            *) PATH="$NVM_DIR/versions/node/$__configs_nvm_v/bin:$PATH" ;;
        esac
        export NVM_BIN="$NVM_DIR/versions/node/$__configs_nvm_v/bin"
    fi
    unset __configs_nvm_v
    unset -f __configs_nvm_default

    nvm() {
        unset -f nvm
        . "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
        nvm "$@"
    }
fi
