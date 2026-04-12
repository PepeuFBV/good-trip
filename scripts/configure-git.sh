#!/usr/bin/env bash
# =============================================================================
# good-trip — scripts/configure-git.sh
# Interactively collect git identity and write ~/.config/good-trip/git.local
#
# Usage:
#   good-trip configure git [options]
#   bash scripts/configure-git.sh [options]
#
# Options:
#   --name    <name>     Git user name
#   --email   <email>    Git user e-mail
#   --key     <key-id>   GPG signing key ID (optional)
#   --no-sign            Disable commit signing
#   --show               Print the current local config and exit
#   --reset              Delete the local config file and exit
# =============================================================================
set -euo pipefail

LOCAL_CONFIG_DIR="${HOME}/.config/good-trip"
LOCAL_GIT_CONFIG="${LOCAL_CONFIG_DIR}/git.local"
export GT_LOG_LABEL="configure-git"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

# ── Argument parsing ──────────────────────────────────────────────────────────
ARG_NAME=""
ARG_EMAIL=""
ARG_KEY=""
ARG_NO_SIGN=false
MODE="interactive"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)   ARG_NAME="$2";  shift 2 ;;
    --email)  ARG_EMAIL="$2"; shift 2 ;;
    --key)    ARG_KEY="$2";   shift 2 ;;
    --no-sign) ARG_NO_SIGN=true; shift ;;
    --show)   MODE="show"; shift ;;
    --reset)  MODE="reset"; shift ;;
    --help|-h)
      echo ""
      echo -e "${BOLD}good-trip configure git${NC}"
      echo ""
      echo -e "${BOLD}Usage:${NC} good-trip configure git [options]"
      echo ""
      echo -e "${BOLD}Options:${NC}"
      echo "  --name  <name>    Git user name"
      echo "  --email <email>   Git user e-mail"
      echo "  --key   <key-id>  GPG signing key (optional)"
      echo "  --no-sign         Disable GPG commit signing"
      echo "  --show            Print the current local git config"
      echo "  --reset           Delete the local git config"
      echo ""
      exit 0
      ;;
    *) error "Unknown option: $1"; exit 1 ;;
  esac
done

# ── Show mode ─────────────────────────────────────────────────────────────────
if [[ "$MODE" == "show" ]]; then
  if [[ -f "$LOCAL_GIT_CONFIG" ]]; then
    echo ""
    echo -e "${BOLD}${CYAN}~/.config/good-trip/git.local${NC}"
    echo -e "${DIM}──────────────────────────────────────────${NC}"
    cat "$LOCAL_GIT_CONFIG"
    echo ""
  else
    warn "No local git config found at ${LOCAL_GIT_CONFIG}"
    log "Run: good-trip configure git"
  fi
  exit 0
fi

# ── Reset mode ────────────────────────────────────────────────────────────────
if [[ "$MODE" == "reset" ]]; then
  if [[ -f "$LOCAL_GIT_CONFIG" ]]; then
    rm -f "$LOCAL_GIT_CONFIG"
    success "Removed ${LOCAL_GIT_CONFIG}"
  else
    warn "Nothing to remove — ${LOCAL_GIT_CONFIG} does not exist."
  fi
  exit 0
fi

# ── Interactive prompts ───────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${BLUE}──────────────────────────────────────────${NC}"
echo -e "${BOLD}${BLUE}  Configure git identity${NC}"
echo -e "${BOLD}${BLUE}──────────────────────────────────────────${NC}"
echo -e "  ${DIM}Writes to: ${LOCAL_GIT_CONFIG}${NC}"
echo -e "  ${DIM}This file is never tracked in the repo.${NC}"
echo ""

# Pre-fill with existing values if file already exists
EXISTING_NAME=""
EXISTING_EMAIL=""
EXISTING_KEY=""
if [[ -f "$LOCAL_GIT_CONFIG" ]]; then
  EXISTING_NAME="$(git config --file "$LOCAL_GIT_CONFIG" user.name  2>/dev/null || true)"
  EXISTING_EMAIL="$(git config --file "$LOCAL_GIT_CONFIG" user.email 2>/dev/null || true)"
  EXISTING_KEY="$(git config  --file "$LOCAL_GIT_CONFIG" user.signingkey 2>/dev/null || true)"
  log "Updating existing config (leave blank to keep current value)."
  echo ""
fi

# Name
if [[ -n "$ARG_NAME" ]]; then
  GIT_NAME="$ARG_NAME"
else
  local_prompt="${EXISTING_NAME:+ [${EXISTING_NAME}]}"
  read -r -p "$(echo -e "${CYAN}  Git user name${NC}${local_prompt}: ")" GIT_NAME
  GIT_NAME="${GIT_NAME:-$EXISTING_NAME}"
fi

if [[ -z "$GIT_NAME" ]]; then
  error "Git user name cannot be empty."
  exit 1
fi

# Email
if [[ -n "$ARG_EMAIL" ]]; then
  GIT_EMAIL="$ARG_EMAIL"
else
  local_prompt="${EXISTING_EMAIL:+ [${EXISTING_EMAIL}]}"
  read -r -p "$(echo -e "${CYAN}  Git user email${NC}${local_prompt}: ")" GIT_EMAIL
  GIT_EMAIL="${GIT_EMAIL:-$EXISTING_EMAIL}"
fi

if [[ -z "$GIT_EMAIL" ]]; then
  error "Git user email cannot be empty."
  exit 1
fi

# GPG signing key (optional)
if $ARG_NO_SIGN; then
  GIT_SIGNING_KEY=""
  SIGN_COMMITS=false
else
  if [[ -n "$ARG_KEY" ]]; then
    GIT_SIGNING_KEY="$ARG_KEY"
    SIGN_COMMITS=true
  else
    # List available GPG keys to help the user pick one
    if has gpg || has gpg2; then
      GPG_BIN="$(command -v gpg2 2>/dev/null || command -v gpg)"
      KEYS="$("$GPG_BIN" --list-secret-keys --keyid-format LONG 2>/dev/null || true)"
      if [[ -n "$KEYS" ]]; then
        echo ""
        echo -e "${DIM}  Available GPG secret keys:${NC}"
        echo "$KEYS" | sed 's/^/    /'
        echo ""
      fi
    fi

    local_prompt="${EXISTING_KEY:+ [${EXISTING_KEY}]}"
    read -r -p "$(echo -e "${CYAN}  GPG signing key ID${NC} ${DIM}(leave blank to skip signing)${NC}${local_prompt}: ")" GIT_SIGNING_KEY
    GIT_SIGNING_KEY="${GIT_SIGNING_KEY:-$EXISTING_KEY}"

    if [[ -n "$GIT_SIGNING_KEY" ]]; then
      SIGN_COMMITS=true
    else
      SIGN_COMMITS=false
    fi
  fi
fi

# ── Write config ──────────────────────────────────────────────────────────────
mkdir -p "$LOCAL_CONFIG_DIR"

{
  echo "# good-trip — git local config"
  echo "# Generated by: good-trip configure git"
  echo "# Do NOT commit this file — it contains personal information."
  echo ""
  echo "[user]"
  echo "    name  = ${GIT_NAME}"
  echo "    email = ${GIT_EMAIL}"
  if [[ -n "$GIT_SIGNING_KEY" ]]; then
    echo "    signingkey = ${GIT_SIGNING_KEY}"
  fi
} > "$LOCAL_GIT_CONFIG"

chmod 600 "$LOCAL_GIT_CONFIG"

# ── Update gpgsign in repo git config if needed ───────────────────────────────
# We cannot easily patch the symlinked config directly, so we reflect the
# signing preference via the local config instead.
if $SIGN_COMMITS; then
  echo "" >> "$LOCAL_GIT_CONFIG"
  echo "[commit]" >> "$LOCAL_GIT_CONFIG"
  echo "    gpgsign = true" >> "$LOCAL_GIT_CONFIG"
else
  echo "" >> "$LOCAL_GIT_CONFIG"
  echo "[commit]" >> "$LOCAL_GIT_CONFIG"
  echo "    gpgsign = false" >> "$LOCAL_GIT_CONFIG"
fi

echo ""
success "Written to ${LOCAL_GIT_CONFIG}"
echo ""
echo -e "  ${BOLD}Git identity:${NC}"
echo -e "    Name  : ${GIT_NAME}"
echo -e "    Email : ${GIT_EMAIL}"
if [[ -n "$GIT_SIGNING_KEY" ]]; then
  echo -e "    Key   : ${GIT_SIGNING_KEY}"
  echo -e "    Sign  : enabled"
else
  echo -e "    Sign  : disabled"
fi
echo ""
log "To verify: git config --list --show-origin | grep user"
echo ""
