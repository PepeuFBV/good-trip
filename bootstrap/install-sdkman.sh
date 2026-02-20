#!/usr/bin/env bash
# =============================================================================
# good-trip — bootstrap/install-sdkman.sh
# Installs SDKMAN! for JVM ecosystem management
# =============================================================================
set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'
log()     { echo -e "${BLUE}[sdkman]${NC} $*"; }
success() { echo -e "${GREEN}[sdkman]${NC} ✓ $*"; }
has()     { command -v "$1" &>/dev/null; }

SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"

if [[ -d "$SDKMAN_DIR" ]] && [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]]; then
  success "SDKMAN already installed: $("${SDKMAN_DIR}/bin/sdk" version 2>/dev/null || echo "installed")"
  exit 0
fi

if ! has curl && ! has wget; then
  echo "[sdkman] curl or wget required to install SDKMAN." >&2
  exit 1
fi

log "Installing SDKMAN..."
curl -fsSL "https://get.sdkman.io" | bash
success "SDKMAN installed. Reload your shell to use it."
