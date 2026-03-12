#!/usr/bin/env bash
# =============================================================================
# good-trip — bootstrap/install-zsh.sh
# Installs ZSH if not present
# =============================================================================
set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'
log()     { echo -e "${BLUE}[zsh]${NC} $*"; }
success() { echo -e "${GREEN}[zsh]${NC} ✓ $*"; }
has()     { command -v "$1" &>/dev/null; }

# Return 0 if running inside a container (docker/containerd/podman)
is_container() {
  if [[ -f "/.dockerenv" ]]; then
    return 0
  fi
  if grep -qaE 'docker|kubepods|containerd|podman' /proc/1/cgroup 2>/dev/null; then
    return 0
  fi
  return 1
}

if has zsh; then
  success "ZSH already installed: $(zsh --version)"
  # Ensure zsh is the default shell even when it was pre-installed
  if [[ "$SHELL" != "$(which zsh)" ]]; then
    log "ZSH is installed but not the default shell. Setting it as default..."
      if is_container || [[ "${NO_CHSH:-}" == "1" ]] || [[ "${NO_CHSH:-}" == "true" ]]; then
        log "Skipping shell change because running in container or NO_CHSH is set"
      else
        if chsh -s "$(which zsh)"; then
          success "Default shell changed to ZSH (restart session to apply)"
        else
          log "Could not auto-change shell. Run: chsh -s $(which zsh)"
        fi
      fi
  fi
  exit 0
fi

log "Installing ZSH..."

if [[ "$OSTYPE" == "darwin"* ]]; then
  brew install zsh
elif [[ -f /etc/arch-release ]]; then
  sudo pacman -S --noconfirm zsh
elif [[ -f /etc/debian_version ]]; then
  sudo apt-get install -y zsh
elif [[ -f /etc/fedora-release ]] || [[ -f /etc/redhat-release ]]; then
  sudo dnf install -y zsh
else
  echo "Please install ZSH manually for your OS." >&2
  exit 1
fi

success "ZSH installed: $(zsh --version)"

# Set zsh as the default shell
if [[ "$SHELL" != "$(which zsh)" ]]; then
  log "Setting default shell to ZSH..."
  if is_container || [[ "${NO_CHSH:-}" == "1" ]] || [[ "${NO_CHSH:-}" == "true" ]]; then
    log "Skipping shell change because running in container or NO_CHSH is set"
  else
    if chsh -s "$(which zsh)"; then
      success "Default shell changed to ZSH (restart session to apply)"
    else
      log "Could not auto-change shell. Run: chsh -s $(which zsh)"
    fi
  fi
fi
