#!/usr/bin/env bash
# =============================================================================
# good-trip — scripts/ssh-github.sh
#
# Registers an SSH public key with a GitHub account via the GitHub REST API.
# Requires a GitHub Personal Access Token with the `write:public_key` scope.
#
# Usage:
#   good-trip ssh-github [options]
#
# Options:
#   --key <path>         Path to the public key file (default: ~/.ssh/id_ed25519.pub)
#   --title <text>       Key title shown in GitHub    (default: user@hostname — date)
#   --token <token>      GitHub PAT (avoids interactive prompt)
#   --list               List SSH keys already on the account (read:public_key scope)
#   --dry-run            Show what would be sent without calling the API
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

log()     { echo -e "${BLUE}[ssh-github]${NC} $*"; }
success() { echo -e "${GREEN}[ssh-github]${NC} ✓ $*"; }
warn()    { echo -e "${YELLOW}[ssh-github]${NC} ⚠ $*"; }
error()   { echo -e "${RED}[ssh-github]${NC} ✗ $*" >&2; }
has()     { command -v "$1" &>/dev/null; }

# ── Defaults ──────────────────────────────────────────────────────────────────
KEY_PATH="${HOME}/.ssh/id_ed25519.pub"
TITLE="${USER:-user}@$(hostname -s 2>/dev/null || echo host) — $(date +%Y-%m-%d)"
GH_TOKEN="${GITHUB_TOKEN:-}"
LIST_ONLY=false
DRY_RUN=false

# ── Argument parsing ──────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --key)       KEY_PATH="$2";          shift 2 ;;
    --title)     TITLE="$2";             shift 2 ;;
    --token)     GH_TOKEN="$2";          shift 2 ;;
    --list)      LIST_ONLY=true;         shift ;;
    --dry-run)   DRY_RUN=true;           shift ;;
    --help|-h)
      echo ""
      echo -e "${BOLD}good-trip ssh-github${NC} — Register an SSH key with your GitHub account"
      echo ""
      echo -e "${BOLD}Usage:${NC}"
      echo "  good-trip ssh-github [options]"
      echo ""
      echo -e "${BOLD}Options:${NC}"
      echo "  --key <path>       Path to .pub file  (default: ~/.ssh/id_ed25519.pub)"
      echo "  --title <text>     Key title on GitHub (default: user@host — date)"
      echo "  --token <token>    GitHub PAT          (or set \$GITHUB_TOKEN env var)"
      echo "  --list             List keys already on your GitHub account"
      echo "  --dry-run          Show API payload without sending"
      echo ""
      echo -e "${BOLD}Token scopes needed:${NC}"
      echo "  write:public_key   — to add a key"
      echo "  read:public_key    — to list keys (--list)"
      echo ""
      echo -e "${BOLD}Create a token at:${NC}"
      echo "  https://github.com/settings/tokens/new?scopes=write:public_key"
      echo ""
      echo -e "${BOLD}Examples:${NC}"
      echo "  good-trip ssh-github"
      echo "  good-trip ssh-github --key ~/.ssh/deploy.pub --title 'prod server'"
      echo "  good-trip ssh-github --list"
      echo "  GITHUB_TOKEN=ghp_xxx good-trip ssh-github"
      echo ""
      exit 0
      ;;
    *)
      error "Unknown option: $1"
      echo "Run 'good-trip ssh-github --help' for usage."
      exit 1
      ;;
  esac
done

# ── Dependency check ──────────────────────────────────────────────────────────
if ! has curl; then
  error "curl is required but not installed."
  exit 1
fi

# ── Token resolution ──────────────────────────────────────────────────────────
_prompt_token() {
  echo ""
  warn "No GitHub token found."
  echo ""
  log "A Personal Access Token (PAT) with ${BOLD}write:public_key${NC} scope is required."
  log "Create one at: ${CYAN}https://github.com/settings/tokens/new?scopes=write:public_key${NC}"
  echo ""
  # Read without echoing (stty may not work in all envs)
  if [[ -t 0 ]]; then
    read -r -s -p "$(echo -e "${YELLOW}[ssh-github]${NC} Paste your GitHub token: ")" GH_TOKEN
    echo ""
  else
    error "No TTY available and no token provided. Use --token or \$GITHUB_TOKEN."
    exit 1
  fi
  if [[ -z "$GH_TOKEN" ]]; then
    error "No token entered. Aborting."
    exit 1
  fi
}

_api() {
  local method="$1"; shift
  local endpoint="$1"; shift
  curl -fsSL \
    -X "$method" \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${GH_TOKEN}" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com${endpoint}" \
    "$@"
}

# ── List mode ─────────────────────────────────────────────────────────────────
if $LIST_ONLY; then
  [[ -z "$GH_TOKEN" ]] && _prompt_token

  log "Fetching SSH keys from GitHub..."
  echo ""

  RESPONSE="$(_api GET /user/keys 2>&1)" || {
    error "API request failed. Check your token and network connection."
    error "Response: ${RESPONSE}"
    exit 1
  }

  if ! has python3; then
    # Fallback: raw JSON
    echo "$RESPONSE"
    exit 0
  fi

  echo "$RESPONSE" | python3 - << 'PYEOF'
import sys, json
keys = json.load(sys.stdin)
if not keys:
    print("  (no SSH keys registered on this account)")
else:
    for k in keys:
        print(f"  [{k['id']}]  {k['title']}")
        print(f"         {k['key'][:60]}...")
        print(f"         Created: {k.get('created_at','?')}")
        print()
PYEOF
  exit 0
fi

# ── Validate public key file ──────────────────────────────────────────────────
if [[ ! -f "$KEY_PATH" ]]; then
  error "Public key not found: ${KEY_PATH}"
  echo ""
  log "Generate one first with:"
  echo "  good-trip ssh-keygen"
  exit 1
fi

PUB_KEY="$(cat "$KEY_PATH" | tr -d '\n')"

if [[ -z "$PUB_KEY" ]]; then
  error "Public key file is empty: ${KEY_PATH}"
  exit 1
fi

# ── Dry-run mode ──────────────────────────────────────────────────────────────
if $DRY_RUN; then
  log "Dry-run mode — no API call will be made."
  echo ""
  log "API endpoint : POST https://api.github.com/user/keys"
  log "Key file     : ${KEY_PATH}"
  log "Title        : ${TITLE}"
  echo ""
  echo -e "${BOLD}Payload:${NC}"
  echo "  {"
  echo "    \"title\": \"${TITLE}\","
  echo "    \"key\":   \"${PUB_KEY}\""
  echo "  }"
  echo ""
  exit 0
fi

# ── Get token if not set ──────────────────────────────────────────────────────
[[ -z "$GH_TOKEN" ]] && _prompt_token

# ── Confirm before sending ────────────────────────────────────────────────────
echo ""
log "About to add the following SSH key to your GitHub account:"
echo ""
echo -e "  ${BOLD}Title :${NC} ${TITLE}"
echo -e "  ${BOLD}Key   :${NC} ${PUB_KEY:0:72}..."
echo -e "  ${BOLD}File  :${NC} ${KEY_PATH}"
echo ""

if [[ -t 0 ]]; then
  read -r -p "$(echo -e "${YELLOW}[ssh-github]${NC} Proceed? [Y/n] ")" answer
  answer="${answer:-y}"
  if [[ ! "${answer,,}" =~ ^(y|yes)$ ]]; then
    log "Aborted."
    exit 0
  fi
fi

# ── Send the API request ──────────────────────────────────────────────────────
log "Sending request to GitHub API..."

BODY="$(printf '{"title":"%s","key":"%s"}' "$TITLE" "$PUB_KEY")"

HTTP_RESPONSE="$(
  curl -sS \
    -o /tmp/good-trip-gh-response.json \
    -w "%{http_code}" \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${GH_TOKEN}" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    -H "Content-Type: application/json" \
    -d "$BODY" \
    "https://api.github.com/user/keys"
)"

RESPONSE_BODY="$(cat /tmp/good-trip-gh-response.json 2>/dev/null || echo '{}')"
rm -f /tmp/good-trip-gh-response.json

# ── Handle response ───────────────────────────────────────────────────────────
if [[ "$HTTP_RESPONSE" == "201" ]]; then
  KEY_ID="$(echo "$RESPONSE_BODY" | grep -o '"id":[0-9]*' | head -1 | cut -d: -f2)"
  echo ""
  success "SSH key added to GitHub!"
  echo ""
  echo -e "  ${BOLD}Title  :${NC} ${TITLE}"
  echo -e "  ${BOLD}Key ID :${NC} ${KEY_ID:-unknown}"
  echo ""
  log "View it at: ${CYAN}https://github.com/settings/keys${NC}"
  echo ""
elif [[ "$HTTP_RESPONSE" == "422" ]]; then
  # Already exists or validation error
  MSG="$(echo "$RESPONSE_BODY" | grep -o '"message":"[^"]*"' | head -1 | cut -d'"' -f4)"
  if echo "$MSG" | grep -qi "already"; then
    warn "This key is already registered on your GitHub account."
  else
    error "Validation error (HTTP 422): ${MSG:-see response below}"
    echo "$RESPONSE_BODY"
    exit 1
  fi
elif [[ "$HTTP_RESPONSE" == "401" ]]; then
  error "Unauthorized (HTTP 401). Check that your token is valid and has 'write:public_key' scope."
  exit 1
else
  error "Unexpected response (HTTP ${HTTP_RESPONSE}):"
  echo "$RESPONSE_BODY"
  exit 1
fi
