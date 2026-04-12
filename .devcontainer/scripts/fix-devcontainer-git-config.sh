#!/usr/bin/env bash
# .devcontainer/scripts/fix-devcontainer-git-config.sh
# Keep the tracked repo git config out of the devcontainer's live ~/.gitconfig.
#
# The installer links ~/.gitconfig to config/git/config. VS Code's devcontainer
# integration appends a temporary credential helper to the global git config on
# attach, which would otherwise dirty the tracked repo file every time the
# container is created or reopened.

set -euo pipefail

GOOD_TRIP_DIR="${GOOD_TRIP_DIR:-/home/vscode/workspace}"
REPO_GIT_CONFIG="${GOOD_TRIP_DIR}/config/git/config"
TARGET_GIT_CONFIG="${HOME}/.gitconfig"
MANAGED_HEADER="# Managed by good-trip devcontainer bootstrap."

write_wrapper() {
    cat > "${TARGET_GIT_CONFIG}" <<EOF_WRAPPER
${MANAGED_HEADER}
# Keeps editor-injected git settings out of tracked repo files.
[include]
    path = ${REPO_GIT_CONFIG}
EOF_WRAPPER
    chmod 644 "${TARGET_GIT_CONFIG}"
}

remove_vscode_helper_from_repo_config() {
    local helper

    while IFS= read -r helper; do
        if [[ "${helper}" == *".vscode-server/bin/"* ]] && [[ "${helper}" == *"git-credential-helper"* ]]; then
            git config --file "${REPO_GIT_CONFIG}" --fixed-value --unset-all credential.helper "${helper}"
            echo "[fix-devcontainer-git-config] Removed VS Code credential helper from tracked git config"
        fi
    done < <(git config --file "${REPO_GIT_CONFIG}" --get-all credential.helper 2>/dev/null || true)
}

if [[ ! -f "${REPO_GIT_CONFIG}" ]]; then
    echo "[fix-devcontainer-git-config] Repo git config not found at ${REPO_GIT_CONFIG} - skipping"
    exit 0
fi

remove_vscode_helper_from_repo_config

if [[ -L "${TARGET_GIT_CONFIG}" ]] && [[ "$(readlink "${TARGET_GIT_CONFIG}")" == "${REPO_GIT_CONFIG}" ]]; then
    rm -f "${TARGET_GIT_CONFIG}"
    write_wrapper
    echo "[fix-devcontainer-git-config] Replaced ~/.gitconfig symlink with managed wrapper"
    exit 0
fi

if [[ ! -e "${TARGET_GIT_CONFIG}" ]]; then
    write_wrapper
    echo "[fix-devcontainer-git-config] Created managed ~/.gitconfig wrapper"
    exit 0
fi

if grep -Fq "${MANAGED_HEADER}" "${TARGET_GIT_CONFIG}" 2>/dev/null; then
    write_wrapper
    echo "[fix-devcontainer-git-config] Refreshed managed ~/.gitconfig wrapper"
    exit 0
fi

echo "[fix-devcontainer-git-config] Leaving existing ~/.gitconfig untouched"
