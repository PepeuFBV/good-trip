#!/usr/bin/env bash
# =============================================================================
# good-trip — scripts/check-version.sh
# Called by .zshrc once per day (background, non-blocking).
# Writes a notification file when an update is available, then the shell
# start-up will display it once and clear it.
# =============================================================================

GOOD_TRIP_DIR="${GOOD_TRIP_DIR:-$HOME/.good-trip}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/good-trip"
NOTIFICATION_FILE="${CACHE_DIR}/update-available"

# Only run if we have network tools
command -v curl &>/dev/null || command -v wget &>/dev/null || exit 0

exec bash "${GOOD_TRIP_DIR}/scripts/update.sh" --check --silent
