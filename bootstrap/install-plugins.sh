#!/usr/bin/env bash
# =============================================================================
# good-trip — bootstrap/install-plugins.sh
# Installs community ZSH plugins required by .zshrc
# =============================================================================
set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'
log()     { echo -e "${BLUE}[plugins]${NC} $*"; }
success() { echo -e "${GREEN}[plugins]${NC} ✓ $*"; }

OMZ_CUSTOM="${ZSH:-$HOME/.oh-my-zsh}/custom/plugins"
mkdir -p "$OMZ_CUSTOM"

clone_or_update() {
  local name="$1"
  local url="$2"
  local dest="${OMZ_CUSTOM}/${name}"

  if [[ -d "$dest" ]]; then
    log "${name} already installed. Updating..."
    git -C "$dest" pull --quiet --ff-only
  else
    log "Installing ${name}..."
    git clone --depth=1 "$url" "$dest"
    success "${name} installed."
  fi
}

clone_or_update "zsh-autosuggestions" \
  "https://github.com/zsh-users/zsh-autosuggestions"

clone_or_update "zsh-syntax-highlighting" \
  "https://github.com/zsh-users/zsh-syntax-highlighting"

success "All plugins up to date."
