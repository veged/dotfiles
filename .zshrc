# Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"

fpath+='/opt/homebrew/share/zsh/site-functions'
source $(brew --prefix)/opt/antidote/share/antidote/antidote.zsh
antidote load

source <(cod init $$ zsh)

source ~/.iterm2_shell_integration.zsh
unsetopt share_history

bindkey -e
bindkey '\e[1;3D' backward-word     # ⌥←
bindkey '\e[1;3C' forward-word      # ⌥→
bindkey '^[[1;9D' beginning-of-line # ⌘←
bindkey '^[[H'    beginning-of-line # Home
bindkey '^[[1;9C' end-of-line       # ⌘→
bindkey '^[[F'    end-of-line       # End

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
bindkey '^[[102;9u' resume-last-job # ⌘f

# Aliases

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
function set-prompt() (
  local top_left=$(ZSH_PROMPT_TOP_LEFT)
  local top_right=$(ZSH_PROMPT_TOP_RIGHT)
  local bottom_left=$(ZSH_PROMPT_BOTTOM_LEFT)
  local bottom_right=$(ZSH_PROMPT_BOTTOM_RIGHT)

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
)

# VCS status
set-vcs() {
  local git_branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
  if [[ -n ${git_branch} ]]; then
    current_vcs 'git'
    CURRENT_VCS_BRANCH=$(print_vcs_branch "$(git status --porcelain 2>/dev/null)" "$git_branch")
  else
    local arc_info=("${(f)$(arc info 2>/dev/null)}")
    local arc_branch=${${(M)arc_info:#branch:*}#branch: }
    if [[ -n ${arc_branch} ]]; then
      current_vcs 'arc'
      CURRENT_VCS_BRANCH=$(print_vcs_branch "$(arc status --short 2>/dev/null)" "$arc_branch")
    else
      current_vcs ''
      CURRENT_VCS_BRANCH=''
    fi
  fi
}

print_vcs_branch() {
  local vcs_status=("${(f)1}")

  if [[ ${(M)vcs_status:#[MADRCU][ MADRCU]*} ]]; then # staged
    print -n "%F{yellow}"
  elif [[ ${(M)vcs_status:# [MADRCU]*} ]]; then # unstaged
    print -n "%F{red}"
  else
    print -n "%F{green}"
  fi

  print -n "$2%f"
}

export CURRENT_VCS=''
alias s='echo "Not in any VCS folder!"'
current_vcs() {
  if [[ $CURRENT_VCS != $1 ]]; then
    export CURRENT_VCS="$1"
    case "$1" in
      git)
        alias s='git st'
        ;;
      arc)
        alias s='arc st'
        ;;
      *)
        ;;
    esac
  fi
}

ZSH_PROMPT_TOP_LEFT() { echo "%{$(iterm2_prompt_mark)%}%F{yellow}%~%f" }
ZSH_PROMPT_TOP_RIGHT() { echo $CURRENT_VCS_BRANCH }
ZSH_PROMPT_BOTTOM_LEFT() { echo "%F{%(?.green.red)}%(!. .➤)%f " }
ZSH_PROMPT_BOTTOM_RIGHT() { echo '' }
export ZSH_THEME_GIT_PROMPT_PREFIX='%B '
export ZSH_THEME_GIT_PROMPT_SUFFIX='%b%f'
export ZSH_THEME_GIT_PROMPT_DIRTY='%F{red}'
export ZSH_THEME_GIT_PROMPT_CLEAN='%F{green}'

set-title() {
  local title=$(print -Pn "%~")
  print -Pn "\e]0;$title\a"
  kitty @ set-window-title "$title"
}

setopt no_prompt_{bang,subst} prompt_{cr,percent,sp}
autoload -Uz add-zsh-hook
add-zsh-hook precmd set-dark-or-light-mode
add-zsh-hook precmd set-vcs
add-zsh-hook precmd set-prompt
add-zsh-hook precmd set-title


# FZF
eval "$(fzf --zsh)"

export FZF_DEFAULT_COLOR_LIGHT_OPTS=" \
  --color=fg:-1,fg+:#d0d0d0,bg:-1,bg+:#7c7f93 \
  --color=hl:#d20f39,hl+:#5fd7ff,info:#8839ef,marker:#dc8a78 \
  --color=prompt:#8839ef,spinner:#dc8a78,pointer:#dc8a78,header:#d20f39 \
  --color=gutter:#eff1f5,border:#262626,label:#aeaeae,query:#5c5f77"
export FZF_DEFAULT_COLOR_DARK_OPTS=" \
  --color=fg:-1,fg+:#d0d0d0,bg:-1,bg+:#262626 \
  --color=hl:#f38ba8,hl+:#5fd7ff,info:#cba6f7,marker:#f5e0dc \
  --color=prompt:#cba6f7,spinner:#f5e0dc,pointer:#f5e0dc,header:#f38ba8 \
  --color=gutter:#1e1e2e,border:#262626,label:#aeaeae,query:#d9d9d9"
export FZF_DEFAULT_BASE_OPTS=" \
  --ansi \
  --min-height=9 \
  --border='rounded' --border-label='' --preview-window='border-rounded' \
  --prompt='➤' --marker='' --pointer='◆' --separator='─' --scrollbar='❚'"

_fzf_compgen_path() {
  # eza --icons=always --color=always -1ad --absolute "$1"
  fd --hidden --follow --exclude ".git" . "$1"
}

_fzf_compgen_dir() {
  # eza --icons=always --color=always -1ad --absolute --only-dirs "$1"
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}' --bind 'ctrl-/:change-preview-window(down|hidden|)'"

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd) fzf --preview 'eza --icons=always --color=always --tree --level=3 {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \$'{}" "$@" ;;
    ssh) fzf --preview 'dig {}' "$@" ;;
    *) fzf --preview 'bat -n --color=always --line-range :500 {}' "$@" ;;
  esac
}

# export FZF_DEFAULT_COMMAND="eza --icons=always --color=always -1da"
# export FZF_ALT_C_COMMAND=$FZF_DEFAULT_COMMAND" --only-dirs"
#
# function _fd_base() {
#   echo "! _fd_base !" $1 $2 >> /tmp/zsh.log
#   echo "! _fd_base 1 !" ${1:-'.* .'} >> /tmp/zsh.log
#   local -a opts
#   [ $1 = 'dirs' ] && opts=('--type=d')
#   echo "fd -0 --follow --hidden $opts --exact-depth=1 --format='{/}' -g '$2*' | xargs -0 eza --icons=always --color=always --no-quotes -1da" >> /tmp/zsh.log
#   eval "fd -0 --follow --hidden $opts --exact-depth=1 --format='{/}' -g '$2*' | xargs -0 eza --icons=always --color=always --no-quotes -1da"
# }
#
# function _fd_filter() {
#   echo "! _fd_filter !" $1 + $2 >> /tmp/zsh.log
#   # Special-case some of the usages
#   case "$2" in
#     '~'*)
#       # Expand and then collapse `~` at the beginning of the search string and then re-check it
#       _fd_filter "${1/#\~/$HOME}" $2
#       ;;
#     (../)##(..)#)
#       # Parent dir only, handle manually as `dirname` fails to handle that correctly
#       _fd_base $1 $2
#       ;;
#     *)
#       # All the rest
#       _fd_base $1 $2
#       ;;
#   esac
# }
#
# function _fd_select() {
#   echo "! _fd_select !" $1 $2 >> /tmp/zsh.log
#   local -a opts=(--preview="bat -n --color=always --pager=never --line-range :300 {echo {+} | sed \"s/^. //\"}" --preview-window=right:70%)
#   if [[ "$2" == 'dirs' ]]; then
#     opts=(--preview='eza --tree --level=3 --color=always --icons {} | head -200' --preview-window=right:50%)
#   fi
#
#   echo "! _fd_select opts !" $opts >> /tmp/zsh.log
#   _fd_filter $1 $2 | fzf $opts \
#     --ansi \
#     --exit-0 \
#     --layout=reverse --height=75% \
#     --tiebreak=begin \
#     --bind 'enter:execute(echo {+} | sed "s/^. //")+abort' \
#     --query="$2"
# }
#
# function _fd_execute() {
#   # All through compadd
#   #local result=("${(@f)$(_fd_filter $1 $2)}")
#   #compadd -a -f result
#
#   # Display FZF manually with a hack to prevent multiple appearances of FZF (i.e. multiple calls to
#   # _files and _cd) when cancelling the matching
#   echo "! _fd_execute !" $_matcher_num $1 $2 >> /tmp/zsh.log
#   if [[ $_matcher_num == 1 ]]; then
#     local result=$(_fd_select $1 $2)
#     echo "! _fd_execute resul !" $result >> /tmp/zsh.log
#     [ "$result" = '' ] || compadd -f -U -- "$result"
#     return 0
#   fi
#   return 1
# }
#
# # Save the original functions since we want them to run when executing `-command-` completion
# autoload +X _files _cd
# functions[_save_orig_files]=$functions[_files]
# functions[_save_orig_cd]=$functions[_cd]
#
# function _files() {
#   echo "! _files !" $LBUFFER >> /tmp/zsh.log
#   if [[ $curcontext == ':complete:-command-:' ]]; then
#     _save_orig_files $@
#   else
#     echo "! _files curcontext != :complete:-command-: !" ${(z)LBUFFER} >> /tmp/zsh.log
#     local query=(${(z)LBUFFER})
#     echo "! _files query !" $query >> /tmp/zsh.log
#     [ "${LBUFFER[-1]}" = ' ' ] && query+=('')
#     echo "! _files query[-1] !" $query[-1] >> /tmp/zsh.log
#     _fd_execute 'files' "$query[-1]"
#   fi
# }
# function _fzf_compgen_path() {
#   echo "! _fzf_compgen_dir !" $1 >> /tmp/zsh.log
#   _fs_base $1
# }
#
# function _cd() {
#   echo "! _cd !" $LBUFFER >> /tmp/zsh.log
#   echo "! _cd curcontext !" $curcontext >> /tmp/zsh.log
#   if [[ $curcontext == ':complete:-command-:' ]]; then
#     _save_orig_cd $@
#   else
#     echo "! _cd curcontext != :complete:-command-: !" ${(z)LBUFFER} >> /tmp/zsh.log
#     local query=(${(z)LBUFFER})
#     echo "! _cd query !" $query >> /tmp/zsh.log
#     [ "${LBUFFER[-1]}" = ' ' ] && query+=('')
#     echo "! _cd query[-1] !" $query[-1] >> /tmp/zsh.log
#     _fd_execute 'dirs' "$query[-1]"
#   fi
# }
# function _fzf_compgen_dir() {
#   echo "! _fzf_compgen_dir !" $1 >> /tmp/zsh.log
#   _fd_base 'dirs' $1
# }
#

zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu no

zstyle ":completion:*:descriptions" format "[%d]"

zstyle ':fzf-tab:complete:*' fzf-min-height 9
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --tree --level=3 --color=always --icons $realpath'
zstyle ':fzf-tab:complete:export|unset' fzf-preview "eval 'echo \$'$realpath"
zstyle ':fzf-tab:complete:*' fzf-preview 'bat -n --color=always --line-range :500 $realpath'

# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false

# give a preview of commandline arguments when completing `kill`
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview '[[ $group == "[process ID]" ]] && ps -p $word -o args='
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags '--preview-window=down:3:wrap'

zstyle ':completion:*:*:local-directories' command "eza --icons=always -a --color=always -L1 $1"

zstyle ':fzf-tab:*' prefix ''

zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' continuous-trigger 'space'
zstyle ':fzf-tab:*' fzf-bindings 'tab:accept'
zstyle ':fzf-tab:*' accept-line enter


eval "$(zoxide init zsh)"

source $HOME/.config/broot/launcher/bash/br

# Dark and light modes

set-dark-or-light-mode() {
  {
    local mode='light'
    defaults read -g AppleInterfaceStyle 2>/dev/null | grep -q Dark && mode='dark'
    if [[ $DARK_OR_LIGHT_MODE != $mode ]]; then
      export DARK_OR_LIGHT_MODE=$mode
      case "$mode" in
        light)
          export BAT_THEME='Catppuccin Latte'
          export KITTY_THEME=Catppuccin-Latte
          export FZF_DEFAULT_COLOR_OPTS=$FZF_DEFAULT_COLOR_LIGHT_OPTS
          ;;
        dark)
          export BAT_THEME='Catppuccin Mocha'
          export KITTY_THEME=Catppuccin-Mocha
          export FZF_DEFAULT_COLOR_OPTS=$FZF_DEFAULT_COLOR_DARK_OPTS
          ;;
      esac
      export FZF_DEFAULT_OPTS="$FZF_DEFAULT_BASE_OPTS $FZF_DEFAULT_COLOR_OPTS"
      lsof -U -Fn | rg -o '/.*nvim.*' | xargs -L1 -r nvim --remote-send "<Esc><Esc>:set background=$mode<CR>" --server
      kitty +kitten themes --reload-in=all $KITTY_THEME
    fi
  } >/dev/null 2>&1
}
set-dark-or-light-mode

# Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"

if [[ $ZSH_EVAL ]]
then
  eval "$ZSH_EVAL"
  unset ZSH_EVAL
fi
