#!/usr/bin/env bash
# =============================================================================
# good-trip — install.sh
# One-shot idempotent installer for the good-trip dotfiles system
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/PepeuFBV/good-trip/main/install.sh | bash
#   # or, from inside the cloned repo:
#   ./install.sh [--update]
# =============================================================================
set -euo pipefail

# ── Constants ─────────────────────────────────────────────────────────────────
REPO_URL="https://github.com/PepeuFBV/good-trip.git"
GOOD_TRIP_DIR="${GOOD_TRIP_DIR:-$HOME/.good-trip}"
GOOD_TRIP_BIN="${HOME}/.local/bin"
LOG_FILE="${HOME}/.local/share/good-trip/install.log"
VERSION_FILE="${GOOD_TRIP_DIR}/version.txt"

# ── Colours ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Colour

# ── Helpers ───────────────────────────────────────────────────────────────────
log()     { echo -e "${BLUE}[good-trip]${NC} $*"; }
success() { echo -e "${GREEN}[good-trip]${NC} ✓ $*"; }
warn()    { echo -e "${YELLOW}[good-trip]${NC} ⚠ $*"; }
error()   { echo -e "${RED}[good-trip]${NC} ✗ $*" >&2; }
die()     { error "$*"; exit 1; }

step() {
  echo ""
  echo -e "${BOLD}${BLUE}──────────────────────────────────────────${NC}"
  echo -e "${BOLD}${BLUE}  $*${NC}"
  echo -e "${BOLD}${BLUE}──────────────────────────────────────────${NC}"
}

has() { command -v "$1" &>/dev/null; }

confirm() {
  local prompt="${1:-Continue?}"
  read -r -p "$(echo -e "${YELLOW}[good-trip]${NC} ${prompt} [y/N] ")" answer
  [[ "${answer,,}" =~ ^(y|yes)$ ]]
}

# ── OS detection ──────────────────────────────────────────────────────────────
detect_os() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    PKG_INSTALL="brew install"
  elif [[ -f /etc/arch-release ]]; then
    OS="arch"
    PKG_INSTALL="sudo pacman -S --noconfirm"
  elif [[ -f /etc/debian_version ]]; then
    OS="debian"
    PKG_INSTALL="sudo apt-get install -y"
  else
    OS="unknown"
    PKG_INSTALL=""
    warn "Unknown OS. Some bootstraps may fail."
  fi
  log "Detected OS: ${OS}"
}

# ── Package manager check ─────────────────────────────────────────────────────
ensure_pkg_manager() {
  if [[ "$OS" == "macos" ]] && ! has brew; then
    log "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  elif [[ "$OS" == "debian" ]]; then
    log "Updating apt cache..."
    sudo apt-get update -qq
  fi
}

# ── Check for sudo ────────────────────────────────────────────────────────────
check_sudo() {
  if [[ "$EUID" -eq 0 ]]; then
    warn "Running as root. sudo calls will be skipped."
    SUDO=""
  elif has sudo && sudo -n true 2>/dev/null; then
    SUDO="sudo"
  elif has sudo; then
    log "This installer may need sudo for system packages."
    SUDO="sudo"
  else
    warn "sudo not available. Some steps may fail if packages aren't installed."
    SUDO=""
  fi
}

# ── Clone or update the repo ──────────────────────────────────────────────────
ensure_repo() {
  if [[ -d "${GOOD_TRIP_DIR}/.git" ]]; then
    log "good-trip already cloned at ${GOOD_TRIP_DIR}. Pulling latest..."
    git -C "${GOOD_TRIP_DIR}" pull --ff-only --quiet
  else
    log "Cloning good-trip into ${GOOD_TRIP_DIR}..."
    git clone --depth=1 "${REPO_URL}" "${GOOD_TRIP_DIR}"
  fi
  success "Repository ready at ${GOOD_TRIP_DIR}"
}

# ── Run a bootstrap script ────────────────────────────────────────────────────
run_bootstrap() {
  local script="${GOOD_TRIP_DIR}/bootstrap/${1}"
  if [[ -f "$script" ]]; then
    log "Running bootstrap: ${1}..."
    bash "$script"
  else
    warn "Bootstrap script not found: ${1}"
  fi
}

# ── Create symlinks ───────────────────────────────────────────────────────────
create_symlinks() {
  bash "${GOOD_TRIP_DIR}/scripts/symlinks.sh"
}

# ── Install good-trip CLI ─────────────────────────────────────────────────────
install_cli() {
  mkdir -p "${GOOD_TRIP_BIN}"
  local target="${GOOD_TRIP_BIN}/good-trip"
  if [[ -L "$target" ]] || [[ -f "$target" ]]; then
    rm -f "$target"
  fi
  ln -sf "${GOOD_TRIP_DIR}/bin/good-trip" "$target"
  chmod +x "${GOOD_TRIP_DIR}/bin/good-trip"

  # Ensure ~/.local/bin is on PATH in the new .zshrc (symlinks.sh handles ~/.zshrc)
  success "CLI installed at ${target}"
}

# ── Logging setup ─────────────────────────────────────────────────────────────
setup_logging() {
  mkdir -p "$(dirname "${LOG_FILE}")"
  exec > >(tee -a "${LOG_FILE}") 2>&1
  log "Log file: ${LOG_FILE}"
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
  echo -e "${BOLD}"
  cat <<'BANNER'
   ___  ___  ___  ___     _____ ___ ___ ___
  / __|/ _ \/ _ \|   \   |_   _| _ \_ _| _ \
 | (_ | (_) | (_) | |) |    | | |  _/| ||  _/
  \___|\___/ \___/|___/     |_| |_| |___|_|

BANNER
  echo -e "${NC}"
  log "Starting good-trip installation..."

  local version
  version="$(cat "${GOOD_TRIP_DIR}/version.txt" 2>/dev/null || echo "unknown")"
  log "Version: ${version}"

  setup_logging
  detect_os
  check_sudo
  ensure_pkg_manager

  # ── If running from a cloned repo (not piped from curl) ──────────────────
  if [[ -f "$(dirname "${BASH_SOURCE[0]}")/version.txt" ]]; then
    GOOD_TRIP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    log "Running from local repo: ${GOOD_TRIP_DIR}"
  else
    ensure_repo
  fi

  step "Installing core dependencies"
  run_bootstrap "install-zsh.sh"

  step "Setting up Oh My Zsh"
  run_bootstrap "install-ohmyzsh.sh"

  step "Installing Powerlevel10k"
  run_bootstrap "install-powerlevel10k.sh"

  step "Installing ZSH plugins"
  run_bootstrap "install-plugins.sh"

  step "Installing NVM"
  run_bootstrap "install-nvm.sh"

  step "Installing SDKMAN"
  run_bootstrap "install-sdkman.sh"

  step "Installing Atuin"
  run_bootstrap "install-atuin.sh"

  step "Configuring Git + GPG"
  run_bootstrap "install-git-gpg.sh"

  step "Creating symlinks"
  create_symlinks

  step "Installing CLI"
  install_cli

  echo ""
  success "good-trip installation complete!"
  echo ""
  log "Installed version: $(cat "${GOOD_TRIP_DIR}/version.txt" 2>/dev/null || echo "unknown")"
  echo ""
  echo -e "${BOLD}Next steps:${NC}"
  echo "  1. Reload your shell: exec zsh"
  echo "  2. Configure your prompt: p10k configure"
  echo "  3. Run 'good-trip help' to explore commands"
  echo ""
}

main "$@"
