bats_require_minimum_version 1.5.0

setup() {
  load 'helpers/load'
  REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
}

# ── has() ─────────────────────────────────────────────────────────────────────

@test "has(): returns 0 for a command that exists (bash)" {
  run bash -c "source '${REPO_ROOT}/lib/common.sh'; has bash"
  assert_success
}

@test "has(): returns 1 for a command that does not exist" {
  run bash -c "source '${REPO_ROOT}/lib/common.sh'; has __nonexistent_cmd_xyz__"
  assert_failure
}

# ── confirm() — non-TTY path ──────────────────────────────────────────────────
# confirm() checks [[ ! -t 0 ]] to detect non-TTY stdin.
# We use `exec </dev/null` in the subprocess to sever the inherited TTY.

@test "confirm(): non-TTY with default=y returns 0 (auto-yes)" {
  run bash -c "exec </dev/null; source '${REPO_ROOT}/lib/common.sh'; confirm 'Continue?' y"
  assert_success
}

@test "confirm(): non-TTY with default=n returns 1 (auto-no)" {
  run bash -c "exec </dev/null; source '${REPO_ROOT}/lib/common.sh'; confirm 'Continue?' n"
  assert_failure
}

@test "confirm(): non-TTY with default=yes returns 0" {
  run bash -c "exec </dev/null; source '${REPO_ROOT}/lib/common.sh'; confirm 'Continue?' yes"
  assert_success
}

@test "confirm(): non-TTY with default omitted defaults to y (returns 0)" {
  run bash -c "exec </dev/null; source '${REPO_ROOT}/lib/common.sh'; confirm 'Continue?'"
  assert_success
}

@test "confirm(): non-TTY with default=no returns 1" {
  run bash -c "exec </dev/null; source '${REPO_ROOT}/lib/common.sh'; confirm 'Continue?' no"
  assert_failure
}

# ── die() ─────────────────────────────────────────────────────────────────────

@test "die(): exits with status 1" {
  run bash -c "source '${REPO_ROOT}/lib/common.sh'; die 'fatal' 2>&1"
  assert_failure
}

@test "die(): emits the provided message" {
  run bash -c "source '${REPO_ROOT}/lib/common.sh'; die 'something went wrong' 2>&1"
  assert_output --partial "something went wrong"
}

@test "die(): message contains the log label" {
  run bash -c "
    export GT_LOG_LABEL='mytest'
    source '${REPO_ROOT}/lib/common.sh'
    die 'boom' 2>&1
  "
  assert_output --partial "[mytest]"
}
