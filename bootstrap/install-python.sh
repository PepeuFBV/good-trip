#!/usr/bin/env bash
# =============================================================================
# good-trip — bootstrap/install-python.sh
# Installs Python 3, pip, and venv support (idempotent)
# =============================================================================
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()     { echo -e "${BLUE}[python]${NC} $*"; }
success() { echo -e "${GREEN}[python]${NC} ✓ $*"; }
warn()    { echo -e "${YELLOW}[python]${NC} ⚠ $*"; }
error()   { echo -e "${RED}[python]${NC} ✗ $*" >&2; }
has()     { command -v "$1" &>/dev/null; }

# ── Detect OS ─────────────────────────────────────────────────────────────────
detect_os() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
  elif [[ -f /etc/arch-release ]]; then
    OS="arch"
  elif [[ -f /etc/debian_version ]]; then
    OS="debian"
  else
    OS="unknown"
  fi
}

# ── Install Python + pip + venv ───────────────────────────────────────────────
install_python() {
  detect_os

  case "$OS" in
    macos)
      if has python3 && has pip3; then
        log "Python 3 already available via Homebrew or system."
      else
        log "Installing python via Homebrew..."
        brew install python
      fi

      # brew installs pip3 alongside python; ensure pip is accessible
      if ! has pip3; then
        warn "pip3 not found after install. Trying ensurepip..."
        python3 -m ensurepip --upgrade
      fi

      # venv is bundled with Python 3.3+; verify
      if ! python3 -m venv --help &>/dev/null; then
        warn "venv module not found."
      fi
      ;;

    arch)
      log "Installing python, python-pip, python-virtualenv via pacman..."
      sudo pacman -S --noconfirm --needed python python-pip python-virtualenv
      ;;

    debian)
      log "Installing python3, python3-pip, python3-venv via apt..."
      sudo apt-get install -y python3 python3-pip python3-venv python3-dev
      ;;

    *)
      error "Unsupported OS: ${OS}. Install Python 3 manually."
      exit 1
      ;;
  esac
}

# ── Upgrade pip to latest ─────────────────────────────────────────────────────
upgrade_pip() {
  local python_bin
  python_bin="$(command -v python3 || command -v python)"

  if [[ -z "$python_bin" ]]; then
    error "Python binary not found after installation."
    return 1
  fi

  log "Upgrading pip..."
  "$python_bin" -m pip install --upgrade pip --quiet
}

# ── Verify venv works ─────────────────────────────────────────────────────────
verify_venv() {
  local python_bin
  python_bin="$(command -v python3 || command -v python)"

  log "Verifying venv support..."
  local tmpdir
  tmpdir="$(mktemp -d)"
  if "$python_bin" -m venv "$tmpdir" &>/dev/null; then
    rm -rf "$tmpdir"
    success "venv is working."
  else
    rm -rf "$tmpdir"
    warn "venv test failed. You may need to install python3-venv manually."
  fi
}

# ── Summary ───────────────────────────────────────────────────────────────────
print_versions() {
  echo ""
  local py pip
  py="$(python3 --version 2>/dev/null || python --version 2>/dev/null || echo 'not found')"
  pip="$(python3 -m pip --version 2>/dev/null | awk '{print $1, $2}' || echo 'not found')"
  success "Python  : ${py}"
  success "pip     : ${pip}"
  success "venv    : bundled with Python (python3 -m venv <dir>)"
  echo ""
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
  log "Setting up Python, pip, and venv..."
  install_python
  upgrade_pip
  verify_venv
  print_versions
}

main "$@"
