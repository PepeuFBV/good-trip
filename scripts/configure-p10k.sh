#!/usr/bin/env bash
# =============================================================================
# good-trip — scripts/configure-p10k.sh
# Import a Powerlevel10k config file (~/.p10k.zsh)
# =============================================================================
set -euo pipefail

GT_LOG_LABEL="p10k"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

P10K_TARGET="$HOME/.p10k.zsh"

usage() {
  echo ""
  echo "Usage: good-trip configure p10k --import <file>"
  echo "       good-trip configure p10k --show"
  echo "       good-trip configure p10k --reset"
  echo ""
  echo "Options:"
  echo "  --import <file>   Copy <file> to ~/.p10k.zsh"
  echo "  --show            Print the path and first lines of ~/.p10k.zsh"
  echo "  --reset           Remove ~/.p10k.zsh (triggers p10k configure on next shell start)"
  echo ""
}

cmd_import() {
  local src="${1:-}"
  if [[ -z "$src" ]]; then
    error "--import requires a file path argument."
    usage
    exit 1
  fi

  if [[ ! -f "$src" ]]; then
    error "File not found: $src"
    exit 1
  fi

  # Backup existing config if present
  if [[ -f "$P10K_TARGET" ]]; then
    local backup
    backup="${P10K_TARGET}.bak.$(date +%Y%m%d%H%M%S)"
    warn "Backing up existing ~/.p10k.zsh to ${backup}"
    cp "$P10K_TARGET" "$backup"
  fi

  cp "$src" "$P10K_TARGET"
  success "Powerlevel10k config imported from ${src} → ${P10K_TARGET}"
  log "Reload your shell or run: source ~/.p10k.zsh"
}

cmd_show() {
  if [[ ! -f "$P10K_TARGET" ]]; then
    warn "No ~/.p10k.zsh found. Run 'p10k configure' or 'good-trip configure p10k --import <file>'."
    exit 0
  fi
  log "File: ${P10K_TARGET}"
  echo ""
  head -20 "$P10K_TARGET"
  echo "..."
}

cmd_reset() {
  if [[ ! -f "$P10K_TARGET" ]]; then
    warn "No ~/.p10k.zsh found — nothing to remove."
    exit 0
  fi
  rm -f "$P10K_TARGET"
  success "Removed ~/.p10k.zsh. Run 'p10k configure' on next shell reload to reconfigure."
}

# ── Argument parsing ──────────────────────────────────────────────────────────
if [[ $# -eq 0 ]]; then
  usage
  exit 0
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --import)
      shift
      cmd_import "${1:-}"
      shift || true
      ;;
    --show)
      cmd_show
      shift
      ;;
    --reset)
      cmd_reset
      shift
      ;;
    --help|-h)
      usage
      shift
      ;;
    *)
      error "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done
