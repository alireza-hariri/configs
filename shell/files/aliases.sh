# Managed by configs/shell (aliases).
alias ls='ls --color=auto'
alias ll='ls -hal'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias df1='df --type btrfs --type ext4 --type xfs -h'

if command -v pz >/dev/null 2>&1; then
    alias pzl='pz -g 1'
    alias unixtime='pz -g 1 "import time;s=time.time()"'
fi

# Activate the nearest .venv, looking in this folder and its parents.
act() {
    local d="$PWD"
    while [ -n "$d" ]; do
        if [ -f "$d/.venv/bin/activate" ]; then
            . "$d/.venv/bin/activate"
            return
        fi
        d="${d%/*}"
    done
    echo "act: no .venv found here or in any parent folder" >&2
    return 1
}
