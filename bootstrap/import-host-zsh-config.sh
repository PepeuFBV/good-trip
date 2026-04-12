#!/usr/bin/env bash
# bootstrap/import-host-zsh-config.sh
# Copy zsh / Powerlevel10k config files from the host machine into the
# devcontainer if they are present.
#
# The host's $HOME is mounted read-only at /mnt/host-home by devcontainer.json.
# That directory is owned by the host user (different uid than vscode inside the
# container), so we use sudo to read across the permission boundary.
#
# Called from "postStartCommand" in devcontainer.json every time the container
# starts, after workspace ownership is fixed.

set -euo pipefail

HOST_HOME=/mnt/host-home
DEST=/home/vscode

# Files to import from the host when present.
FILES=(
    .p10k.zsh        # Powerlevel10k theme configuration
    .zsh_aliases     # Host-local aliases (optional)
    .zsh_local       # Host-local extras (optional)
)

for f in "${FILES[@]}"; do
    src="${HOST_HOME}/${f}"
    dst="${DEST}/${f}"
    if sudo test -f "${src}"; then
        sudo cp "${src}" "${dst}"
        sudo chown vscode:vscode "${dst}"
        echo "[import-host-zsh-config] Imported ${f} from host"
    fi
done
