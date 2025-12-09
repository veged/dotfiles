eval "$(/opt/homebrew/bin/brew shellenv)"

export GOROOT="$(brew --prefix golang)/libexec"

export NVM_DIR="$HOME/.nvm"
[ -s '/opt/homebrew/opt/nvm/nvm.sh' ] && \. '/opt/homebrew/opt/nvm/nvm.sh'  # This loads nvm

export PATH=$HOME/.local/bin:$GOROOT/bin:./node_modules/.bin:$HOME/arcadia:$PATH

export XDG_CONFIG_HOME=$HOME/.config
export XDG_DATA_HOME=$HOME/.local/share
export XDG_STATE_HOME=$HOME/.local/state
export XDG_CACHE_HOME=$HOME/.cache

export EDITOR='nvim'

export LANG=en_US.UTF-8

export LSCOLORS='exfxcxdxbxegedabagacad'
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'

export AWS_PROFILE=veged-static
