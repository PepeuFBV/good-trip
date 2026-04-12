#!/usr/bin/env bash
# =============================================================================
# good-trip — bootstrap/install-nvm.sh
# Installs Node Version Manager (NVM)
# =============================================================================
set -euo pipefail

export GT_LOG_LABEL="nvm"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
NVM_VERSION="${NVM_VERSION:-v0.40.1}"
# Set NVM_DEFAULT_NODE to a Node.js version (e.g. "lts/*", "22", "20.11.0")
# to have that version installed and set as default after NVM is set up.
NVM_DEFAULT_NODE="${NVM_DEFAULT_NODE:-lts/*}"

if [[ -d "$NVM_DIR" ]] && [[ -s "${NVM_DIR}/nvm.sh" ]]; then
  # shellcheck source=/dev/null
  source "${NVM_DIR}/nvm.sh"
  success "NVM already installed: $(nvm --version)"
  if [[ -n "$NVM_DEFAULT_NODE" ]]; then
    log "Ensuring default Node.js version '${NVM_DEFAULT_NODE}' is installed..."
    nvm install "$NVM_DEFAULT_NODE"
    nvm alias default "$NVM_DEFAULT_NODE"
    success "Default Node.js set to: $(nvm version default)"
  fi
  exit 0
fi

log "Installing NVM ${NVM_VERSION}..."
curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
success "NVM installed. Reloading NVM..."

# shellcheck source=/dev/null
export NVM_DIR
source "${NVM_DIR}/nvm.sh"

if [[ -n "$NVM_DEFAULT_NODE" ]]; then
  log "Installing default Node.js version '${NVM_DEFAULT_NODE}'..."
  nvm install "$NVM_DEFAULT_NODE"
  nvm alias default "$NVM_DEFAULT_NODE"
  success "Default Node.js set to: $(nvm version default)"
fi

success "NVM setup complete. Reload your shell to use it."
