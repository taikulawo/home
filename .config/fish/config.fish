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

alias t="tmux"
alias z="zellij"
alias ll="ls -alF"
alias hs 'history --merge'  # read and merge history from disk

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
    fish_add_path --path /usr/local/bin
end

function set_windows

end

function setproxy -d "set http proxy to"
    set -gx http_proxy http://127.0.0.1:$argv[1]
    set -gx https_proxy http://127.0.0.1:$argv[1]
    set -gx HTTP_PROXY http://127.0.0.1:$argv[1]
    set -gx HTTPS_PROXY http://127.0.0.1:$argv[1]
end

function unsetproxy -d "unset http proxy"
    unset_proxy
end

function set_unix
    fish_add_path --path /usr/local/go/bin
    fish_add_path --path ~/go/bin
    if test -d ~/.deno/bin
        fish_add_path --path ~/.deno/bin
    end
end


function set_macos
    set -Ux BASH_SILENCE_DEPRECATION_WARNING 1
    eval    (/opt/homebrew/bin/brew shellenv)
    fish_add_path --path /opt/homebrew/opt/make/libexec/gnubin
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
fish_add_path --path ~/.cargo/bin
fish_add_path --path $(go env GOPATH)/bin

# -g Sets a globally-scoped variable. Global variables are available to all functions running in the same shell.
# -x export to child process.
set -Ux LC_CTYPE en_US.UTF-8
set -Ux LC_ALL en_US.UTF-8

# rust mirror
# set -Ux RUSTUP_DIST_SERVER https://rsproxy.cn
# set -Ux RUSTUP_UPDATE_ROOT https://rsproxy.cn/rustup

if type -q flamegraph
flamegraph --completions fish > $fish_complete_path[1]/flamegraph.fish
end
