#!/usr/bin/env bash
# =============================================================================
# tests/unit/helpers/load.bash
# Common bats-support / bats-assert loader for all test files
# =============================================================================

# Resolve bats libs relative to this helper file
_BATS_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/bats"

load "${_BATS_LIB_DIR}/bats-support/load.bash"
load "${_BATS_LIB_DIR}/bats-assert/load.bash"

# Suppress ANSI color codes and bold escape sequences in all output so
# assert_output can match plain text without fighting escape sequences.
export NO_COLOR=1
export TERM=dumb
