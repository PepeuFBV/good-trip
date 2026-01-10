# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
export EDITOR=nano

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  z
  sudo
  history
  command-not-found
  docker
  docker-compose
  npm
  node
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# aliases
alias zshconfig="mate ~/.zshrc"
alias ohmyzsh="mate ~/.oh-my-zsh"

# load shared aliases
for f in ~/.shell/aliases/*.aliases; do
  [ -r "$f" ] && source "$f"
done

# SDKMAN
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Atuin PATH + env
source "$HOME/.atuin/bin/env"

# deactivate up arrow key override
export ATUIN_NOBIND="true"

# Atuin ZSH integration
eval "$(atuin init zsh)"

chpwd() {
  ls
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # this loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # this loads nvm >

autoload -U add-zsh-hook

load-nvmrc() {
  local node_version
  local nvmrc_path

  nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    node_version="$(cat "$nvmrc_path")"

    if [ "$(nvm version "$node_version")" = "N/A" ]; then
      nvm install "$node_version"
    fi

    nvm use "$node_version" > /dev/null
  fi
}

add-zsh-hook chpwd load-nvmrc
load-nvmrc
