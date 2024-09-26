platform=$(uname)

if [[ "$platform" == "Darwin" ]]; then
    export PATH=/opt/homebrew/bin/:$PATH
elif [[ "$platform" == "Linux" ]]; then
    
else
    # windows?
fi
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

. "$HOME/.cargo/env"
