#!/usr/bin/env bash
# .devcontainer/scripts/import-host-codex.sh
# One-time import of Codex CLI credentials, config, plugins, and cache from
# the host machine into the devcontainer's named volume at /home/vscode/.codex.
#
# The host's $HOME is mounted read-only at /mnt/host-home.  Because some
# files (auth.json, config.toml) are mode 600 and owned by the host user
# (UID different from the container's vscode), we use sudo to read across
# the permission boundary — the same pattern used by import-host-zsh-config.sh.
#
# Only copies a file/dir when the destination does NOT already exist, so a
# rebuild never clobbers credentials or data updated inside the running container.
#
# Called from "postStartCommand" in devcontainer.json on every container start.

set -euo pipefail

HOST_CODEX=/mnt/host-home/.codex
DEST=/home/vscode/.codex

# Ensure the destination directory exists and is owned by vscode.
mkdir -p "${DEST}"

if ! sudo test -d "${HOST_CODEX}"; then
    echo "[import-host-codex] No .codex directory found on host — skipping import"
    exit 0
fi

# ── Files: copy once; never clobber container-side changes ────────────────────
# auth.json / config.toml are mode 600 on the host (different UID), so sudo is
# required to read them across the permission boundary.

FILES_600=(
    auth.json    # API keys / OAuth tokens
    config.toml  # CLI preferences
)
for f in "${FILES_600[@]}"; do
    src="${HOST_CODEX}/${f}"
    dst="${DEST}/${f}"
    if sudo test -f "${src}" && [[ ! -f "${dst}" ]]; then
        sudo cp "${src}" "${dst}"
        sudo chown vscode:vscode "${dst}"
        chmod 600 "${dst}"
        echo "[import-host-codex] Imported ${f}"
    fi
done

# Marker / cache files — world-readable on host, import once.
FILES_644=(
    .personality_migration  # skips first-run personality setup
    models_cache.json       # avoids re-fetching model list on every start
)
for f in "${FILES_644[@]}"; do
    src="${HOST_CODEX}/${f}"
    dst="${DEST}/${f}"
    if sudo test -f "${src}" && [[ ! -f "${dst}" ]]; then
        sudo cp "${src}" "${dst}"
        sudo chown vscode:vscode "${dst}"
        echo "[import-host-codex] Imported ${f}"
    fi
done

# ── Directories: import once so plugins/memories are available immediately ────
DIRS=(
    plugins    # installed plugins (e.g. github@openai-curated); missing = re-download on start
    memories   # persistent memory store
)
for d in "${DIRS[@]}"; do
    src="${HOST_CODEX}/${d}"
    dst="${DEST}/${d}"
    if sudo test -d "${src}" && [[ ! -d "${dst}" ]]; then
        sudo cp -r "${src}" "${dst}"
        sudo chown -R vscode:vscode "${dst}"
        echo "[import-host-codex] Imported ${d}/"
    fi
done

# ── Ensure directory is fully owned by vscode so CLI can persist changes ─────
sudo chown -R vscode:vscode "${DEST}"
