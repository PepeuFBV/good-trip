#!/usr/bin/env bash
# =============================================================================
# good-trip — bootstrap/install-atuin.sh
# Installs Atuin for shell history management
# =============================================================================
set -euo pipefail

export GT_LOG_LABEL="atuin"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

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
  # ATUIN_NO_PROMPT suppresses interactive sync/registration prompts
  ATUIN_NO_PROMPT=1 curl -fsSL https://setup.atuin.sh | bash
fi

# The installer places the binary in ~/.atuin/bin which is not yet on PATH;
# source its env file so we can call atuin in this same shell session.
if [[ -f "$HOME/.atuin/bin/env" ]]; then
  # shellcheck source=/dev/null
  . "$HOME/.atuin/bin/env"
fi

atuin_bin="$(command -v atuin 2>/dev/null || echo "$HOME/.atuin/bin/atuin")"
success "Atuin installed: $($atuin_bin --version 2>/dev/null || echo '(version unavailable)')"
log "Atuin ZSH integration is configured in .zshrc."
log "Optional: run 'atuin register' to enable sync across machines."
