#!/usr/bin/env bash
# =============================================================================
# good-trip — bootstrap/install-zsh.sh
# Installs ZSH if not present
# =============================================================================
set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'
log()     { echo -e "${BLUE}[zsh]${NC} $*"; }
success() { echo -e "${GREEN}[zsh]${NC} ✓ $*"; }
has()     { command -v "$1" &>/dev/null; }

if has zsh; then
  success "ZSH already installed: $(zsh --version)"
  exit 0
fi

log "Installing ZSH..."

if [[ "$OSTYPE" == "darwin"* ]]; then
  brew install zsh
elif [[ -f /etc/arch-release ]]; then
  sudo pacman -S --noconfirm zsh
elif [[ -f /etc/debian_version ]]; then
  sudo apt-get install -y zsh
elif [[ -f /etc/fedora-release ]] || [[ -f /etc/redhat-release ]]; then
  sudo dnf install -y zsh
else
  echo "Please install ZSH manually for your OS." >&2
  exit 1
fi

success "ZSH installed: $(zsh --version)"

# Offer to change default shell
if [[ "$SHELL" != "$(which zsh)" ]]; then
  log "Changing default shell to ZSH..."
  if chsh -s "$(which zsh)"; then
    success "Default shell changed to ZSH (restart session to apply)"
  else
    log "Could not auto-change shell. Run: chsh -s $(which zsh)"
  fi
fi
