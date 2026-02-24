#!/usr/bin/env zsh
# =============================================================================
# good-trip — config/zsh/.zshrc
# Managed by good-trip: https://github.com/PepeuFBV/good-trip
# DO NOT EDIT MANUALLY — edit the source file and run 'good-trip symlinks'
# =============================================================================

# ── good-trip ─────────────────────────────────────────────────────────────────
export GOOD_TRIP_DIR="${GOOD_TRIP_DIR:-$HOME/.good-trip}"

# ── Powerlevel10k instant prompt ─────────────────────────────────────────────
# Must stay near top — nothing requiring console input above this block
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ── Environment ───────────────────────────────────────────────────────────────
export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
export EDITOR="${EDITOR:-nano}"
export GPG_TTY=$(tty)
export PATH="$HOME/.local/bin:$PATH"

# ── Oh My Zsh ─────────────────────────────────────────────────────────────────
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
  python
  pip
  virtualenv
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

# ── History ───────────────────────────────────────────────────────────────────
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# ── Aliases (load all .aliases files) ─────────────────────────────────────────
for _f in ~/.shell/aliases/*.aliases; do
  [[ -r "$_f" ]] && source "$_f"
done
unset _f

# ── Convenience aliases ───────────────────────────────────────────────────────
alias zshconfig="${EDITOR} ${GOOD_TRIP_DIR}/config/zsh/.zshrc"
alias ohmyzsh="cd ${ZSH}"
alias gt="good-trip"

# ── NVM ───────────────────────────────────────────────────────────────────────
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
[[ -s "${NVM_DIR}/nvm.sh" ]] && source "${NVM_DIR}/nvm.sh"
[[ -s "${NVM_DIR}/bash_completion" ]] && source "${NVM_DIR}/bash_completion"

autoload -U add-zsh-hook

load-nvmrc() {
  local nvmrc_path
  nvmrc_path="$(nvm_find_nvmrc 2>/dev/null)"
  if [[ -n "$nvmrc_path" ]]; then
    local node_version
    node_version="$(cat "$nvmrc_path")"
    if [[ "$(nvm version "$node_version" 2>/dev/null)" == "N/A" ]]; then
      nvm install "$node_version"
    fi
    nvm use "$node_version" > /dev/null
  fi
}

add-zsh-hook chpwd load-nvmrc
load-nvmrc

# ── Python / venv auto-activation ────────────────────────────────────────────
# Automatically activate .venv (or venv/env) when entering a directory that has one
_gt_venv_autoactivate() {
  local venv_dir
  for d in .venv venv env; do
    if [[ -f "${PWD}/${d}/bin/activate" ]]; then
      venv_dir="${PWD}/${d}"
      break
    fi
  done

  if [[ -n "${venv_dir:-}" ]]; then
    # Only activate if not already in this venv
    if [[ "${VIRTUAL_ENV:-}" != "$venv_dir" ]]; then
      source "${venv_dir}/bin/activate"
    fi
  elif [[ -n "${VIRTUAL_ENV:-}" ]]; then
    # Deactivate if we've left the venv's project directory
    if [[ "$PWD" != "${VIRTUAL_ENV%/*}"* ]]; then
      deactivate
    fi
  fi
}
add-zsh-hook chpwd _gt_venv_autoactivate
_gt_venv_autoactivate  # run on shell start

# ── SDKMAN ────────────────────────────────────────────────────────────────────
export SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"
[[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"

# ── Atuin ─────────────────────────────────────────────────────────────────────
if [[ -s "$HOME/.atuin/bin/env" ]]; then
  source "$HOME/.atuin/bin/env"
  export ATUIN_NOBIND="true"
  eval "$(atuin init zsh)"
fi

# ── Auto-list on cd ───────────────────────────────────────────────────────────
chpwd() { ls; }

# ── Powerlevel10k config ──────────────────────────────────────────────────────
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# ── good-trip: daily update check (background, non-blocking) ─────────────────
_gt_check_update() {
  local stamp="${XDG_CACHE_HOME:-$HOME/.cache}/good-trip/last-update-check"
  local interval="${GOOD_TRIP_UPDATE_INTERVAL:-86400}"
  local stale=false

  if [[ ! -f "$stamp" ]]; then
    stale=true
  else
    local last now
    last=$(cat "$stamp")
    now=$(date +%s)
    (( now - last > interval )) && stale=true
  fi

  if $stale && [[ -x "${GOOD_TRIP_DIR}/scripts/update.sh" ]]; then
    (bash "${GOOD_TRIP_DIR}/scripts/update.sh" --check --silent &) 2>/dev/null
  fi
}
_gt_check_update
export GPG_TTY="$(tty)"
