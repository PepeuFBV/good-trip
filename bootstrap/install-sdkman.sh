#!/usr/bin/env bash
# =============================================================================
# good-trip — bootstrap/install-sdkman.sh
# Installs SDKMAN! for JVM ecosystem management
# =============================================================================
set -euo pipefail

GT_LOG_LABEL="sdkman"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

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
  error "curl or wget required to install SDKMAN."
  exit 1
fi

if ! has zip; then
  log "zip is required by SDKMAN but is not installed. Installing..."
  if [[ -f /etc/debian_version ]]; then
    sudo apt-get install -y zip
  elif [[ -f /etc/arch-release ]]; then
    sudo pacman -S --noconfirm zip
  else
    error "Please install zip manually before running SDKMAN."
    exit 1
  fi
fi

log "Installing SDKMAN..."
curl -fsSL "https://get.sdkman.io" | bash
success "SDKMAN installed."

_sdk_install_default "$SDKMAN_DEFAULT_JAVA"

success "SDKMAN setup complete. Reload your shell to use it."
