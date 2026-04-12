#!/usr/bin/env bash
# =============================================================================
# good-trip — tests/run_unit_tests.sh
# Bootstraps bats if needed, then runs all tests under tests/unit/
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BATS_BIN="${SCRIPT_DIR}/bats/bats-core/bin/bats"
UNIT_DIR="${SCRIPT_DIR}/unit"

# Bootstrap bats if not yet cloned
if [[ ! -x "$BATS_BIN" ]]; then
  bash "${SCRIPT_DIR}/setup-bats.sh"
fi

echo ""
echo "Running good-trip unit tests…"
echo ""

"$BATS_BIN" \
  --print-output-on-failure \
  "${UNIT_DIR}"
