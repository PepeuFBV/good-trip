#!/usr/bin/env bash
# =============================================================================
# good-trip — scripts/check-version.sh
# Called by .zshrc once per day (background, non-blocking).
# Writes a notification file when an update is available, then the shell
# start-up will display it once and clear it.
# =============================================================================

GOOD_TRIP_DIR="${GOOD_TRIP_DIR:-$HOME/.good-trip}"
GT_LOG_LABEL="good-trip"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/good-trip"
# Notification filename kept for external readers; not used directly in this
# script but used by the shell startup to detect pending updates.
# shellcheck disable=SC2034
NOTIFICATION_FILE="${CACHE_DIR}/update-available"

# Only run if we have network tools
has curl || has wget || exit 0

exec bash "${GOOD_TRIP_DIR}/scripts/update.sh" --check --silent
