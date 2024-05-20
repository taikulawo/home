if status is-interactive
    # Commands to run in interactive sessions can go here
    function fish_prompt --description 'Write out the prompt'
        set -U fish_greeting
        set -l last_status $status
        set -l normal (set_color normal)
        set -l status_color (set_color brgreen)
        set -l cwd_color (set_color $fish_color_cwd)
        set -l vcs_color (set_color brpurple)
        set -l prompt_status ""

        # Since we display the prompt on a new line allow the directory names to be longer.
        set -q fish_prompt_pwd_dir_length
        or set -lx fish_prompt_pwd_dir_length 0

        # Color the prompt differently when we're root
        set -l suffix '❯'
        if functions -q fish_is_root_user; and fish_is_root_user
            if set -q fish_color_cwd_root
                set cwd_color (set_color $fish_color_cwd_root)
            end
            set suffix '#'
        end

        # Color the prompt in red on error
        if test $last_status -ne 0
            set status_color (set_color $fish_color_error)
            set prompt_status $status_color "[" $last_status "]" $normal
        end

        echo -s (prompt_login) ' ' $cwd_color (prompt_pwd) $vcs_color (fish_vcs_prompt) $normal ' ' $prompt_status
        echo -n -s $status_color $suffix ' ' $normal
    end
end

# function export
# # fish 的 $PATH 是 list，不是 : 分割的字符串
# # export PATH=$PATH 会报错
# # 如果对export有硬需求，用bash
#     if [ $argv ] 
#         set var (printenv $argv | cut -f1 -d=)
#         set val (printenv $argv | cut -f2 -d=)
#         set -g -x $var $val
#     else
#         echo 'export var=value'
#     end
# end

alias t="tmux"
alias ll="ls -alF"
alias hs 'history --merge'  # read and merge history from disk
# 安装nvm/node
set -l checknvm (nvm list lts)
if test -n "$checknvm"
    nvm use lts -s
# else
#     nvm install lts
end

function use_proxy
end

function unset_proxy
    set -e HTTP_PROXY
    set -e HTTPS_PROXY
    set -e http_proxy
    set -e https_proxy
end

# load xmake
if test -f ~/.xmake/profile
    source ~/.xmake/profile
end

function set_linux
    set PATH /usr/local/bin $PATH
    set PATH /usr/local/go/bin $PATH
    set PATH ~/go/bin $PATH
end

function set_windows
    
end

function setproxy -d "set http proxy to"
    set -g -x http_proxy http://127.0.0.1:$argv[1]
    set -g -x https_proxy http://127.0.0.1:$argv[1]
    set -g -x HTTP_PROXY http://127.0.0.1:$argv[1]
    set -g -x HTTPS_PROXY http://127.0.0.1:$argv[1]
end

function unsetproxy -d "unset http proxy"
    unset_proxy
end

function set_unix
    if test -d ~/.deno/bin
        set PATH ~/.deno/bin $PATH
    end
end


function set_macos
    set -Ux BASH_SILENCE_DEPRECATION_WARNING 1
    eval    (/opt/homebrew/bin/brew shellenv)
    set PATH /opt/homebrew/opt/make/libexec/gnubin $PATH 
end

switch (uname)
    case Linux
        set_linux
        set_unix
    case Darwin
        set_macos
        set_unix
    case '*'
        echo "At ~/.config/fish/config.fish, unknown os detected, assume Windows"
        set_windows
end
set PATH ~/.cargo/bin $PATH
set PATH /usr/local/go/bin $PATH
set GOROOT $HOME/go
set GOPATH $GOROOT/src
set PATH $GOROOT/bin $PATH

set LC_CTYPE en_US.UTF-8
set LC_ALL en_US.UTF-8
set RUSTUP_DIST_SERVER https://rsproxy.cn
set RUSTUP_UPDATE_ROOT https://rsproxy.cn/rustup
