#!/usr/bin/env bash
# =============================================================================
# good-trip — tests/setup-bats.sh
# Downloads bats-core, bats-support, and bats-assert into tests/bats/
# if they are not already present. Idempotent.
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BATS_DIR="${SCRIPT_DIR}/bats"

_clone_or_skip() {
  local repo="$1" dest="$2" label="$3"
  if [[ -d "$dest" ]]; then
    echo "  [bats-setup] ${label} already present — skipping"
    return 0
  fi
  echo "  [bats-setup] Cloning ${label}..."
  git clone --depth=1 --quiet "https://github.com/bats-core/${repo}.git" "$dest"
  echo "  [bats-setup] ${label} ready"
}

echo ""
echo "[bats-setup] Setting up bats-core test dependencies in tests/bats/"
echo ""

_clone_or_skip "bats-core"    "${BATS_DIR}/bats-core"    "bats-core"
_clone_or_skip "bats-support" "${BATS_DIR}/bats-support" "bats-support"
_clone_or_skip "bats-assert"  "${BATS_DIR}/bats-assert"  "bats-assert"

echo ""
echo "[bats-setup] All dependencies ready."
echo ""
