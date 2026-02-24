#!/usr/bin/env bash
# =============================================================================
# good-trip — scripts/ssh-keygen.sh
#
# Quick SSH key generator intended to be run on a server.
# Generates an Ed25519 key pair, prints the public key, and optionally
# appends it to ~/.ssh/authorized_keys so the machine becomes accessible.
#
# Usage:
#   good-trip ssh-keygen [options]
#
# Options:
#   --comment <text>     Key comment, e.g. your email  (default: user@hostname)
#   --name <filename>    Key file name without path     (default: id_ed25519)
#   --authorized-keys    Also append pubkey to ~/.ssh/authorized_keys
#   --force              Overwrite existing key without prompting
#   --dry-run            Print what would happen without writing anything
# =============================================================================
set -euo pipefail

# ── Colours ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

log()     { echo -e "${BLUE}[ssh-keygen]${NC} $*"; }
success() { echo -e "${GREEN}[ssh-keygen]${NC} ✓ $*"; }
warn()    { echo -e "${YELLOW}[ssh-keygen]${NC} ⚠ $*"; }
error()   { echo -e "${RED}[ssh-keygen]${NC} ✗ $*" >&2; }

# ── Defaults ──────────────────────────────────────────────────────────────────
COMMENT="${USER:-user}@$(hostname -s 2>/dev/null || echo host)"
KEY_NAME=""
ADD_TO_AUTHORIZED=false
DRY_RUN=false
DRY_RUN=false

# ── Argument parsing ──────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --comment)       COMMENT="$2";        shift 2 ;;
    --name)          KEY_NAME="$2";       shift 2 ;;
    --authorized-keys) ADD_TO_AUTHORIZED=true; shift ;;
    --dry-run)       DRY_RUN=true;        shift ;;
    --help|-h)
      echo ""
      echo -e "${BOLD}good-trip ssh-keygen${NC} — Quick SSH key generator (for servers)"
      echo ""
      echo -e "${BOLD}Usage:${NC}"
      echo "  good-trip ssh-keygen [options]"
      echo ""
      echo -e "${BOLD}Options:${NC}"
      echo "  --comment <text>     Key comment, e.g. your email  (default: user@hostname)"
      echo "  --name <filename>    Key file name without path     (required)"
      echo "  --authorized-keys    Also append pubkey to ~/.ssh/authorized_keys"
      echo "  --dry-run            Show what would happen without writing files"
      echo ""
      echo -e "${BOLD}Examples:${NC}"
      echo "  good-trip ssh-keygen"
      echo "  good-trip ssh-keygen --comment me@example.com --authorized-keys"
      echo "  good-trip ssh-keygen --name deploy_key --force"
      echo ""
      exit 0
      ;;
    *)
      error "Unknown option: $1"
      echo "Run 'good-trip ssh-keygen --help' for usage."
      exit 1
      ;;
  esac
done

SSH_DIR="${HOME}/.ssh"
KEY_PATH="${SSH_DIR}/${KEY_NAME}"
PUB_PATH="${KEY_PATH}.pub"
AUTH_KEYS="${SSH_DIR}/authorized_keys"

# ── Require name and reject existing key names (validate before dry-run) ──────
if [[ -z "$KEY_NAME" ]]; then
  error "Missing required option: --name <filename>"
  echo "Run 'good-trip ssh-keygen --help' for usage."
  exit 1
fi

if [[ -f "$KEY_PATH" ]] || [[ -f "$PUB_PATH" ]]; then
  error "Key already exists: ${KEY_PATH} or ${PUB_PATH}. Choose a different --name."
  exit 1
fi

# ── Dry-run mode ──────────────────────────────────────────────────────────────
if $DRY_RUN; then
  log "Dry-run mode — no files will be written."
  log "Would create key  : ${KEY_PATH}"
  log "Would create pub  : ${PUB_PATH}"
  log "Comment           : ${COMMENT}"
  $ADD_TO_AUTHORIZED && log "Would append to   : ${AUTH_KEYS}"
  exit 0
fi

# ── Ensure ~/.ssh exists with correct permissions ─────────────────────────────
if [[ ! -d "$SSH_DIR" ]]; then
  log "Creating ${SSH_DIR} ..."
  mkdir -p "$SSH_DIR"
  chmod 700 "$SSH_DIR"
fi



# ── Generate the key ──────────────────────────────────────────────────────────
log "Generating Ed25519 key: ${KEY_PATH}"
log "Comment: ${COMMENT}"
echo ""
ssh-keygen -t ed25519 -C "$COMMENT" -f "$KEY_PATH" -N ""
chmod 600 "$KEY_PATH"
chmod 644 "$PUB_PATH"
success "Key pair created."

# ── Optionally add to authorized_keys ────────────────────────────────────────
if $ADD_TO_AUTHORIZED; then
  touch "$AUTH_KEYS"
  chmod 600 "$AUTH_KEYS"
  PUB_CONTENT="$(cat "$PUB_PATH")"
  if grep -qF "$PUB_CONTENT" "$AUTH_KEYS" 2>/dev/null; then
    log "Public key already in authorized_keys, skipping."
  else
    echo "$PUB_CONTENT" >> "$AUTH_KEYS"
    success "Public key appended to ${AUTH_KEYS}"
  fi
fi

# ── Print the public key prominently ─────────────────────────────────────────
echo ""
echo -e "${BOLD}${CYAN}┌─────────────────────────────────────────────────────────┐${NC}"
echo -e "${BOLD}${CYAN}│  Public key — copy and store this somewhere safe        │${NC}"
echo -e "${BOLD}${CYAN}└─────────────────────────────────────────────────────────┘${NC}"
cat "$PUB_PATH"
echo ""

echo -e "${BOLD}  Private key :${NC} ${KEY_PATH}"
echo -e "${BOLD}  Public key  :${NC} ${PUB_PATH}"
if $ADD_TO_AUTHORIZED; then
  echo -e "${BOLD}  Added to    :${NC} ${AUTH_KEYS}"
fi

echo ""
echo -e "${BLUE}[ssh-keygen]${NC} Next steps:"
if ! $ADD_TO_AUTHORIZED; then
  echo "  • To allow access to THIS machine, run:"
  echo "      good-trip ssh-keygen --authorized-keys"
  echo "    or manually:"
  echo "      cat ${PUB_PATH} >> ~/.ssh/authorized_keys"
fi
echo "  • To add this key to GitHub:"
echo "      good-trip ssh-github"
echo ""
success "Done."
