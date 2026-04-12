bats_require_minimum_version 1.5.0

setup() {
  load 'helpers/load'
  REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
  CLI="${REPO_ROOT}/bin/good-trip"
  export GOOD_TRIP_DIR="${REPO_ROOT}"
}

# ── help / version dispatch ────────────────────────────────────────────────────

@test "CLI: 'help' exits 0 and prints usage" {
  run "$CLI" help
  assert_success
  assert_output --partial "Usage:"
}

@test "CLI: '--help' exits 0 and prints usage" {
  run "$CLI" --help
  assert_success
  assert_output --partial "Usage:"
}

@test "CLI: '-h' exits 0 and prints usage" {
  run "$CLI" -h
  assert_success
  assert_output --partial "Usage:"
}

@test "CLI: no arguments defaults to help (exits 0)" {
  run "$CLI"
  assert_success
  assert_output --partial "Usage:"
}

@test "CLI: 'version' exits 0" {
  run "$CLI" version
  assert_success
}

@test "CLI: 'version' output contains 'good-trip'" {
  run "$CLI" version
  assert_success
  assert_output --partial "good-trip"
}

@test "CLI: '--version' exits 0 and includes a version number" {
  run "$CLI" --version
  assert_success
  assert_output --partial "good-trip"
}

# ── status ────────────────────────────────────────────────────────────────────

@test "CLI: 'status' exits 0" {
  run "$CLI" status
  assert_success
}

@test "CLI: 'status' reports installed version" {
  run "$CLI" status
  assert_success
  assert_output --partial "Installed version"
}

@test "CLI: 'status' reports symlink state" {
  run "$CLI" status
  assert_success
  assert_output --partial "Symlinks"
}

# ── error path ────────────────────────────────────────────────────────────────

@test "CLI: unknown command exits non-zero" {
  run bash -c "'${CLI}' __unknown_command_xyz__ 2>&1"
  assert_failure
}

@test "CLI: unknown command prints 'Unknown command'" {
  run bash -c "GOOD_TRIP_DIR='${REPO_ROOT}' '${CLI}' __unknown_command_xyz__ 2>&1"
  assert_failure
  assert_output --partial "Unknown command"
}

@test "CLI: 'configure' with no subcommand exits non-zero" {
  run bash -c "GOOD_TRIP_DIR='${REPO_ROOT}' '${CLI}' configure 2>&1"
  assert_failure
}

@test "CLI: 'configure' with unknown service exits non-zero" {
  run bash -c "GOOD_TRIP_DIR='${REPO_ROOT}' '${CLI}' configure __nosuchservice__ 2>&1"
  assert_failure
}
