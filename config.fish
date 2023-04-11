function reload
    source ~/.config/fish/config.fish
end

function actv
    source ~/.venvs/$argv[1]/bin/activate.fish
end

function get_org
    if string match -r '^https*' $argv[1]
        echo 'this is HTTPS'
    else if string match -r '^git@*' $argv[1]
        echo 'this is SSH'
    else
        echo 'this is None'
    end
end

function fix_wsl2_interop
    for i in (pstree -np -s $fish_pid | grep -o -E '[0-9]+')
        if test -e "/run/WSL/"$i"_interop"
            set -x WSL_INTEROP "/run/WSL/"$i"_interop"
        end
    end
end

fix_wsl2_interop

function refresh_tmux --on-event fish_postexec
    if [ -n "$TMUX" ]
        tmux refresh-client -S
    end
end

function reload-tmux
    tmux source ~/.tmux.conf
end

function cdgitroot
    set -l in_git (command git rev-parse --is-inside-work-tree >/dev/null; and echo 1)
    if test -n in_git
        builtin cd (git rev-parse --show-toplevel)
    end
end

# color settings
## Syntax Highlighting Colors
set -g fish_color_normal c0caf5
set -g fish_color_command 7dcfff
set -g fish_color_keyword bb9af7
set -g fish_color_quote e0af68
set -g fish_color_redirection c0caf5
set -g fish_color_end ff9e64
set -g fish_color_error f7768e
set -g fish_color_param 9d7cd8
set -g fish_color_comment 565f89
set -g fish_color_selection --background=364a82
set -g fish_color_search_match --background=364a82
set -g fish_color_operator 9ece6a
set -g fish_color_escape bb9af7
set -g fish_color_autosuggestion 565f89

## Completion Pager Colors
set -g fish_pager_color_progress 565f89
set -g fish_pager_color_prefix 7dcfff
set -g fish_pager_color_completion c0caf5
set -g fish_pager_color_description 565f89
set -g fish_pager_color_selected_background --background=364a82

#aliases
alias t='tminimum'

#docker alias
alias drun='docker run'
alias dstart='docker start'
alias dstop='docker stop'
alias drm='docker rm'
alias dps='docker ps -a'
alias dv='docker volume'
alias dn='docker network'
alias dc='docker-compose'

#theme-bobthefish
set -g theme_powerline_fonts no
set -g theme_nerd_fonts yes
set -g theme_date_format "+%a %m/%d %H:%M"
set -g theme_display_date no
set -g theme_newline_cursor yes
set -g theme_newline_prompt '⛵ '
set -g theme_display_git_stashed_verbose no
set -g theme_display_git_ahead_verbose no
set -g theme_display_git_dirty_verbose no
set -g theme_display_git_dirty yes

#fzf setting
set -U FZF_ENABLE_OPEN_PREVIEW 1
set -U FZF_LEGACY_KEYBINDINGS 0
set -U FZF_REVERSE_ISEARCH_OPTS "--reverse --height=100%"

# ghq + fzf
function ghq_fzf_repo -d 'Repository search'
    ghq list --full-path | fzf --reverse --height=100% | read select
    [ -n "$select" ]; and cd "$select"
    echo " $select "
    commandline -f repaint
end
  
# fish key bindings
function fish_user_key_bindings
    bind \cg ghq_fzf_repo
end

# Base16 Shell
if status --is-interactive
    set -l BASE16_DIR $HOME/.config/base16-shell
    set -l BASE16_THEME base16-dracula

    begin
        test -d $BASE16_DIR
        and not set -qx VIM    # Vim/Neovim
        and not set -qx VSCODE # VSCode with terminal.integrated.env.linux
    end

    if test $status -eq 0
        bash $BASE16_DIR/scripts/$BASE16_THEME.sh
    end
end
