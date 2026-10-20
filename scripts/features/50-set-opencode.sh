FEATURE_NAME="set-opencode"
FEATURE_DESC="Switch opencode's OpenRouter key, base URL and model from a menu (keys come from env vars)"

source "$GROUP_DIR/features/_bin.sh"
apply() { need_cmd python3; bin_install set-opencode.py; }
