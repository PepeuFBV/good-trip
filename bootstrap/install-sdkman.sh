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
# Set SDKMAN_DEFAULT_JAVA to a Java identifier (e.g. "21.0.3-tem", "17.0.9-tem")
# to have that version installed and set as default after SDKMAN is set up.
# Run 'sdk list java' to see available identifiers.
SDKMAN_DEFAULT_JAVA="${SDKMAN_DEFAULT_JAVA:-}"

# Helper: run sdk commands inside the current shell after sourcing sdkman-init
_sdk_install_default() {
  local identifier="${1:-}"
  if [[ -z "$identifier" ]]; then
    return 0
  fi
  log "Installing default Java SDK '${identifier}'..."
  # shellcheck source=/dev/null
  source "${SDKMAN_DIR}/bin/sdkman-init.sh"
  sdk install java "$identifier" < /dev/null || true
  sdk default java "$identifier" || true
  success "Default Java set to: $(sdk current java 2>/dev/null || echo "$identifier")"
}

if [[ -d "$SDKMAN_DIR" ]] && [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]]; then
  success "SDKMAN already installed: $("${SDKMAN_DIR}/bin/sdk" version 2>/dev/null || echo "installed")"
  _sdk_install_default "$SDKMAN_DEFAULT_JAVA"
  exit 0
fi

if ! has curl && ! has wget; then
  echo "[sdkman] curl or wget required to install SDKMAN." >&2
  exit 1
fi

log "Installing SDKMAN..."
curl -fsSL "https://get.sdkman.io" | bash
success "SDKMAN installed."

_sdk_install_default "$SDKMAN_DEFAULT_JAVA"

success "SDKMAN setup complete. Reload your shell to use it."
