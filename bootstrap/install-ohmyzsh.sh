#!/usr/bin/env bash
# =============================================================================
# good-trip — bootstrap/install-ohmyzsh.sh
# Installs Oh My Zsh non-interactively (idempotent)
# =============================================================================
set -euo pipefail

GT_LOG_LABEL="oh-my-zsh"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

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
