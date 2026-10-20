# Managed by configs/shell (prompt). [user@host dir] in green, plus a red
# exit code when the last command failed.
__configs_prompt_status() {
    local s=$?
    [ "$s" -ne 0 ] && printf '\001\033[01;31m\002%s \001\033[0m\002' "$s"
    return 0
}
PS1='$(__configs_prompt_status)[\[\033[01;32m\]\u\[\033[0m\]@\[\033[01;32m\]\h \W\[\033[0m\]] '
