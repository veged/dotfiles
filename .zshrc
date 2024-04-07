# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"

export GOROOT=`go env GOPATH`

# If you come from bash you might have to change your $PATH.
export PATH=$GOROOT/bin:./node_modules/.bin:$HOME/Documents/arcadia:$PATH

ZSH_DISABLE_COMPFIX="true"
# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
export LSCOLORS="exfxcxdxbxegedabagacad"
export LS_COLORS="di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    arc-prompt
    zsh-shift-select
    zsh-better-npm-completion
)

source $ZSH/oh-my-zsh.sh
source ~/.iterm2_shell_integration.zsh
unsetopt share_history

export LANG=en_US.UTF-8

bindkey "\e[1;3D" backward-word     # ⌥←
bindkey "\e[1;3C" forward-word      # ⌥→
bindkey "^[[1;9D" beginning-of-line # ⌘←
bindkey "^[[1;9C" end-of-line       # ⌘→

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

bindkey "^[[99;9u" pb-copy-region-as-kill # ⌘c
bindkey "^[[120;9u" pb-kill-region # ⌘x

resume-last-job () { fg % }
zle -N resume-last-job
bindkey "^[[102;9u" resume-last-job

export EDITOR='nvim'

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.

alias v="nvim -o"
alias vc="v ~/.config/nvim/{init.lua,lua/plugins.lua}"
alias vd="nvim -d"
alias l="eza --icons"
alias l1="l -1"
alias ll="l -lah"
alias t="eza -T"

alias kitty-light="kitty +kitten themes --reload-in=all Catppuccin-Latte"
alias kitty-dark="kitty +kitten themes --reload-in=all Catppuccin-Mocha"

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

ZSH_PROMPT_TOP_LEFT() { echo "%{$(iterm2_prompt_mark)%}%F{yellow}%~%f" }
ZSH_PROMPT_TOP_RIGHT() { echo "$(git_prompt_info)$(arc_prompt_info)" }
ZSH_PROMPT_BOTTOM_LEFT() { echo "%F{%(?.green.red)}%(!. .➤)%f " }
ZSH_PROMPT_BOTTOM_RIGHT() { echo '' }
export ZSH_THEME_GIT_PROMPT_PREFIX='%B '
export ZSH_THEME_GIT_PROMPT_SUFFIX='%b%f'
export ZSH_THEME_GIT_PROMPT_DIRTY='%F{red}'
export ZSH_THEME_GIT_PROMPT_CLEAN='%F{green}'


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

eval "$(/opt/homebrew/bin/brew shellenv)"

fpath+=~/.zfunc

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

eval "$(zoxide init zsh)"

source $HOME/.config/broot/launcher/bash/br

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"

source /Users/veged/.config/broot/launcher/bash/br

