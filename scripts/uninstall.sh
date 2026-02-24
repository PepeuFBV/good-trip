#!/usr/bin/env bash
# =============================================================================
# good-trip — scripts/uninstall.sh
# Removes all good-trip managed files and optionally the install directory.
#
# Usage:
#   good-trip uninstall              — interactive (asks before each action)
#   good-trip uninstall --yes        — non-interactive, remove everything
#   good-trip uninstall --purge      — also delete ~/.good-trip directory
#   good-trip uninstall --dry-run    — show what would be removed, no changes
# =============================================================================
set -euo pipefail

GOOD_TRIP_DIR="${GOOD_TRIP_DIR:-$HOME/.good-trip}"
GOOD_TRIP_BIN="${HOME}/.local/bin/good-trip"
LOG_FILE="${HOME}/.local/share/good-trip/install.log"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/good-trip"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

log()     { echo -e "${BLUE}[good-trip]${NC} $*"; }
success() { echo -e "${GREEN}[good-trip]${NC} ✓ $*"; }
warn()    { echo -e "${YELLOW}[good-trip]${NC} ⚠ $*"; }
error()   { echo -e "${RED}[good-trip]${NC} ✗ $*" >&2; }

# ── Flags ──────────────────────────────────────────────────────────────────────
YES=false
PURGE=false
DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
    --yes|-y)    YES=true ;;
    --purge)     PURGE=true ;;
    --dry-run)   DRY_RUN=true ;;
  esac
done

# ── Helpers ────────────────────────────────────────────────────────────────────
ask() {
  # ask <prompt> — returns 0 (yes) or 1 (no)
  # If --yes was passed, always return 0.
  $YES && return 0
  local answer
  read -r -p "$(echo -e "${YELLOW}[good-trip]${NC} $1 [y/N] ")" answer
  answer="${answer:-n}"
  [[ "${answer,,}" =~ ^(y|yes)$ ]]
}

do_remove() {
  # do_remove <path> <description>
  local path="$1" desc="$2"
  if $DRY_RUN; then
    log "[dry-run] Would remove: ${path}  (${desc})"
    return 0
  fi
  rm -rf "$path"
  success "Removed: ${path}  (${desc})"
}

# ── Restore a managed symlink ─────────────────────────────────────────────────
# Looks for the most recent .good-trip.bak.* alongside the symlink target and
# restores it when available.
restore_link() {
  local dst="${1/#\~/$HOME}"

  if [[ ! -L "$dst" ]]; then
    log "Not a symlink, skipping: ${dst}"
    return 0
  fi

  local current_target
  current_target="$(readlink "$dst")"

  # Only remove links that point inside GOOD_TRIP_DIR
  if [[ "$current_target" != "${GOOD_TRIP_DIR}"* ]]; then
    warn "Symlink ${dst} points outside good-trip — leaving untouched."
    return 0
  fi

  if $DRY_RUN; then
    log "[dry-run] Would remove symlink: ${dst}"
    # Check for backup
    local latest_bak
    latest_bak="$(ls -1t "${dst}.good-trip.bak."* 2>/dev/null | head -1 || true)"
    [[ -n "$latest_bak" ]] && log "[dry-run] Would restore: ${latest_bak} → ${dst}"
    return 0
  fi

  rm -f "$dst"
  success "Removed symlink: ${dst}"

  # Restore the most recent backup if one exists
  local latest_bak
  latest_bak="$(ls -1t "${dst}.good-trip.bak."* 2>/dev/null | head -1 || true)"
  if [[ -n "$latest_bak" ]]; then
    mv "$latest_bak" "$dst"
    success "Restored backup: ${latest_bak} → ${dst}"
  fi
}

# ── Main uninstall flow ────────────────────────────────────────────────────────
main() {
  echo ""
  echo -e "${BOLD}${RED}  good-trip uninstaller${NC}"
  echo ""

  if $DRY_RUN; then
    warn "Dry-run mode — no changes will be made."
    echo ""
  fi

  # 1. Remove managed symlinks
  if ask "Remove managed symlinks (~/.zshrc, ~/.gitconfig, ~/.shell/aliases)?"; then
    restore_link "~/.zshrc"
    restore_link "~/.gitconfig"
    restore_link "~/.shell/aliases"
  fi

  # 2. Remove CLI binary
  if [[ -L "$GOOD_TRIP_BIN" || -f "$GOOD_TRIP_BIN" ]]; then
    if ask "Remove good-trip CLI (${GOOD_TRIP_BIN})?"; then
      do_remove "$GOOD_TRIP_BIN" "CLI binary"
    fi
  else
    log "CLI binary not found at ${GOOD_TRIP_BIN} — already removed."
  fi

  # 3. Remove log file
  if [[ -f "$LOG_FILE" ]]; then
    if ask "Remove install log (${LOG_FILE})?"; then
      do_remove "$LOG_FILE" "install log"
    fi
  fi

  # 4. Remove cache directory
  if [[ -d "$CACHE_DIR" ]]; then
    if ask "Remove cache directory (${CACHE_DIR})?"; then
      do_remove "$CACHE_DIR" "cache"
    fi
  fi

  # 5. Purge the good-trip directory (opt-in via --purge or interactive prompt)
  if [[ -d "$GOOD_TRIP_DIR" ]]; then
    local purge_approved=false
    if $PURGE; then
      purge_approved=true
    elif ask "Delete good-trip directory (${GOOD_TRIP_DIR})? This removes all dotfiles managed by good-trip."; then
      purge_approved=true
    fi

    if $purge_approved; then
      do_remove "$GOOD_TRIP_DIR" "good-trip directory"
    else
      log "Kept: ${GOOD_TRIP_DIR}"
    fi
  fi

  echo ""
  if $DRY_RUN; then
    log "Dry-run complete — no changes were made."
  else
    success "good-trip uninstall complete."
    echo ""
    echo -e "  ${DIM}Reload your shell to pick up any restored config files.${NC}"
  fi
  echo ""
}

main "$@"
