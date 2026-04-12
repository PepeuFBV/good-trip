#!/usr/bin/env bash
# =============================================================================
# good-trip — bootstrap/install-powerlevel10k.sh
# Installs Powerlevel10k theme for Oh My Zsh
# =============================================================================
set -euo pipefail

GT_LOG_LABEL="p10k"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

OMZ_THEMES="${ZSH:-$HOME/.oh-my-zsh}/custom/themes"
P10K_DIR="${OMZ_THEMES}/powerlevel10k"

if [[ -d "$P10K_DIR" ]]; then
  success "Powerlevel10k already installed. Updating..."
  git -C "$P10K_DIR" pull --quiet --ff-only
  exit 0
fi

log "Installing Powerlevel10k..."
mkdir -p "$OMZ_THEMES"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
success "Powerlevel10k installed."

if [[ ! -f "$HOME/.p10k.zsh" ]]; then
  log "No ~/.p10k.zsh found. Run 'p10k configure' after reloading your shell."
fi
