# ~/.config/fish/config.fish
#
# 组织方式（自上而下）：
#   1. 内部小工具
#   2. 环境变量：通用 / 平台相关
#   3. PATH：通用 / 平台相关
#   4. 平台分发
#   5. 第三方集成（xmake、coco …）
#   6. 用户面向的命令（setproxy / unsetproxy）
#   7. 交互式专属（aliases、prompt、补全生成）

# -------- 1. 内部小工具 --------

function __add_path_if_exists --argument-names dir
    test -n "$dir"; and test -d $dir; and fish_add_path --path $dir
end

# -------- 2. 环境变量设置 --------

function __setup_env_common
    set -q LC_CTYPE; or set -gx LC_CTYPE en_US.UTF-8
    set -q LC_ALL;   or set -gx LC_ALL   en_US.UTF-8
    set -q RUSTUP_DIST_SERVER; or set -gx RUSTUP_DIST_SERVER https://cloudfront-static.rust-lang.org
    set -e TMOUT
end

function __setup_env_unix
    set -gx EDITOR vim
end

function __setup_env_linux
end

function __setup_env_macos
    set -q BASH_SILENCE_DEPRECATION_WARNING; or set -gx BASH_SILENCE_DEPRECATION_WARNING 1
end

# -------- 3. PATH 设置 --------

function __setup_path_common
    __add_path_if_exists ~/.cargo/bin
    __add_path_if_exists ~/.local/bin
    if type -q go
        __add_path_if_exists (go env GOPATH)/bin
    end
end

function __setup_path_unix
    __add_path_if_exists /usr/local/go/bin
    __add_path_if_exists ~/go/bin
    __add_path_if_exists ~/.deno/bin
end

function __setup_path_linux
    __add_path_if_exists /usr/local/bin
end

function __setup_path_macos
    if test -x /opt/homebrew/bin/brew
        eval (/opt/homebrew/bin/brew shellenv)
    end
    __add_path_if_exists /opt/homebrew/opt/make/libexec/gnubin
end

# -------- 4. 平台分发 --------

switch (uname)
    case Linux
        __setup_env_linux
        __setup_env_unix
        __setup_path_linux
        __setup_path_unix
    case Darwin
        __setup_env_macos
        __setup_env_unix
        __setup_path_macos
        __setup_path_unix
    case '*'
        # Windows / 未知平台：当前没有特殊处理
end
__setup_env_common
__setup_path_common

# -------- 5. 第三方集成 --------

# xmake 自动加载
test -f ~/.xmake/profile; and source ~/.xmake/profile

# -------- 6. 用户命令 --------

function setproxy -d "set http(s) proxy to 127.0.0.1:<port>"
    if test (count $argv) -ne 1
        echo "usage: setproxy <port>" >&2
        return 1
    end
    set -gx http_proxy  http://127.0.0.1:$argv[1]
    set -gx https_proxy $http_proxy
    set -gx HTTP_PROXY  $http_proxy
    set -gx HTTPS_PROXY $http_proxy
end

function unsetproxy -d "unset http(s) proxy"
    set -e http_proxy https_proxy HTTP_PROXY HTTPS_PROXY
end

# 把某个已安装的 Node 版本设为所有 fish 的默认。
# 原理：写入 universal 变量 nvm_default_version，conf.d/nvm.fish 在每个新 shell
# 启动时会自动 `nvm use --silent $nvm_default_version`。
#
# 用法：
#   nvm_set_default              # 用当前激活的版本作为默认
#   nvm_set_default lts          # 别名
#   nvm_set_default 20           # 任何 _nvm_version_match 能匹配的写法
#   nvm_set_default v20.11.0
#   nvm_set_default system       # 使用系统自带 node
function nvm_set_default -d "Persist a default Node version across all fish shells"
    if not type -q nvm
        echo "nvm_set_default: nvm is not available" >&2
        return 1
    end

    set -l ver $argv[1]
    if not set -q ver[1]
        if set -q nvm_current_version
            set ver $nvm_current_version
        else
            echo "nvm_set_default: no version specified and no active node version" >&2
            echo "usage: nvm_set_default <version>   # e.g. lts | 20 | v20.11.0 | system" >&2
            return 1
        end
    end

    # 解析并校验：以 `nvm ls` 为准，存在即可设为默认
    set -l resolved
    _nvm_list | string match --entire --regex -- (_nvm_version_match $ver) | read resolved __

    if not set -q resolved[1]
        echo "nvm_set_default: \"$ver\" is not installed (checked via nvm ls)" >&2
        echo "  run: nvm install $ver" >&2
        return 1
    end

    set -Ux nvm_default_version $resolved
    echo "nvm_default_version = $resolved  (universal; new fish shells will auto-activate)"

    # 当前 shell 立即生效
    if test "$resolved" != "$nvm_current_version"
        nvm use --silent $resolved
    end
end

# -------- 7. 交互式专属 --------

if status is-interactive
    # 关闭欢迎语（universal，只写一次）
    set -q fish_greeting; or set -U fish_greeting

    # aliases
    alias t='tmux'
    alias z='zellij'
    alias ll='ls -alF'
    alias hs='history --merge'

    # 重载 fish（替换当前进程，重新读 config.fish）
    abbr -a r 'exec fish'

    # 强制对齐 nvm_default_version：
    # conf.d/nvm.fish 自带的自动激活在 nvm_current_version 已被父进程
    # 环境继承时不会触发，导致新 shell 仍用旧版本。这里兜底纠正。
    if type -q nvm; and set -q nvm_default_version
        if test "$nvm_current_version" != "$nvm_default_version"
            nvm use --silent $nvm_default_version
        end
    end

    # 当 nvm_default_version 被任何 fish 改写（universal 变量会同步到所有正在跑的
    # fish），各个已存在的交互式 shell 也跟着切到新版本，免得需要 `exec fish`。
    function __nvm_sync_default --on-variable nvm_default_version
        type -q nvm; or return
        set -q nvm_default_version; or return
        test "$nvm_current_version" = "$nvm_default_version"; and return
        nvm use --silent $nvm_default_version
    end

    # 自定义 prompt
    function fish_prompt --description 'Write out the prompt'
        set -l last_status $status
        set -l normal       (set_color normal)
        set -l status_color (set_color brgreen)
        set -l cwd_color    (set_color $fish_color_cwd)
        set -l vcs_color    (set_color brpurple)
        set -l prompt_status ""

        # 单独一行展示，路径不截断
        set -q fish_prompt_pwd_dir_length
        or set -lx fish_prompt_pwd_dir_length 0

        set -l suffix '❯'
        if functions -q fish_is_root_user; and fish_is_root_user
            if set -q fish_color_cwd_root
                set cwd_color (set_color $fish_color_cwd_root)
            end
            set suffix '#'
        end

        if test $last_status -ne 0
            set status_color (set_color $fish_color_error)
            set prompt_status $status_color "[" $last_status "]" $normal
        end

        echo -s (prompt_login) ' ' $cwd_color (prompt_pwd) $vcs_color (fish_vcs_prompt) $normal ' ' $prompt_status
        echo -n -s $status_color $suffix ' ' $normal
    end

    # flamegraph 补全：仅生成一次
    if type -q flamegraph
        set -l __fg_completion $fish_complete_path[1]/flamegraph.fish
        if not test -e $__fg_completion
            flamegraph --completions fish >$__fg_completion
        end
        set -e __fg_completion
    end
end
