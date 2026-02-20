#!/usr/bin/env bash
# =============================================================================
# good-trip — bootstrap/install-nvm.sh
# Installs Node Version Manager (NVM)
# =============================================================================
set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'
log()     { echo -e "${BLUE}[nvm]${NC} $*"; }
success() { echo -e "${GREEN}[nvm]${NC} ✓ $*"; }

NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
NVM_VERSION="${NVM_VERSION:-v0.40.1}"

if [[ -d "$NVM_DIR" ]] && [[ -s "${NVM_DIR}/nvm.sh" ]]; then
  # shellcheck source=/dev/null
  source "${NVM_DIR}/nvm.sh"
  success "NVM already installed: $(nvm --version)"
  exit 0
fi

log "Installing NVM ${NVM_VERSION}..."
curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
success "NVM installed. Reload your shell to use it."
