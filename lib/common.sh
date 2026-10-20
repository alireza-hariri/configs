# Shared runner and helpers for every config group.
#
# A group is a folder with install.sh, uninstall.sh and features/NN-<id>.sh.
# A feature file sets FEATURE_NAME / FEATURE_DESC and defines apply().
# It may also define revert() and is_applied(); the defaults below replay
# the undo log that the helpers (put_file, block_set, kset, ...) write, so
# most features only need apply().

CONFIGS_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIGS_STATE="${XDG_STATE_HOME:-$HOME/.local/state}/configs"
# shellcheck source=menu.sh
source "$CONFIGS_LIB/menu.sh"

log()  { printf '\033[1;34m::\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m  ✓\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m  !\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m  ✗\033[0m %s\n' "$*" >&2; exit 1; }

need_cmd() {
    local c
    for c in "$@"; do
        command -v "$c" >/dev/null 2>&1 || die "'$c' is required but not installed"
    done
}

# ask_yn "Question" [Y|N]  -> 0 for yes. Uses the default when there is no tty.
ask_yn() {
    local q="$1" def="${2:-Y}" ans hint="[Y/n]"
    [[ "$def" == N ]] && hint="[y/N]"
    if [[ "${CONFIGS_YES:-0}" == 1 ]] || ! { : </dev/tty; } 2>/dev/null; then
        [[ "$def" == Y ]]; return
    fi
    read -rp "  $q $hint " ans </dev/tty
    ans="${ans:-$def}"
    [[ "$ans" =~ ^[Yy] ]]
}

# ask "Question" default -> prints the answer
ask() {
    local q="$1" def="${2:-}" ans
    if [[ "${CONFIGS_YES:-0}" == 1 ]] || ! { : </dev/tty; } 2>/dev/null; then
        printf '%s' "$def"; return
    fi
    read -rp "  $q${def:+ [$def]}: " ans </dev/tty
    printf '%s' "${ans:-$def}"
}

# ---------------------------------------------------------------- undo log
#
# Each helper records how to undo its change once per resource, the first
# time it touches it, so re-running apply keeps the original backup.

_undo_file_path() { printf '%s/undo' "$FEATURE_STATE"; }

# undo_once KEY CMD ARGS...  -- append "CMD ARGS" to the undo log unless KEY was seen
undo_once() {
    local key="$1"; shift
    mkdir -p "$FEATURE_STATE"
    if [[ -f "$FEATURE_STATE/seen" ]] && grep -qxF -- "$key" "$FEATURE_STATE/seen"; then
        return 0
    fi
    printf '%s\n' "$key" >> "$FEATURE_STATE/seen"
    printf '%q ' "$@" >> "$(_undo_file_path)"
    printf '\n' >> "$(_undo_file_path)"
}

run_undo() {
    local f; f="$(_undo_file_path)"
    [[ -f "$f" ]] || return 0
    local line rc=0
    while IFS= read -r line; do
        [[ -n "$line" ]] || continue
        eval "$line" || { warn "undo step failed: $line"; rc=1; }
    done < <(tac "$f")
    return $rc
}

_sha() { sha256sum "$1" 2>/dev/null | cut -d' ' -f1; }

# ---------------------------------------------------------------- files

# put_file SRC DEST [MODE] -- install a file, backing up whatever was there
put_file() {
    local src="$1" dest="$2" mode="${3:-}"
    mkdir -p "$FEATURE_STATE/backup" "$(dirname "$dest")"
    local bak="$FEATURE_STATE/backup/$(printf '%s' "$dest" | sha1sum | cut -c1-16)"
    if [[ -e "$dest" || -L "$dest" ]]; then
        if ! cmp -s "$src" "$dest"; then
            [[ -e "$bak" ]] || cp -a "$dest" "$bak"
        fi
        undo_once "file:$dest" _undo_file "$dest" "$bak"
    else
        undo_once "file:$dest" _undo_file "$dest" ""
    fi
    install -m "${mode:-644}" "$src" "$dest"
    # Remember what we wrote, so revert can tell if the user edited it since.
    _sha "$dest" > "$bak.installed"
}

# put_text DEST [MODE] <<EOF ... -- like put_file, content from stdin
put_text() {
    local tmp; tmp="$(mktemp)"
    cat > "$tmp"
    put_file "$tmp" "$@"
    rm -f "$tmp"
}

# seed_text DEST [MODE] <<EOF ... -- create a file the user is meant to edit.
# Never overwritten and never removed on revert.
seed_text() {
    local dest="$1" mode="${2:-644}"
    if [[ -e "$dest" ]]; then cat >/dev/null; return 0; fi
    mkdir -p "$(dirname "$dest")"
    (umask 077; cat > "$dest")
    chmod "$mode" "$dest"
    ok "created $dest"
}

_undo_file() {
    local dest="$1" bak="$2" key
    key="$FEATURE_STATE/backup/$(printf '%s' "$dest" | sha1sum | cut -c1-16)"
    if [[ -f "$dest" && -f "$key.installed" && "$(_sha "$dest")" != "$(cat "$key.installed")" ]]; then
        local keep; keep="$dest.configs-modified.$(date +%Y%m%d%H%M%S)"
        cp -a "$dest" "$keep"
        warn "$dest was edited after install; kept your version as $keep"
    fi
    if [[ -n "$bak" && -e "$bak" ]]; then
        cp -a "$bak" "$dest" && ok "restored $dest"
    elif [[ -n "$bak" ]]; then
        # Was there before but identical to ours: leave it.
        :
    else
        rm -f "$dest" && ok "removed $dest"
        rmdir -p --ignore-fail-on-non-empty "$(dirname "$dest")" 2>/dev/null || true
    fi
}

# ---------------------------------------------------------------- marked blocks

# block_set FILE NAME [--top] <<EOF ... -- insert/replace a marked block
block_set() {
    local file="$1" name="$2" where="${3:-}" body tmp
    body="$(cat)"
    if [[ -e "$file" ]]; then
        undo_once "block:$file:$name" _undo_block "$file" "$name" 0
    else
        undo_once "block:$file:$name" _undo_block "$file" "$name" 1
        mkdir -p "$(dirname "$file")"; : > "$file"
    fi
    tmp="$(mktemp)"
    _block_strip "$file" "$name" > "$tmp"
    {
        if [[ "$where" == --top ]]; then
            printf '# >>> configs:%s >>>\n%s\n# <<< configs:%s <<<\n' "$name" "$body" "$name"
            cat "$tmp"
        else
            cat "$tmp"
            [[ -s "$tmp" && -n "$(tail -c1 "$tmp")" ]] && printf '\n'
            printf '# >>> configs:%s >>>\n%s\n# <<< configs:%s <<<\n' "$name" "$body" "$name"
        fi
    } > "$tmp.new"
    cat "$tmp.new" > "$file"   # keep the original inode and permissions
    rm -f "$tmp" "$tmp.new"
}

block_has() { grep -qxF "# >>> configs:$2 >>>" "$1" 2>/dev/null; }

_block_strip() {
    awk -v b="# >>> configs:$2 >>>" -v e="# <<< configs:$2 <<<" '
        $0 == b { skip = 1; next }
        $0 == e { skip = 0; next }
        !skip
    ' "$1"
}

_undo_block() {
    local file="$1" name="$2" created="$3" tmp
    [[ -f "$file" ]] || return 0
    tmp="$(mktemp)"
    _block_strip "$file" "$name" > "$tmp"
    cat "$tmp" > "$file"; rm -f "$tmp"
    if [[ "$created" == 1 && ! -s "$file" ]]; then rm -f "$file"; fi
    ok "removed configs:$name block from $file"
}

# ---------------------------------------------------------------- KDE config

_KUNSET=$'\x1f__configs_unset__'

# kset FILE "GROUP[/SUBGROUP...]" KEY VALUE -- kwriteconfig6, remembering the old value
kset() {
    local file="$1" groups="$2" key="$3" value="$4" g gargs=() old x
    IFS=/ read -ra g <<< "$groups"
    for x in "${g[@]}"; do gargs+=(--group "$x"); done
    local path="$file"
    [[ "$path" == /* ]] || path="${XDG_CONFIG_HOME:-$HOME/.config}/$file"
    # Recorded before the key, so on revert it runs after all keys are restored.
    [[ -e "$path" ]] || undo_once "kfile:$path" _undo_kfile "$path"
    old="$(kreadconfig6 --file "$file" "${gargs[@]}" --key "$key" --default "$_KUNSET")"
    undo_once "kconf:$file:$groups:$key" _undo_kset "$file" "$groups" "$key" "$old"
    kwriteconfig6 --file "$file" "${gargs[@]}" --key "$key" "$value"
}

_undo_kset() {
    local file="$1" groups="$2" key="$3" old="$4" g gargs=() x
    IFS=/ read -ra g <<< "$groups"
    for x in "${g[@]}"; do gargs+=(--group "$x"); done
    if [[ "$old" == "$_KUNSET" ]]; then
        kwriteconfig6 --file "$file" "${gargs[@]}" --key "$key" --delete
    else
        kwriteconfig6 --file "$file" "${gargs[@]}" --key "$key" "$old"
    fi
}

# A config file kset created: remove it again if only empty groups are left.
_undo_kfile() {
    [[ -f "$1" ]] || return 0
    if ! grep -qvE '^\s*$|^\s*\[.*\]\s*$' "$1"; then
        rm -f "$1"
        rmdir "$(dirname "$1")" 2>/dev/null || true
    fi
}

# ---------------------------------------------------------------- ~/.bashrc.d

BASHRC_D="$HOME/.bashrc.d"

# bashrc_d_install NAME SRC -- drop SRC into ~/.bashrc.d/NAME.sh and make
# sure ~/.bashrc loads that folder.
bashrc_d_install() {
    local name="$1" src="$2"
    # Recorded first so that, undone in reverse, it runs after the file is gone.
    undo_once "bashrc.d-loader" _undo_bashrc_d
    put_file "$src" "$BASHRC_D/$name.sh"
    if ! block_has "$HOME/.bashrc" bashrc.d; then
        # Not recorded in the undo log: the loader is shared between
        # features and is removed by _undo_bashrc_d once the folder is empty.
        local FEATURE_STATE="$CONFIGS_STATE/.shared"
        block_set "$HOME/.bashrc" bashrc.d <<'EOF'
for __f in "$HOME"/.bashrc.d/*.sh; do [ -r "$__f" ] && . "$__f"; done
unset __f
EOF
    fi
}

_undo_bashrc_d() {
    compgen -G "$BASHRC_D/*.sh" >/dev/null && return 0
    _undo_block "$HOME/.bashrc" bashrc.d 0
    [[ -s "$HOME/.bashrc" ]] || rm -f "$HOME/.bashrc"
    rmdir "$BASHRC_D" 2>/dev/null || true
}

# ---------------------------------------------------------------- runner

_feature_id() { local b; b="$(basename "$1" .sh)"; printf '%s' "${b#[0-9][0-9]-}"; }

# Run one function of a feature in an isolated subshell.
_feature_call() {
    local file="$1" fn="$2"
    (
        set -euo pipefail
        FEATURE_ID="$(_feature_id "$file")"
        FEATURE_STATE="$CONFIGS_STATE/$GROUP/$FEATURE_ID"
        FEATURE_FILE="$file"
        apply() { die "feature has no apply()"; }
        revert() { run_undo; }
        is_applied() { [[ -f "$FEATURE_STATE/applied" ]]; }
        # shellcheck disable=SC1090
        source "$file"
        "$fn"
    )
}

_feature_meta() {
    ( FEATURE_NAME=""; FEATURE_DESC=""; source "$1" >/dev/null 2>&1
      printf '%s\t%s\n' "${FEATURE_NAME:-$(_feature_id "$1")}" "$FEATURE_DESC" )
}

_usage() {
    cat <<EOF
Usage: $1 [options] [feature ...]

With no feature names an interactive menu is shown.

  -a, --all     select every feature (install) / every installed one (uninstall)
  -l, --list    list features and whether they are installed
  -y, --yes     do not ask questions, take the defaults
  -h, --help    this help
EOF
}

# configs_run install|uninstall GROUP_DIR [args...]
configs_run() {
    local mode="$1" dir="$2"; shift 2
    GROUP_DIR="$dir"
    GROUP="$(basename "$dir")"
    export GROUP GROUP_DIR

    local all=0 list=0 names=() f
    while (( $# )); do
        case "$1" in
            -a|--all) all=1 ;;
            -l|--list) list=1 ;;
            -y|--yes) export CONFIGS_YES=1 ;;
            -h|--help) _usage "$mode.sh"; return 0 ;;
            -*) die "unknown option: $1" ;;
            *) names+=("$1") ;;
        esac
        shift
    done

    local files=() ids=() titles=() descs=() states=()
    for f in "$dir"/features/[0-9][0-9]-*.sh; do
        [[ -e "$f" ]] || continue
        local meta; meta="$(_feature_meta "$f")"
        files+=("$f"); ids+=("$(_feature_id "$f")")
        titles+=("${meta%%$'\t'*}"); descs+=("${meta#*$'\t'}")
        if _feature_call "$f" is_applied >/dev/null 2>&1; then states+=(1); else states+=(0); fi
    done
    (( ${#files[@]} )) || die "no features in $dir/features"

    local i
    if (( list )); then
        for i in "${!files[@]}"; do
            printf '%-22s %-10s %s\n' "${ids[i]}" "$( (( states[i] )) && echo installed || echo -)" "${titles[i]}"
        done
        return 0
    fi

    # Candidates: everything for install, only installed features for uninstall.
    local cand=()
    for i in "${!files[@]}"; do
        if [[ "$mode" == install ]] || (( states[i] )); then cand+=("$i"); fi
    done
    if (( ${#cand[@]} == 0 )); then log "Nothing from '$GROUP' is installed."; return 0; fi

    local chosen=()
    if (( ${#names[@]} )); then
        local n found
        for n in "${names[@]}"; do
            found=0
            for i in "${cand[@]}"; do [[ "${ids[i]}" == "$n" ]] && { chosen+=("$i"); found=1; }; done
            (( found )) || die "unknown or not installed feature: $n (see --list)"
        done
    elif (( all )); then
        chosen=("${cand[@]}")
    else
        { : </dev/tty; } 2>/dev/null || die "no terminal for the menu; pass feature names or --all"
        MENU_LABELS=(); MENU_DESCS=(); MENU_SELECTED=()
        for i in "${cand[@]}"; do
            local tag=""
            [[ "$mode" == install ]] && (( states[i] )) && tag="  (installed)"
            MENU_LABELS+=("$(printf '%-20s %s%s' "${ids[i]}" "${titles[i]}" "$tag")")
            MENU_DESCS+=("${descs[i]}")
            MENU_SELECTED+=(0)
        done
        local verb="install"; [[ "$mode" == uninstall ]] && verb="remove"
        menu_select "configs/$GROUP: choose what to $verb" || { log "Cancelled."; return 0; }
        local k
        for k in "${!cand[@]}"; do (( MENU_SELECTED[k] )) && chosen+=("${cand[k]}"); done
    fi
    (( ${#chosen[@]} )) || { log "Nothing selected."; return 0; }

    # Revert in reverse order so later features come off first.
    if [[ "$mode" == uninstall ]]; then
        local rev=()
        for (( i = ${#chosen[@]} - 1; i >= 0; i-- )); do rev+=("${chosen[i]}"); done
        chosen=("${rev[@]}")
    fi

    # shellcheck disable=SC1091
    [[ -f "$dir/hooks.sh" ]] && source "$dir/hooks.sh"
    [[ "$(type -t group_before)" == function ]] && group_before "$mode"

    # Not "if _feature_call": bash ignores set -e inside a subshell that is
    # used as a condition, so a failing step would not stop the feature.
    local failed=() state rc
    for i in "${chosen[@]}"; do
        state="$CONFIGS_STATE/$GROUP/${ids[i]}"
        if [[ "$mode" == install ]]; then
            log "Installing ${ids[i]}: ${titles[i]}"
            set +e; _feature_call "${files[i]}" apply; rc=$?; set -e
            if (( rc == 0 )); then
                mkdir -p "$state"; date -Is > "$state/applied"
            else
                failed+=("${ids[i]}")
            fi
        else
            log "Removing ${ids[i]}: ${titles[i]}"
            set +e; _feature_call "${files[i]}" revert; rc=$?; set -e
            if (( rc == 0 )); then
                rm -rf "$state"
            else
                failed+=("${ids[i]}")
            fi
        fi
    done

    [[ "$(type -t group_after)" == function ]] && group_after "$mode"

    if (( ${#failed[@]} )); then
        warn "failed: ${failed[*]}"
        return 1
    fi
    log "Done."
}
