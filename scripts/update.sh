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
GOOD_TRIP_RELEASES_API="https://api.github.com/repos/PepeuFBV/good-trip/releases"
LOCK_FILE="${GOOD_TRIP_DIR}/.version-lock"

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
normalize_version() {
  # Normalize to MAJOR.MINOR.PATCH (pad with .0 when needed)
  local v="$1"
  # remove any leading v or whitespace
  v="${v#v}"
  v="$(echo -n "$v" | tr -d '[:space:]')"
  IFS='.' read -r -a parts <<< "$v"
  parts[0]="${parts[0]:-0}"
  parts[1]="${parts[1]:-0}"
  parts[2]="${parts[2]:-0}"
  echo "${parts[0]}.${parts[1]}.${parts[2]}"
}

version_lt() {
  # Compare two versions after normalizing to MAJOR.MINOR.PATCH
  local a b na nb
  a="$1"; b="$2"
  na="$(normalize_version "$a")"
  nb="$(normalize_version "$b")"
  [[ "$na" != "$nb" ]] && [[ "$(printf '%s\n' "$na" "$nb" | sort -V | head -1)" == "$na" ]]
}

# ── Update stamp (used by daily auto-check) ────────────────────────────────────
update_stamp() {
  local stamp_dir="${XDG_CACHE_HOME:-$HOME/.cache}/good-trip"
  mkdir -p "$stamp_dir"
  date +%s > "${stamp_dir}/last-update-check"
}

# ── Lock helpers ─────────────────────────────────────────────────────────────
locked_version() {
  [[ -f "$LOCK_FILE" ]] && cat "$LOCK_FILE" | tr -d '[:space:]' || echo ""
}

# ── List available releases ───────────────────────────────────────────────────
cmd_list() {
  log "Fetching available releases from GitHub..."
  local response
  if has curl; then
    response="$(curl -fsSL "${GOOD_TRIP_RELEASES_API}?per_page=20" 2>/dev/null)"
  elif has wget; then
    response="$(wget -qO- "${GOOD_TRIP_RELEASES_API}?per_page=20" 2>/dev/null)"
  else
    error "curl or wget is required."
    return 1
  fi

  if [[ -z "$response" ]]; then
    error "Could not reach GitHub. Check network connection."
    return 1
  fi

  local current locked
  current="$(normalize_version "$(local_version)")"
  locked="$(locked_version)"
  [[ -n "$locked" ]] && locked="$(normalize_version "$locked")"

  echo ""
  echo -e "  ${BOLD}Available versions:${NC}"
  echo ""
  while IFS= read -r ver; do
    local na tag=""
    na="$(normalize_version "$ver")"
    [[ "$na" == "$current" ]]  && tag="${tag} ${GREEN}← installed${NC}"
    [[ -n "$locked" && "$na" == "$locked" ]] && tag="${tag} ${YELLOW}🔒 locked${NC}"
    echo -e "    ${ver}${tag}"
  done < <(echo "$response" | grep '"tag_name"' | sed 's/.*"tag_name": *"v\?\([^"]*\)".*/\1/')
  echo ""
}

# ── Install a specific version ────────────────────────────────────────────────
cmd_install_version() {
  local target_ver="$1"
  log "Fetching version ${target_ver}..."
  git -C "${GOOD_TRIP_DIR}" fetch --tags --quiet
  local tag
  for tag in "v${target_ver}" "${target_ver}"; do
    if git -C "${GOOD_TRIP_DIR}" rev-parse "${tag}" &>/dev/null 2>&1; then
      git -C "${GOOD_TRIP_DIR}" checkout --quiet "${tag}"
      bash "${GOOD_TRIP_DIR}/scripts/symlinks.sh"
      success "Installed version ${target_ver}."
      log "Restart your shell to apply changes: exec zsh"
      return 0
    fi
  done
  error "Tag '${target_ver}' not found. Run 'good-trip update --list' to see available versions."
  return 1
}

# ── Lock / unlock ─────────────────────────────────────────────────────────────
cmd_lock() {
  local lock_ver="${1:-$(local_version)}"
  local normalized
  normalized="$(normalize_version "$lock_ver")"
  echo "$normalized" > "$LOCK_FILE"
  success "Locked to ${BOLD}${normalized}${NC}. Auto-updates are suppressed."
  log "To update freely again: good-trip update --unlock"
}

cmd_unlock() {
  if [[ -f "$LOCK_FILE" ]]; then
    local was
    was="$(cat "$LOCK_FILE" | tr -d '[:space:]')"
    rm -f "$LOCK_FILE"
    success "Lock removed (was: ${was}). Auto-updates are active again."
  else
    log "No version lock is currently set."
  fi
}

# ── Apply update ───────────────────────────────────────────────────────────────
apply_update() {
  log "Fetching latest changes..."
  git -C "${GOOD_TRIP_DIR}" fetch --tags --quiet

  # If the repo is in detached HEAD state (e.g. after --version / --lock checkout),
  # switch back to the main branch before pulling.
  local head_ref
  head_ref="$(git -C "${GOOD_TRIP_DIR}" symbolic-ref --short HEAD 2>/dev/null || echo "DETACHED")"
  if [[ "$head_ref" == "DETACHED" ]]; then
    log "Detached HEAD detected — switching back to main branch..."
    if ! git -C "${GOOD_TRIP_DIR}" checkout --quiet main 2>/dev/null; then
      error "Could not switch to main branch. Run 'git -C ~/.good-trip checkout main' manually."
      return 1
    fi
  fi

  local remote local_ref
  remote="$(git -C "${GOOD_TRIP_DIR}" rev-parse origin/main)"
  local_ref="$(git -C "${GOOD_TRIP_DIR}" rev-parse HEAD)"

  if [[ "$remote" == "$local_ref" ]]; then
    success "Repository is already at latest commit."
  else
    if ! git -C "${GOOD_TRIP_DIR}" pull --ff-only --quiet; then
      error "Fast-forward pull failed. Run 'git -C ~/.good-trip pull' manually to resolve."
      return 1
    fi
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
  local target_version=""
  local lock_version=""

  # Parse arguments (while loop to support value-consuming flags)
  local args=("$@")
  local i=0
  while (( i < ${#args[@]} )); do
    case "${args[$i]}" in
      --yes|-y)   mode="auto" ;;
      --check)    mode="check" ;;
      --silent)   silent=true ;;
      --list)     mode="list" ;;
      --unlock)   mode="unlock" ;;
      --version)
        mode="version"
        i=$(( i + 1 ))
        target_version="${args[$i]:?'--version requires a version argument, e.g. --version 1.3.2'}"
        ;;
      --lock)
        mode="lock"
        # Consume next arg if it looks like a version (starts with digit or 'v')
        local _next="${args[$((i+1))]:-}"
        if [[ "$_next" =~ ^[0-9v] ]]; then
          lock_version="$_next"
          i=$(( i + 1 ))
        fi
        ;;
    esac
    i=$(( i + 1 ))
  done

  # ── Dispatch non-update modes immediately (no stamp needed) ──────────────
  case "$mode" in
    list)    cmd_list; return $? ;;
    unlock)  cmd_unlock; return $? ;;
    version)
      cmd_install_version "$target_version"
      return $?
      ;;
    lock)
      if [[ -n "$lock_version" ]]; then
        cmd_install_version "$lock_version" && cmd_lock "$lock_version"
      else
        cmd_lock
      fi
      return $?
      ;;
  esac

  # ── Auto-update modes — stamp on exit ─────────────────────────────────────
  trap update_stamp RETURN

  # ── Respect version lock ──────────────────────────────────────────────────
  local locked
  locked="$(locked_version)"
  if [[ -n "$locked" ]]; then
    if $silent; then
      warn "Version locked to ${locked}. Skipping auto-update."
    else
      warn "Version is locked to ${BOLD}${locked}${NC}."
      log "Run 'good-trip update --unlock' to re-enable auto-updates."
      log "Run 'good-trip update --list' to see available versions."
    fi
    return 0
  fi

  local local_ver
  local_ver="$(local_version)"
  local remote_ver
  remote_ver="$(remote_version)"

  if [[ -z "$remote_ver" ]]; then
    $silent || warn "Could not reach GitHub to check for updates (offline?)."
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
