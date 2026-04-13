#!/usr/bin/env bash
# =============================================================================
# good-trip — lib/common.sh
# Shared shell helpers used by the installer, CLI, and operational scripts.
# =============================================================================

: "${GT_LOG_LABEL:=good-trip}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
# shellcheck disable=SC2034
CYAN='\033[0;36m'
BOLD='\033[1m'
# shellcheck disable=SC2034
DIM='\033[2m'
NC='\033[0m'

log()     { echo -e "${BLUE}[${GT_LOG_LABEL}]${NC} $*"; }
success() { echo -e "${GREEN}[${GT_LOG_LABEL}]${NC} ✓ $*"; }
warn()    { echo -e "${YELLOW}[${GT_LOG_LABEL}]${NC} ⚠ $*"; }
error()   { echo -e "${RED}[${GT_LOG_LABEL}]${NC} ✗ $*" >&2; }
die()     { error "$*"; exit 1; }
has()     { command -v "$1" &>/dev/null; }

step() {
  echo ""
  echo -e "${BOLD}${BLUE}──────────────────────────────────────────${NC}"
  echo -e "${BOLD}${BLUE}  $*${NC}"
  echo -e "${BOLD}${BLUE}──────────────────────────────────────────${NC}"
}

confirm() {
  local prompt="${1:?prompt is required}"
  local default="${2:-y}"
  local answer fallback suffix default_lc

  # tr[:upper:] is used instead of ${var,,} for bash 3.2 (macOS) compatibility
  default_lc="$(printf '%s' "$default" | tr '[:upper:]' '[:lower:]')"
  case "$default_lc" in
    y|yes)
      fallback="y"
      suffix="[Y/n]"
      ;;
    *)
      fallback="n"
      suffix="[y/N]"
      ;;
  esac

  if [[ ! -t 0 ]]; then
    [[ "$fallback" == "y" ]]
    return
  fi

  read -r -p "$(echo -e "${YELLOW}[${GT_LOG_LABEL}]${NC} ${prompt} ${suffix} ")" answer
  answer="${answer:-$fallback}"
  [[ "$(printf '%s' "$answer" | tr '[:upper:]' '[:lower:]')" =~ ^(y|yes)$ ]]
}

is_container() {
  [[ -f "/.dockerenv" ]] && return 0
  grep -qaE 'docker|kubepods|containerd|podman' /proc/1/cgroup 2>/dev/null && return 0
  return 1
}
