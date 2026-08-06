# ~/.config/fish/conf.d/trae.fish
#
# 为 TRAE CLI 的 ai-contribution 上报插件推导上报身份。
# 插件优先级：AI_CONTRIBUTION_USERNAME > git user.email > $USER 等
# 参见 ~/.trae/plugins/.../ai_contribution_sdk_adapter.js:detectUsername

function __trae_sync_ai_contribution_username --on-variable PWD
    set -l resolved_email

    # 场景 1：当前目录本身是 git 仓库，直接用其 user.email
    set -l current_email (command git -C "$PWD" config --get user.email 2>/dev/null)
    if test -n "$current_email"
        set resolved_email $current_email
    else
        # 场景 2：多仓工作区。扫描所有直接子目录里的 git 仓库，
        # 仅当 ≥2 个子仓且邮箱完全一致时才采用，避免歧义误报。
        set -l emails
        for git_marker in (command find "$PWD" -mindepth 2 -maxdepth 2 -name .git 2>/dev/null)
            set -l email (command git -C (dirname $git_marker) config --get user.email 2>/dev/null)
            test -n "$email"; and set -a emails $email
        end

        if test (count $emails) -ge 2
            set -l unique
            for e in $emails
                contains -- $e $unique; or set -a unique $e
            end
            test (count $unique) -eq 1; and set resolved_email $unique[1]
        end
    end

    if test -n "$resolved_email"
        set -gx AI_CONTRIBUTION_USERNAME (string replace -r '@.*$' '' -- $resolved_email)
    else
        set -e AI_CONTRIBUTION_USERNAME
    end
end

__trae_sync_ai_contribution_username
