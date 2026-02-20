#!/usr/bin/env bash
# =============================================================================
# good-trip — bootstrap/install-atuin.sh
# Installs Atuin for shell history management
# =============================================================================
set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'
log()     { echo -e "${BLUE}[atuin]${NC} $*"; }
success() { echo -e "${GREEN}[atuin]${NC} ✓ $*"; }
has()     { command -v "$1" &>/dev/null; }

if has atuin; then
  success "Atuin already installed: $(atuin --version)"
  exit 0
fi

log "Installing Atuin..."

if [[ "$OSTYPE" == "darwin"* ]]; then
  brew install atuin
elif [[ -f /etc/arch-release ]]; then
  # Available in extra repo on Arch
  sudo pacman -S --noconfirm atuin
else
  # Universal installer script (Rust-based binary)
  curl -fsSL https://setup.atuin.sh | bash
fi

success "Atuin installed: $(atuin --version)"
log "Atuin ZSH integration is configured in .zshrc."
log "Optional: run 'atuin register' to enable sync across machines."
