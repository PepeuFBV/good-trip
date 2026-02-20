#!/usr/bin/env bash
# =============================================================================
# good-trip — scripts/symlinks.sh
# Creates and maintains all managed symlinks idempotently.
#
# Any symlink this script manages is prefixed with a comment so users know
# which ones to edit here vs. manually managed links.
# =============================================================================
set -euo pipefail

GOOD_TRIP_DIR="${GOOD_TRIP_DIR:-$HOME/.good-trip}"
DRY_RUN=false

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()     { echo -e "${BLUE}[symlinks]${NC} $*"; }
success() { echo -e "${GREEN}[symlinks]${NC} ✓ $*"; }
warn()    { echo -e "${YELLOW}[symlinks]${NC} ⚠ $*"; }

for arg in "$@"; do
  [[ "$arg" == "--dry-run" ]] && DRY_RUN=true
done

# ── Safe link helper ──────────────────────────────────────────────────────────
# link <source_in_repo> <link_target_on_system>
link() {
  local src="${GOOD_TRIP_DIR}/${1}"
  local dst="${2/#\~/$HOME}"

  if [[ ! -e "$src" ]]; then
    warn "Source not found, skipping: ${src}"
    return 0
  fi

  # Already linked correctly?
  if [[ -L "$dst" ]] && [[ "$(readlink "$dst")" == "$src" ]]; then
    log "Already linked: ${dst}"
    return 0
  fi

  if $DRY_RUN; then
    log "[dry-run] Would link: ${dst} → ${src}"
    return 0
  fi

  # Backup existing file (not a symlink)
  if [[ -e "$dst" ]] && [[ ! -L "$dst" ]]; then
    local backup="${dst}.good-trip.bak.$(date +%Y%m%d%H%M%S)"
    warn "Backing up existing file: ${dst} → ${backup}"
    mv "$dst" "$backup"
  fi

  # Remove old symlink if pointing elsewhere
  [[ -L "$dst" ]] && rm -f "$dst"

  mkdir -p "$(dirname "$dst")"
  ln -sf "$src" "$dst"
  success "Linked: ${dst} → ${src}"
}

# ── Symlink definitions ────────────────────────────────────────────────────────
log "Applying good-trip symlinks${DRY_RUN:+ (dry-run)}..."

link "config/zsh/.zshrc"       "~/.zshrc"
link "config/git/config"       "~/.gitconfig"
link "config/aliases"          "~/.shell/aliases"

log "Done."
