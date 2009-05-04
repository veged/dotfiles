autoload -U promptinit;
promptinit;
# prompt walters

PROMPT='%n@%m:%/> '
RPROMPT=''

alias ls="ls --color=auto"
alias ll="ls -FGl"
alias la="ls -la"
alias du="du -s"
alias df="df"
alias vim='vim -o'

umask 0002

# The following lines were added by compinstall
zmodload zsh/complist

zstyle ':completion:*' completer _complete
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle :compinstall filename '/home/veged/.zshrc'

# ssh 
local _myhosts
_myhosts=( ${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[0-9]*}%%\ *}%%,*} )
zstyle ':completion:*' hosts $_myhosts


autoload -U compinit
compinit
zstyle ':completion:*' menu yes select
# End of lines added by compinstall

source ${ZDOTDIR:-$HOME}/.zkbd/xterm-color-pc-linux-gnu
[[ -n ${key[Home]} ]] && bindkey "${key[Home]}" beginning-of-line
[[ -n ${key[End]} ]] && bindkey "${key[End]}" end-of-line
[[ -n ${key[Backspace]} ]] && bindkey "${key[Backspace]}" backward-delete-char
[[ -n ${key[Delete]} ]] && bindkey "${key[Delete]}" delete-char
bindkey "^R" history-incremental-search-backward
#precmd() {
#	print -Pn "\ek\e\\"
#}

# History settings
HISTFILE=~/.zhistory
HISTSIZE=100
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS

alias t='find -name "*.x[ms]l" -or -name "*.html" | xargs touch'

export CVSROOT=tree.yandex.ru:/opt/CVSROOT
export TERM=linux
export CFG=veged
export EDITOR=vim
