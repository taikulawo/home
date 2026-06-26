# Import exported variables from fish into POSIX-style shells.
# Keep PATH/env definitions in ~/.config/fish/config.fish; this file only bridges them.

__import_fish_env() {
    command -v fish >/dev/null 2>&1 || return 0
    [ -z "${__IMPORTING_FISH_ENV:-}" ] || return 0
    [ -z "${__FISH_ENV_IMPORTED:-}" ] || return 0

    env __IMPORTING_FISH_ENV=1 fish -lc '
        if type -q nvm; and set -q nvm_default_version
            set --erase nvm_current_version NVM_BIN NVM_INC
            nvm use --silent $nvm_default_version >/dev/null 2>&1
        end

        for name in (set --names --export)
            contains -- $name PWD SHELL SHLVL _; and continue
            string match -qr "^[A-Za-z_][A-Za-z0-9_]*\$" -- $name; or continue
            printf "export %s=%s\n" $name (string escape --style=script -- (string join : -- $$name))
        end
    '
}

eval "$(__import_fish_env)"
__FISH_ENV_IMPORTED=1
unset -f __import_fish_env 2>/dev/null || unset __import_fish_env
unset __IMPORTING_FISH_ENV
