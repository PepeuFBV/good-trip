bats_require_minimum_version 1.5.0

setup() {
  load 'helpers/load'
  REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
  # Each test uses its own isolated tmpdir via BATS_TEST_TMPDIR
}

# Helper: run a snippet sourcing update.sh with GOOD_TRIP_DIR=$1
_run_update() {
  local gt_dir="$1"; shift
  run bash -c "
    GOOD_TRIP_DIR='${gt_dir}'
    source '${REPO_ROOT}/scripts/update.sh'
    $*
  "
}

# ── normalize_version() ────────────────────────────────────────────────────────

@test "normalize_version: passes through a full x.y.z version unchanged" {
  run bash -c "source '${REPO_ROOT}/scripts/update.sh'; normalize_version '1.2.3'"
  assert_success
  assert_output "1.2.3"
}

@test "normalize_version: strips leading v prefix" {
  run bash -c "source '${REPO_ROOT}/scripts/update.sh'; normalize_version 'v1.2.3'"
  assert_success
  assert_output "1.2.3"
}

@test "normalize_version: pads x.y to x.y.0" {
  run bash -c "source '${REPO_ROOT}/scripts/update.sh'; normalize_version '1.2'"
  assert_success
  assert_output "1.2.0"
}

@test "normalize_version: pads x to x.0.0" {
  run bash -c "source '${REPO_ROOT}/scripts/update.sh'; normalize_version '1'"
  assert_success
  assert_output "1.0.0"
}

@test "normalize_version: strips v prefix on two-part version" {
  run bash -c "source '${REPO_ROOT}/scripts/update.sh'; normalize_version 'v2.10'"
  assert_success
  assert_output "2.10.0"
}

# ── version_lt() ──────────────────────────────────────────────────────────────

@test "version_lt: 1.2.2 < 1.2.3 → returns 0" {
  run bash -c "source '${REPO_ROOT}/scripts/update.sh'; version_lt '1.2.2' '1.2.3'"
  assert_success
}

@test "version_lt: 1.0.0 < 2.0.0 → returns 0" {
  run bash -c "source '${REPO_ROOT}/scripts/update.sh'; version_lt '1.0.0' '2.0.0'"
  assert_success
}

@test "version_lt: equal versions return 1 (not less than)" {
  run bash -c "source '${REPO_ROOT}/scripts/update.sh'; version_lt '1.2.3' '1.2.3'"
  assert_failure
}

@test "version_lt: greater version returns 1 (not less than)" {
  run bash -c "source '${REPO_ROOT}/scripts/update.sh'; version_lt '2.0.0' '1.9.9'"
  assert_failure
}

@test "version_lt: accepts v-prefixed versions" {
  run bash -c "source '${REPO_ROOT}/scripts/update.sh'; version_lt 'v1.5.0' 'v1.6.0'"
  assert_success
}

# ── local_version() ───────────────────────────────────────────────────────────

@test "local_version: reads content of version.txt" {
  local tmpdir="${BATS_TEST_TMPDIR}"
  echo "2.3.4" > "${tmpdir}/version.txt"
  _run_update "$tmpdir" "local_version"
  assert_success
  assert_output "2.3.4"
}

@test "local_version: returns 0.0.0 when version.txt is absent" {
  local tmpdir="${BATS_TEST_TMPDIR}"
  rm -f "${tmpdir}/version.txt"
  _run_update "$tmpdir" "local_version"
  assert_success
  assert_output "0.0.0"
}

# ── locked_version() ─────────────────────────────────────────────────────────

@test "locked_version: returns content of .version-lock" {
  local tmpdir="${BATS_TEST_TMPDIR}"
  echo "1.5.0" > "${tmpdir}/.version-lock"
  _run_update "$tmpdir" "locked_version"
  assert_success
  assert_output "1.5.0"
}

@test "locked_version: returns empty string when .version-lock is absent" {
  local tmpdir="${BATS_TEST_TMPDIR}"
  rm -f "${tmpdir}/.version-lock"
  _run_update "$tmpdir" "locked_version"
  assert_success
  assert_output ""
}

# ── update_stamp() ────────────────────────────────────────────────────────────

@test "update_stamp: creates the cache directory when absent" {
  local tmpdir="${BATS_TEST_TMPDIR}"
  run bash -c "
    GOOD_TRIP_DIR='${tmpdir}'
    XDG_CACHE_HOME='${tmpdir}/cache'
    source '${REPO_ROOT}/scripts/update.sh'
    update_stamp
  "
  assert_success
  assert [ -d "${tmpdir}/cache/good-trip" ]
}

@test "update_stamp: writes a numeric unix timestamp to last-update-check" {
  local tmpdir="${BATS_TEST_TMPDIR}"
  run bash -c "
    GOOD_TRIP_DIR='${tmpdir}'
    XDG_CACHE_HOME='${tmpdir}/cache'
    source '${REPO_ROOT}/scripts/update.sh'
    update_stamp
  "
  assert_success
  local stamp_file="${tmpdir}/cache/good-trip/last-update-check"
  assert [ -f "$stamp_file" ]
  # Content must be a positive integer (unix timestamp)
  run bash -c "[[ \"\$(cat '${stamp_file}')\" =~ ^[0-9]+$ ]]"
  assert_success
}

# ── cmd_lock() / cmd_unlock() ─────────────────────────────────────────────────

@test "cmd_lock: writes the normalized version to .version-lock" {
  local tmpdir="${BATS_TEST_TMPDIR}"
  mkdir -p "$tmpdir"
  run bash -c "
    GOOD_TRIP_DIR='${tmpdir}'
    source '${REPO_ROOT}/scripts/update.sh'
    cmd_lock '1.5.0'
  "
  assert_success
  assert [ -f "${tmpdir}/.version-lock" ]
  run cat "${tmpdir}/.version-lock"
  assert_output "1.5.0"
}

@test "cmd_lock: normalizes a v-prefixed version before writing" {
  local tmpdir="${BATS_TEST_TMPDIR}"
  mkdir -p "$tmpdir"
  run bash -c "
    GOOD_TRIP_DIR='${tmpdir}'
    source '${REPO_ROOT}/scripts/update.sh'
    cmd_lock 'v2.0.0'
  "
  assert_success
  run cat "${tmpdir}/.version-lock"
  assert_output "2.0.0"
}

@test "cmd_unlock: removes .version-lock" {
  local tmpdir="${BATS_TEST_TMPDIR}"
  mkdir -p "$tmpdir"
  echo "1.5.0" > "${tmpdir}/.version-lock"
  run bash -c "
    GOOD_TRIP_DIR='${tmpdir}'
    source '${REPO_ROOT}/scripts/update.sh'
    cmd_unlock
  "
  assert_success
  assert [ ! -f "${tmpdir}/.version-lock" ]
}

@test "cmd_unlock: is idempotent when no lock file exists" {
  local tmpdir="${BATS_TEST_TMPDIR}"
  rm -f "${tmpdir}/.version-lock"
  run bash -c "
    GOOD_TRIP_DIR='${tmpdir}'
    source '${REPO_ROOT}/scripts/update.sh'
    cmd_unlock
  "
  assert_success
}
