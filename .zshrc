# Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"

source $(brew --prefix)/opt/antidote/share/antidote/antidote.zsh
antidote load

source <(cod init $$ zsh)

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu select

source ~/.iterm2_shell_integration.zsh
unsetopt share_history

bindkey '\e[1;3D' backward-word     # ⌥←
bindkey '\e[1;3C' forward-word      # ⌥→
bindkey '^[[1;9D' beginning-of-line # ⌘←
bindkey '^[[1;9C' end-of-line       # ⌘→

pb-copy-region-as-kill () {
  zle copy-region-as-kill
  echo -n $CUTBUFFER | pbcopy
}
zle -N pb-copy-region-as-kill

pb-kill-region () {
  zle kill-region
  echo -n $CUTBUFFER | pbcopy
}
zle -N pb-kill-region

bindkey '^[[99;9u' pb-copy-region-as-kill # ⌘c
bindkey '^[[120;9u' pb-kill-region # ⌘x

resume-last-job () { fg % }
zle -N resume-last-job
bindkey '^[[102;9u' resume-last-job

export BAT_THEME='Catppuccin Mocha'

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.

alias ..='cd ..'
alias ...='cd ../..'
alias ↑='..'
alias ↑↑='...'
alias ←='cd -'
alias v='nvim -o'
alias vc='v -O ~/.config/nvim/{init.lua,lua/plugins.lua}'
alias vd='nvim -d'
alias l='eza --icons -a'
alias l1='l -1a'
alias ll='l -lah'
alias t='eza -Ta --icons'

alias kitty-light='kitty +kitten themes --reload-in=all Catppuccin-Latte'
alias kitty-dark='kitty +kitten themes --reload-in=all Catppuccin-Mocha'

alias ya="$HOME/arcadia/ya"

# Usage: prompt-length TEXT [COLUMNS]
#
# If you run `print -P TEXT`, how many characters will be printed
# on the last line?
#
# Or, equivalently, if you set PROMPT=TEXT with prompt_subst
# option unset, on which column will the cursor be?
#
# The second argument specifies terminal width. Defaults to the
# real terminal width.
#
# Assumes that `%{%}` and `%G` don't lie.
#
# Examples:
#
#   prompt-length ''            => 0
#   prompt-length 'abc'         => 3
#   prompt-length $'abc\nxy'    => 2
#   prompt-length '❎'          => 2
#   prompt-length $'\t'         => 8
#   prompt-length $'\u274E'     => 2
#   prompt-length '%F{red}abc'  => 3
#   prompt-length $'%{a\b%Gb%}' => 1
#   prompt-length '%D'          => 8
#   prompt-length '%1(l..ab)'   => 2
#   prompt-length '%(!.a.)'     => 1 if root, 0 if not
function prompt-length() {
  emulate -L zsh
  local -i COLUMNS=${2:-COLUMNS}
  local -i x y=${#1} m
  if (( y )); then
    while (( ${${(%):-$1%$y(l.1.0)}[-1]} )); do
      x=y
      (( y *= 2 ))
    done
    while (( y > x + 1 )); do
      (( m = x + (y - x) / 2 ))
      (( ${${(%):-$1%$m(l.x.y)}[-1]} = m ))
    done
  fi
  echo $x
}

# Sets PROMPT and RPROMPT.
#
# Requires: prompt_percent and no_prompt_subst.
function set-prompt() {
  emulate -L zsh

  top_left=$(ZSH_PROMPT_TOP_LEFT)
  top_right=$(ZSH_PROMPT_TOP_RIGHT)
  bottom_left=$(ZSH_PROMPT_BOTTOM_LEFT)
  bottom_right=$(ZSH_PROMPT_BOTTOM_RIGHT)

  local -i left_len=$(prompt-length ${top_left})
  local -i right_len=$(prompt-length ${top_right} 9999)
  local -i pad_len=$((COLUMNS - left_len - right_len - ${ZLE_RPROMPT_INDENT:-1}))
  if (( pad_len > $((left_len + right_len)))); then
    PROMPT=${top_left}' '${bottom_left}
    RPROMPT=${bottom_right}${top_right}
  else
    if (( pad_len < 1 )); then
      PROMPT=${top_left}$'\n'${bottom_left}
      RPROMPT=${bottom_right}${top_right}
    else
      local pad=${(pl.$pad_len.. .)}
      PROMPT=${top_left}${pad}${top_right}$'\n'${bottom_left}
      RPROMPT=${bottom_right}
    fi
  fi
}

setopt no_prompt_{bang,subst} prompt_{cr,percent,sp}
autoload -Uz add-zsh-hook
add-zsh-hook precmd set-prompt

# Git status
git_prompt_info() {
    local message=''
    local message_color="%F{green}"

    # https://git-scm.com/docs/git-status#_short_format
    local staged=$(git status --porcelain 2>/dev/null | grep -e "^[MADRCU]")
    local unstaged=$(git status --porcelain 2>/dev/null | grep -e "^[MADRCU? ][MADRCU?]")

    if [[ -n ${staged} ]]; then
        message_color="%F{red}"
    elif [[ -n ${unstaged} ]]; then
        message_color="%F{yellow}"
    fi

    local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [[ -n ${branch} ]]; then
        message+="${message_color}${branch}%f"
    fi

    echo -n "${message}"
}

ZSH_PROMPT_TOP_LEFT() { echo "%{$(iterm2_prompt_mark)%}%F{yellow}%~%f" }
ZSH_PROMPT_TOP_RIGHT() { echo "$(git_prompt_info)" }
ZSH_PROMPT_BOTTOM_LEFT() { echo "%F{%(?.green.red)}%(!. .➤)%f " }
ZSH_PROMPT_BOTTOM_RIGHT() { echo '' }
export ZSH_THEME_GIT_PROMPT_PREFIX='%B '
export ZSH_THEME_GIT_PROMPT_SUFFIX='%b%f'
export ZSH_THEME_GIT_PROMPT_DIRTY='%F{red}'
export ZSH_THEME_GIT_PROMPT_CLEAN='%F{green}'

fpath+='/opt/homebrew/share/zsh/site-functions'

# FZF
eval "$(fzf --zsh)"

export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}' --bind 'ctrl-/:change-preview-window(down|hidden|)'"

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd) fzf --preview 'eza --tree --level=3 --color=always --icons {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \$'{}" "$@" ;;
    ssh) fzf --preview 'dig {}' "$@" ;;
    *) fzf --preview 'bat -n --color=always --line-range :500 {}' "$@" ;;
  esac
}

eval "$(zoxide init zsh)"

source $HOME/.config/broot/launcher/bash/br

# Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"
