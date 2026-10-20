FEATURE_NAME="Git LFS + Xet"
FEATURE_DESC="git-lfs filters, 3 parallel transfers, and the git-xet transfer agent for Hugging Face repos"

source "$GROUP_DIR/features/_include.sh"
apply() {
    command -v git-lfs >/dev/null || warn "git-lfs is not installed (pacman -S git-lfs)"
    command -v git-xet >/dev/null || warn "git-xet is not installed; Xet repos will fall back to plain LFS"
    git_include lfs "$GROUP_DIR/files/lfs.gitconfig"
}
