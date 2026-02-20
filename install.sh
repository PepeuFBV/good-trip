#!/usr/bin/env bash
# =============================================================================
# good-trip — install.sh
# Interactive, idempotent installer for the good-trip dotfiles system
#
# Usage:
#   ./install.sh              — interactive component picker (default)
#   ./install.sh --yes        — install everything, no prompts
#   ./install.sh --minimal    — ZSH + OMZ + p10k + symlinks only
#   ./install.sh --help       — show help
#
#   curl -fsSL https://raw.githubusercontent.com/PepeuFBV/good-trip/main/install.sh | bash
# =============================================================================
set -euo pipefail

# ── Constants ─────────────────────────────────────────────────────────────────
REPO_URL="https://github.com/PepeuFBV/good-trip.git"
GOOD_TRIP_DIR="${GOOD_TRIP_DIR:-$HOME/.good-trip}"
GOOD_TRIP_BIN="${HOME}/.local/bin"
LOG_FILE="${HOME}/.local/share/good-trip/install.log"

# ── Colours ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# ── Helpers ───────────────────────────────────────────────────────────────────
log()     { echo -e "${BLUE}[good-trip]${NC} $*"; }
success() { echo -e "${GREEN}[good-trip]${NC} ✓ $*"; }
warn()    { echo -e "${YELLOW}[good-trip]${NC} ⚠ $*"; }
error()   { echo -e "${RED}[good-trip]${NC} ✗ $*" >&2; }
die()     { error "$*"; exit 1; }
has()     { command -v "$1" &>/dev/null; }

step() {
  echo ""
  echo -e "${BOLD}${BLUE}──────────────────────────────────────────${NC}"
  echo -e "${BOLD}${BLUE}  $*${NC}"
  echo -e "${BOLD}${BLUE}──────────────────────────────────────────${NC}"
}

# ── Component registry ────────────────────────────────────────────────────────
# Format: "script_name|Label|Description|default(1=on,0=off)|required(1=always)"
COMPONENTS=(
  "install-zsh.sh|ZSH|Z Shell — the core shell runtime|1|1"
  "install-ohmyzsh.sh|Oh My Zsh|Framework for managing ZSH config and plugins|1|1"
  "install-powerlevel10k.sh|Powerlevel10k|Fast, beautiful prompt theme with instant prompt|1|0"
  "install-plugins.sh|ZSH Plugins|zsh-autosuggestions and zsh-syntax-highlighting|1|0"
  "install-git-gpg.sh|Git + GPG|Git config symlink and GPG signing setup|1|0"
  "install-nvm.sh|NVM|Node Version Manager with .nvmrc auto-switching|1|0"
  "install-atuin.sh|Atuin|Searchable, syncable shell history|1|0"
  "install-docker.sh|Docker + Compose|Docker Engine, Compose plugin, add user to group|0|0"
  "install-sdkman.sh|SDKMAN|SDK manager for Java, Kotlin, Scala, Groovy|0|0"
)

# Selected state array (parallel to COMPONENTS)
declare -a SELECTED=()

# ── Interactive checkbox picker ────────────────────────────────────────────────
#
# Controls:
#   ↑ / k       — move up
#   ↓ / j       — move down
#   Space       — toggle selection
#   a           — select all
#   n           — deselect all (required items stay on)
#   Enter       — confirm and proceed
#   q / Ctrl+C  — quit
#
picker() {
  local -a labels descs required defaults
  local n=${#COMPONENTS[@]}

  for i in "${!COMPONENTS[@]}"; do
    IFS='|' read -r _script label desc default req <<< "${COMPONENTS[$i]}"
    labels[$i]="$label"
    descs[$i]="$desc"
    required[$i]="$req"
    defaults[$i]="$default"
    SELECTED[$i]="$default"
  done

  local cursor=0

  # Restore terminal on exit / Ctrl+C
  _cleanup_picker() {
    tput cnorm 2>/dev/null || true
    tput rmcup 2>/dev/null || true
    stty echo 2>/dev/null || true
  }
  trap _cleanup_picker EXIT INT TERM

  tput smcup 2>/dev/null || true   # enter alternate screen
  tput civis 2>/dev/null || true   # hide cursor
  stty -echo 2>/dev/null || true   # don't echo keystrokes

  _draw() {
    tput clear
    echo -e "${BOLD}${BLUE}"
    cat <<'ART'
   ___  ___  ___  ___     _____ ___ ___ ___
  / __|/ _ \/ _ \|   \   |_   _| _ \_ _| _ \
 | (_ | (_) | (_) | |) |    | | |  _/| ||  _/
  \___|\___/ \___/|___/     |_| |_| |___|_|
ART
    echo -e "${NC}"
    echo -e "  ${BOLD}Select components to install${NC}"
    echo -e "  ${DIM}Symlinks and good-trip CLI are always installed.${NC}"
    echo ""

    local col_w=22
    for i in $(seq 0 $((n - 1))); do
      local check desc_text prefix suffix lock=""

      if [[ "${SELECTED[$i]}" == "1" ]]; then
        check="${GREEN}✓${NC}"
      else
        check="${DIM} ${NC}"
      fi

      if [[ "${required[$i]}" == "1" ]]; then
        lock=" ${DIM}(required)${NC}"
      fi

      if [[ $i -eq $cursor ]]; then
        prefix="${BOLD}${CYAN}▶ ${NC}"
        suffix="${NC}"
        printf "  %b[%b] %-${col_w}s%b  %b%b%b\n" \
          "$prefix" "$check" "${labels[$i]}${lock}" "$suffix" \
          "${CYAN}" "${descs[$i]}" "${NC}"
      else
        printf "    [%b] %-${col_w}s  %b%s%b\n" \
          "$check" "${labels[$i]}${lock}" \
          "${DIM}" "${descs[$i]}" "${NC}"
      fi
    done

    echo ""
    echo -e "  ${DIM}↑↓ / j k  Navigate   Space  Toggle   a  All   n  None   Enter  Confirm   q  Quit${NC}"
    echo ""
  }

  while true; do
    _draw

    # Read a single keypress (including escape sequences for arrow keys)
    local key
    IFS= read -r -s -n1 key

    if [[ "$key" == $'\x1b' ]]; then
      # Escape sequence — read two more bytes
      local seq1 seq2
      IFS= read -r -s -n1 -t 0.1 seq1 || true
      IFS= read -r -s -n1 -t 0.1 seq2 || true
      key="${key}${seq1}${seq2}"
    fi

    case "$key" in
      $'\x1b[A'|k|K)  # Up arrow or k
        (( cursor > 0 )) && (( cursor-- )) || cursor=$(( n - 1 ))
        ;;
      $'\x1b[B'|j|J)  # Down arrow or j
        (( cursor < n - 1 )) && (( cursor++ )) || cursor=0
        ;;
      ' ')  # Space — toggle (skip required)
        if [[ "${required[$cursor]}" != "1" ]]; then
          if [[ "${SELECTED[$cursor]}" == "1" ]]; then
            SELECTED[$cursor]="0"
          else
            SELECTED[$cursor]="1"
          fi
        fi
        ;;
      a|A)  # Select all
        for i in $(seq 0 $((n - 1))); do SELECTED[$i]="1"; done
        ;;
      n|N)  # Deselect all non-required
        for i in $(seq 0 $((n - 1))); do
          [[ "${required[$i]}" != "1" ]] && SELECTED[$i]="0"
        done
        ;;
      ''|$'\n')  # Enter — confirm
        break
        ;;
      q|Q|$'\x03')  # q or Ctrl+C — quit
        _cleanup_picker
        echo ""
        log "Installation cancelled."
        exit 0
        ;;
    esac
  done

  _cleanup_picker
  trap - EXIT INT TERM
}

# ── OS detection ──────────────────────────────────────────────────────────────
detect_os() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
  elif [[ -f /etc/arch-release ]]; then
    OS="arch"
  elif [[ -f /etc/debian_version ]]; then
    OS="debian"
  else
    OS="unknown"
    warn "Unknown OS. Some bootstraps may fail."
  fi
  log "Detected OS: ${OS}"
}

# ── Package manager bootstrap ─────────────────────────────────────────────────
ensure_pkg_manager() {
  if [[ "$OS" == "macos" ]] && ! has brew; then
    log "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  elif [[ "$OS" == "debian" ]]; then
    log "Updating apt cache..."
    sudo apt-get update -qq
  fi
}

# ── Sudo check ────────────────────────────────────────────────────────────────
check_sudo() {
  if [[ "$EUID" -eq 0 ]]; then
    warn "Running as root."
    SUDO=""
  elif has sudo; then
    SUDO="sudo"
  else
    warn "sudo not available. Some steps may fail."
    SUDO=""
  fi
}

# ── Repo bootstrap ────────────────────────────────────────────────────────────
ensure_repo() {
  if [[ -d "${GOOD_TRIP_DIR}/.git" ]]; then
    log "Pulling latest good-trip..."
    git -C "${GOOD_TRIP_DIR}" pull --ff-only --quiet
  else
    log "Cloning good-trip into ${GOOD_TRIP_DIR}..."
    git clone --depth=1 "${REPO_URL}" "${GOOD_TRIP_DIR}"
  fi
  success "Repository ready at ${GOOD_TRIP_DIR}"
}

# ── Bootstrap runner ──────────────────────────────────────────────────────────
run_bootstrap() {
  local script="${GOOD_TRIP_DIR}/bootstrap/${1}"
  if [[ -f "$script" ]]; then
    bash "$script"
  else
    warn "Bootstrap script not found: ${1}"
  fi
}

# ── Symlinks + CLI ────────────────────────────────────────────────────────────
create_symlinks() {
  bash "${GOOD_TRIP_DIR}/scripts/symlinks.sh"
}

install_cli() {
  mkdir -p "${GOOD_TRIP_BIN}"
  local target="${GOOD_TRIP_BIN}/good-trip"
  rm -f "$target"
  ln -sf "${GOOD_TRIP_DIR}/bin/good-trip" "$target"
  chmod +x "${GOOD_TRIP_DIR}/bin/good-trip"
  success "CLI installed at ${target}"
}

setup_logging() {
  mkdir -p "$(dirname "${LOG_FILE}")"
  exec > >(tee -a "${LOG_FILE}") 2>&1
  log "Log file: ${LOG_FILE}"
}

# ── Summary screen before install ────────────────────────────────────────────
print_summary() {
  echo ""
  echo -e "${BOLD}  The following components will be installed:${NC}"
  echo ""
  for i in "${!COMPONENTS[@]}"; do
    IFS='|' read -r _script label _desc _default _req <<< "${COMPONENTS[$i]}"
    if [[ "${SELECTED[$i]}" == "1" ]]; then
      echo -e "    ${GREEN}✓${NC}  ${label}"
    fi
  done
  echo -e "    ${GREEN}✓${NC}  Symlinks  ${DIM}(always)${NC}"
  echo -e "    ${GREEN}✓${NC}  good-trip CLI  ${DIM}(always)${NC}"
  echo ""
  read -r -p "$(echo -e "${YELLOW}[good-trip]${NC} Proceed with installation? [Y/n] ")" answer
  answer="${answer:-y}"
  if [[ ! "${answer,,}" =~ ^(y|yes)$ ]]; then
    log "Installation cancelled."
    exit 0
  fi
}

# ── Help ──────────────────────────────────────────────────────────────────────
show_help() {
  echo ""
  echo -e "${BOLD}good-trip installer${NC}"
  echo ""
  echo -e "${BOLD}Usage:${NC} ./install.sh [options]"
  echo ""
  echo -e "${BOLD}Options:${NC}"
  echo "  (none)       Interactive component picker"
  echo "  --yes        Install all components, no prompts"
  echo "  --minimal    Install only: ZSH, Oh My Zsh, Powerlevel10k, symlinks, CLI"
  echo "  --help       Show this help"
  echo ""
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
  local mode="interactive"

  for arg in "$@"; do
    case "$arg" in
      --yes|-y)     mode="all" ;;
      --minimal)    mode="minimal" ;;
      --help|-h)    show_help; exit 0 ;;
    esac
  done

  # Initialise SELECTED defaults from registry
  for i in "${!COMPONENTS[@]}"; do
    IFS='|' read -r _s _l _d default _r <<< "${COMPONENTS[$i]}"
    SELECTED[$i]="$default"
  done

  case "$mode" in
    all)
      for i in "${!COMPONENTS[@]}"; do SELECTED[$i]="1"; done
      ;;
    minimal)
      for i in "${!COMPONENTS[@]}"; do
        IFS='|' read -r _s _l _d _default req <<< "${COMPONENTS[$i]}"
        SELECTED[$i]="$req"   # only required ones
      done
      ;;
    interactive)
      # Check we have a real TTY (not piped from curl)
      if [[ ! -t 0 ]]; then
        warn "No TTY detected (running via pipe?). Using --yes mode."
        warn "For interactive mode: clone the repo and run ./install.sh"
        for i in "${!COMPONENTS[@]}"; do SELECTED[$i]="1"; done
      else
        picker
      fi
      ;;
  esac

  # ── Pre-install setup ──────────────────────────────────────────────────────
  echo -e "${BOLD}"
  cat <<'BANNER'
   ___  ___  ___  ___     _____ ___ ___ ___
  / __|/ _ \/ _ \|   \   |_   _| _ \_ _| _ \
 | (_ | (_) | (_) | |) |    | | |  _/| ||  _/
  \___|\___/ \___/|___/     |_| |_| |___|_|

BANNER
  echo -e "${NC}"

  if [[ "$mode" == "interactive" ]] && [[ -t 0 ]]; then
    print_summary
  fi

  setup_logging
  detect_os
  check_sudo
  ensure_pkg_manager

  # Detect if running from a local clone or piped from curl
  if [[ -f "$(dirname "${BASH_SOURCE[0]}")/version.txt" ]]; then
    GOOD_TRIP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    log "Running from local repo: ${GOOD_TRIP_DIR}"
  else
    ensure_repo
  fi

  # ── Run selected components ────────────────────────────────────────────────
  local installed=0
  local skipped=0

  for i in "${!COMPONENTS[@]}"; do
    IFS='|' read -r script label _desc _default _req <<< "${COMPONENTS[$i]}"
    if [[ "${SELECTED[$i]}" == "1" ]]; then
      step "${label}"
      run_bootstrap "$script"
      (( installed++ )) || true
    else
      log "Skipping: ${label}"
      (( skipped++ )) || true
    fi
  done

  # ── Always-on: symlinks + CLI ──────────────────────────────────────────────
  step "Creating symlinks"
  create_symlinks

  step "Installing good-trip CLI"
  install_cli

  # ── Done ──────────────────────────────────────────────────────────────────
  echo ""
  echo -e "${BOLD}${GREEN}  ✓ good-trip installation complete!${NC}"
  echo ""
  echo -e "  ${DIM}Installed : ${installed} component(s)"
  echo -e "  Skipped   : ${skipped} component(s)${NC}"
  echo ""
  echo -e "${BOLD}  Next steps:${NC}"
  echo "    1. exec zsh                  — reload your shell"
  echo "    2. p10k configure            — set up your prompt (first time)"
  echo "    3. good-trip help            — explore available commands"
  if grep -q "docker" <<< "$(for i in "${!COMPONENTS[@]}"; do
    IFS='|' read -r s _ _ _ _ <<< "${COMPONENTS[$i]}"
    [[ "${SELECTED[$i]}" == "1" ]] && echo "$s"; done)"; then
    echo "    4. newgrp docker             — activate docker group (or re-login)"
  fi
  echo ""
  log "Version: $(cat "${GOOD_TRIP_DIR}/version.txt" 2>/dev/null || echo "unknown")"
  log "Log: ${LOG_FILE}"
  echo ""
}

main "$@"
