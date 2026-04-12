#!/usr/bin/env bash
# =============================================================================
# good-trip — bootstrap/install-git-gpg.sh
# Installs git + GPG, then runs the interactive git identity configurator.
# =============================================================================

set -euo pipefail

GOOD_TRIP_DIR="${GOOD_TRIP_DIR:-$HOME/.good-trip}"
GT_LOG_LABEL="git-gpg"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

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
# This script focuses on installing GPG and configuring the user identity.

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

# List existing keys informatively
KEYS="$("$GPG_BIN" --list-secret-keys --keyid-format LONG 2>/dev/null || true)"
if [[ -z "$KEYS" ]]; then
  warn "No GPG keys found. You can generate one after installation:"
  echo "  gpg --full-generate-key"
else
  success "Existing GPG keys found:"
  echo "$KEYS"
fi

# ── Git identity configuration ────────────────────────────────────────────────
LOCAL_GIT_CONFIG="${HOME}/.config/good-trip/git.local"

if [[ -f "$LOCAL_GIT_CONFIG" ]]; then
  log "Git identity already configured at ${LOCAL_GIT_CONFIG}"
  log "To update it, run: good-trip configure git"
else
  log "Setting up your git identity..."
  # Run the configure script if we have a TTY; otherwise, print instructions.
  if [[ -t 0 ]] && [[ -t 1 ]]; then
    bash "${GOOD_TRIP_DIR}/scripts/configure-git.sh"
  else
    warn "No interactive TTY — skipping git identity setup."
    warn "After installation, run: good-trip configure git"
  fi
fi

success "Git + GPG bootstrap complete."
