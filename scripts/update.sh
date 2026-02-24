#!/usr/bin/env bash
# =============================================================================
# good-trip — scripts/update.sh
# Safe, idempotent self-updater
#
# Usage:
#   good-trip update          (interactive — asks before applying)
#   good-trip update --yes    (non-interactive)
#   good-trip update --check  (only report, never apply)
# =============================================================================
set -euo pipefail

GOOD_TRIP_DIR="${GOOD_TRIP_DIR:-$HOME/.good-trip}"
GOOD_TRIP_API="https://api.github.com/repos/PepeuFBV/good-trip/releases/latest"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

log()     { echo -e "${BLUE}[good-trip]${NC} $*"; }
success() { echo -e "${GREEN}[good-trip]${NC} ✓ $*"; }
warn()    { echo -e "${YELLOW}[good-trip]${NC} ⚠ $*"; }
error()   { echo -e "${RED}[good-trip]${NC} ✗ $*" >&2; }
has()     { command -v "$1" &>/dev/null; }

# ── Version helpers ────────────────────────────────────────────────────────────
local_version() {
  cat "${GOOD_TRIP_DIR}/version.txt" 2>/dev/null | tr -d '[:space:]' || echo "0.0.0"
}

remote_version() {
  if has curl; then
    curl -fsSL "${GOOD_TRIP_API}" 2>/dev/null \
      | grep '"tag_name"' \
      | sed 's/.*"tag_name": *"v\?\([^"]*\)".*/\1/'
  elif has wget; then
    wget -qO- "${GOOD_TRIP_API}" 2>/dev/null \
      | grep '"tag_name"' \
      | sed 's/.*"tag_name": *"v\?\([^"]*\)".*/\1/'
  else
    echo ""
  fi
}

# Compares semver strings. Returns 0 if $1 < $2 (update available).
version_lt() {
  [[ "$1" != "$2" ]] && [[ "$(printf '%s\n' "$1" "$2" | sort -V | head -1)" == "$1" ]]
}

# ── Update stamp (used by daily auto-check) ────────────────────────────────────
update_stamp() {
  local stamp_dir="${XDG_CACHE_HOME:-$HOME/.cache}/good-trip"
  mkdir -p "$stamp_dir"
  date +%s > "${stamp_dir}/last-update-check"
}

# ── Apply update ───────────────────────────────────────────────────────────────
apply_update() {
  log "Fetching latest changes..."
  git -C "${GOOD_TRIP_DIR}" fetch --tags --quiet
  local remote
  remote="$(git -C "${GOOD_TRIP_DIR}" rev-parse origin/main)"
  local local_ref
  local_ref="$(git -C "${GOOD_TRIP_DIR}" rev-parse HEAD)"

  if [[ "$remote" == "$local_ref" ]]; then
    success "Repository is already at latest commit."
  else
    git -C "${GOOD_TRIP_DIR}" pull --ff-only --quiet
    success "Repository updated."
  fi
  log "Re-applying symlinks..."
  bash "${GOOD_TRIP_DIR}/scripts/symlinks.sh"
  success "good-trip updated to $(local_version)."
  log "Restart your shell to apply changes: exec zsh"
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
  local mode="interactive"
  local silent=false
  # Ensure we always record when the check ran, even if we return early
  trap update_stamp RETURN

  for arg in "$@"; do
    case "$arg" in
      --yes|-y)     mode="auto" ;;
      --check)      mode="check" ;;
      --silent)     silent=true ;;
    esac
  done

  local local_ver
  local_ver="$(local_version)"
  local remote_ver
  remote_ver="$(remote_version)"

  if [[ -z "$remote_ver" ]]; then
    $silent || warn "Could not reach GitHub to check for updates (offline?)."
    update_stamp
    return 0
  fi

  if version_lt "$local_ver" "$remote_ver"; then
    if $silent; then
      echo -e "${YELLOW}[good-trip]${NC} Update available: ${local_ver} → ${BOLD}${remote_ver}${NC}. Run ${BOLD}good-trip update${NC} to upgrade."
    fi

    if [[ "$mode" == "check" ]]; then
      echo ""
      log "Update available!"
      echo -e "  Installed : ${BOLD}${local_ver}${NC}"
      echo -e "  Latest    : ${BOLD}${GREEN}${remote_ver}${NC}"
      echo ""
      return 0
    fi

    local do_update=false
    if [[ "$mode" == "auto" ]]; then
      do_update=true
    else
      read -r -p "$(echo -e "${YELLOW}[good-trip]${NC} Apply update? [y/N] ")" answer
      [[ "${answer,,}" =~ ^(y|yes)$ ]] && do_update=true
    fi

    if $do_update; then
      apply_update
    else
      log "Update skipped. Run 'good-trip update' anytime to upgrade."
    fi
  else
    $silent || success "good-trip is up-to-date (${local_ver})."
  fi

}

main "$@"
