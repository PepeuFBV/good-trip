#!/usr/bin/env bash
# =============================================================================
# good-trip — bootstrap/install-plugins.sh
# Installs community ZSH plugins required by .zshrc
# =============================================================================
set -euo pipefail

export GT_LOG_LABEL="plugins"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

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
