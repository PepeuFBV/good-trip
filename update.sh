#!/usr/bin/env bash
# =============================================================================
# good-trip — update.sh (root convenience script)
# Delegates to the full update logic in scripts/update.sh
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec bash "${SCRIPT_DIR}/scripts/update.sh" "$@"
