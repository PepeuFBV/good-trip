#!/usr/bin/env bash
# =============================================================================
# good-trip — bootstrap/install-docker.sh
# Installs Docker Engine + Compose plugin, adds current user to docker group
# Supports: macOS (Docker Desktop via Homebrew), Debian/Ubuntu, Arch
# =============================================================================
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
log()     { echo -e "${BLUE}[docker]${NC} $*"; }
success() { echo -e "${GREEN}[docker]${NC} ✓ $*"; }
warn()    { echo -e "${YELLOW}[docker]${NC} ⚠ $*"; }
has()     { command -v "$1" &>/dev/null; }

# ── Already installed? ────────────────────────────────────────────────────────
if has docker; then
  success "Docker already installed: $(docker --version)"
  _check_compose
  _add_to_group
  exit 0
fi

# ── Helpers ───────────────────────────────────────────────────────────────────
_add_to_group() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    return 0  # no docker group on macOS
  fi
  if ! getent group docker &>/dev/null; then
    log "Creating docker group..."
    sudo groupadd docker
  fi
  if id -nG "$USER" | grep -qw docker; then
    success "User '${USER}' is already in the docker group."
  else
    log "Adding user '${USER}' to the docker group..."
    sudo usermod -aG docker "$USER"
    warn "Group membership takes effect in a new shell session."
    warn "Run: newgrp docker  (or log out and back in)"
  fi
}

_check_compose() {
  if docker compose version &>/dev/null 2>&1; then
    success "Docker Compose plugin: $(docker compose version)"
  else
    warn "Docker Compose plugin not found — will install."
    _install_compose_plugin
  fi
}

_install_compose_plugin() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    log "On macOS the Compose plugin is bundled with Docker Desktop."
    return 0
  fi
  if [[ -f /etc/debian_version ]]; then
    log "Installing docker-compose-plugin via apt..."
    sudo apt-get install -y docker-compose-plugin
  elif [[ -f /etc/arch-release ]]; then
    log "Installing docker-compose via pacman..."
    sudo pacman -S --noconfirm docker-compose
  else
    # Fallback: install Compose plugin binary manually
    local compose_version
    compose_version="$(curl -fsSL https://api.github.com/repos/docker/compose/releases/latest \
      | grep '"tag_name"' | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/')"
    local install_dir="${DOCKER_CONFIG:-$HOME/.docker}/cli-plugins"
    mkdir -p "$install_dir"
    curl -fsSL \
      "https://github.com/docker/compose/releases/download/${compose_version}/docker-compose-$(uname -s)-$(uname -m)" \
      -o "${install_dir}/docker-compose"
    chmod +x "${install_dir}/docker-compose"
    success "Docker Compose plugin (${compose_version}) installed to ${install_dir}/docker-compose"
  fi
}

# ── Install Docker ────────────────────────────────────────────────────────────
if [[ "$OSTYPE" == "darwin"* ]]; then
  log "Installing Docker Desktop via Homebrew..."
  brew install --cask docker
  success "Docker Desktop installed. Launch it from Applications to start the daemon."

elif [[ -f /etc/arch-release ]]; then
  log "Installing Docker on Arch Linux..."
  sudo pacman -S --noconfirm docker docker-compose
  sudo systemctl enable --now docker
  success "Docker installed and service enabled."
  _add_to_group

elif [[ -f /etc/debian_version ]]; then
  log "Installing Docker Engine on Debian/Ubuntu..."

  # Remove any conflicting legacy packages
  for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
    sudo apt-get remove -y "$pkg" 2>/dev/null || true
  done

  # Install prerequisites
  sudo apt-get update -qq
  sudo apt-get install -y ca-certificates curl

  # Add Docker's official GPG key and repository
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/$(. /etc/os-release && echo "$ID")/gpg \
    -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
    https://download.docker.com/linux/$(. /etc/os-release && echo "$ID") \
    $(. /etc/os-release && echo "${VERSION_CODENAME}") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt-get update -qq
  sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

  sudo systemctl enable --now docker
  success "Docker Engine + Compose plugin installed."
  _add_to_group

else
  warn "Unsupported OS. Install Docker manually: https://docs.docker.com/engine/install/"
  exit 1
fi

success "Docker: $(docker --version)"
docker compose version && success "Docker Compose plugin: $(docker compose version)"
