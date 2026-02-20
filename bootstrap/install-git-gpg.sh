#!/usr/bin/env bash
# =============================================================================
# good-trip — bootstrap/install-git-gpg.sh
# Configures Git (writes ~/.gitconfig via symlink) and helps set up GPG signing
# =============================================================================
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
log()     { echo -e "${BLUE}[git-gpg]${NC} $*"; }
success() { echo -e "${GREEN}[git-gpg]${NC} ✓ $*"; }
warn()    { echo -e "${YELLOW}[git-gpg]${NC} ⚠ $*"; }
has()     { command -v "$1" &>/dev/null; }

# ── Git presence check ────────────────────────────────────────────────────────
if ! has git; then
  log "Installing git..."
  if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install git
  elif [[ -f /etc/debian_version ]]; then
    sudo apt-get install -y git
  elif [[ -f /etc/arch-release ]]; then
    sudo pacman -S --noconfirm git
  fi
fi
success "Git: $(git --version)"

# ── Symlink for ~/.gitconfig is handled by scripts/symlinks.sh ───────────────
# This script focuses on the GPG portion.

# ── GPG setup ─────────────────────────────────────────────────────────────────
if ! has gpg && ! has gpg2; then
  log "Installing GPG..."
  if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install gnupg pinentry-mac
  elif [[ -f /etc/debian_version ]]; then
    sudo apt-get install -y gnupg
  elif [[ -f /etc/arch-release ]]; then
    sudo pacman -S --noconfirm gnupg
  fi
fi

GPG_BIN="$(command -v gpg2 2>/dev/null || command -v gpg 2>/dev/null)"
success "GPG: $("$GPG_BIN" --version | head -1)"

# List existing keys
KEYS="$("$GPG_BIN" --list-secret-keys --keyid-format LONG 2>/dev/null)"

if [[ -z "$KEYS" ]]; then
  warn "No GPG keys found."
  echo ""
  log "To generate a new GPG key:"
  echo "  gpg --full-generate-key"
  echo ""
  log "Then update 'config/git/config' with your key ID:"
  echo "  [user]"
  echo "      signingkey = <YOUR_KEY_ID>"
  echo ""
else
  success "Existing GPG keys found:"
  echo "$KEYS"
  log "Ensure [user].signingkey in config/git/config matches your key."
fi

# Ensure GPG_TTY is exportable (already in .zshrc)
success "Git + GPG configuration complete."
