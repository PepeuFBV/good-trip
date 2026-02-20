#!/usr/bin/env bash
# =============================================================================
# good-trip — bootstrap/install-ohmyzsh.sh
# Installs Oh My Zsh non-interactively (idempotent)
# =============================================================================
set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'
log()     { echo -e "${BLUE}[oh-my-zsh]${NC} $*"; }
success() { echo -e "${GREEN}[oh-my-zsh]${NC} ✓ $*"; }

OMZ_DIR="${ZSH:-$HOME/.oh-my-zsh}"

if [[ -d "$OMZ_DIR" ]]; then
  success "Oh My Zsh already installed at ${OMZ_DIR}"
  exit 0
fi

log "Installing Oh My Zsh..."

# Install unattended (skip shell change, don't run zsh after)
RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

success "Oh My Zsh installed."
