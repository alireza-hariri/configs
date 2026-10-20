# Managed by configs/shell (history). Big, timestamped history shared
# between open terminals.
HISTSIZE=100000            # in memory (was never set; HISTFILESIZE was set twice)
HISTFILESIZE=500000        # on disk
HISTCONTROL=ignoreboth     # skip duplicates and lines starting with a space
HISTIGNORE='ls:ll:bg:fg:clear:exit:pwd:history'
HISTTIMEFORMAT='%F %T '
shopt -s histappend cmdhist

# Append new lines and read other terminals' new lines at every prompt.
# "history -n" reads only what is new, instead of reloading the whole
# 500k-line file each time like "history -c; history -r" did.
__configs_hist_sync() { history -a; history -n; }
case ";${PROMPT_COMMAND:-};" in
    *";__configs_hist_sync;"*) ;;
    *) PROMPT_COMMAND="__configs_hist_sync${PROMPT_COMMAND:+;$PROMPT_COMMAND}" ;;
esac
