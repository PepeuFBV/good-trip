bats_require_minimum_version 1.5.0

setup() {
  load 'helpers/load'
  REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"

  FAKE_REPO="${BATS_TEST_TMPDIR}/repo"
  mkdir -p "${FAKE_REPO}"
  HOME_DIR="${BATS_TEST_TMPDIR}/home"
  mkdir -p "${HOME_DIR}"
}

# Helper: run a snippet in a subshell with uninstall.sh sourced
_run_uninstall() {
  run bash -c "
    export HOME='${HOME_DIR}'
    GOOD_TRIP_DIR='${FAKE_REPO}'
    source '${REPO_ROOT}/scripts/uninstall.sh'
    $*
  "
}

# ── do_remove(): dry-run ──────────────────────────────────────────────────────

@test "do_remove(): dry-run leaves the file untouched" {
  local target="${BATS_TEST_TMPDIR}/somefile"
  echo "keep me" > "$target"

  _run_uninstall "DRY_RUN=true; do_remove '${target}' 'test file'"
  assert_success
  assert [ -f "$target" ]
}

@test "do_remove(): dry-run outputs [dry-run] marker" {
  local target="${BATS_TEST_TMPDIR}/somefile"
  touch "$target"

  _run_uninstall "DRY_RUN=true; do_remove '${target}' 'test file'"
  assert_success
  assert_output --partial "[dry-run]"
}

@test "do_remove(): removes the file when DRY_RUN=false" {
  local target="${BATS_TEST_TMPDIR}/somefile"
  echo "remove me" > "$target"

  _run_uninstall "DRY_RUN=false; do_remove '${target}' 'test file'"
  assert_success
  assert [ ! -e "$target" ]
}

@test "do_remove(): removes a directory recursively when DRY_RUN=false" {
  local target="${BATS_TEST_TMPDIR}/somedir"
  mkdir -p "${target}/nested"
  touch "${target}/nested/file"

  _run_uninstall "DRY_RUN=false; do_remove '${target}' 'test dir'"
  assert_success
  assert [ ! -e "$target" ]
}

# ── restore_link(): guard — only manages links inside GOOD_TRIP_DIR ───────────

@test "restore_link(): leaves untouched a symlink pointing outside GOOD_TRIP_DIR" {
  local external="/tmp/external-target"
  local link_path="${HOME_DIR}/.zshrc"
  ln -sf "$external" "$link_path"

  _run_uninstall "DRY_RUN=false; restore_link '${link_path}'"
  assert_success
  # Symlink must still point to the external target
  assert [ -L "$link_path" ]
  run readlink "$link_path"
  assert_output "$external"
}

@test "restore_link(): warns when symlink points outside GOOD_TRIP_DIR" {
  local link_path="${HOME_DIR}/.zshrc"
  ln -sf "/tmp/external" "$link_path"

  _run_uninstall "DRY_RUN=false; restore_link '${link_path}'"
  assert_success
  assert_output --partial "outside good-trip"
}

@test "restore_link(): skips a path that is not a symlink" {
  local path="${HOME_DIR}/.zshrc"
  echo "regular file" > "$path"

  _run_uninstall "DRY_RUN=false; restore_link '${path}'"
  assert_success
  # Regular file must be untouched
  assert [ -f "$path" ]
  assert [ ! -L "$path" ]
}

# ── restore_link(): removal of a managed symlink ──────────────────────────────

@test "restore_link(): removes a symlink pointing inside GOOD_TRIP_DIR" {
  local link_path="${HOME_DIR}/.zshrc"
  local target="${FAKE_REPO}/config/zsh/.zshrc"
  mkdir -p "$(dirname "$target")"
  touch "$target"
  ln -sf "$target" "$link_path"

  _run_uninstall "DRY_RUN=false; restore_link '${link_path}'"
  assert_success
  assert [ ! -L "$link_path" ]
}

@test "restore_link(): restores the most recent backup when one exists" {
  local link_path="${HOME_DIR}/.zshrc"
  local bak_path="${link_path}.good-trip.bak.20260101120000"
  local target="${FAKE_REPO}/config/zsh/.zshrc"
  mkdir -p "$(dirname "$target")"
  touch "$target"
  ln -sf "$target" "$link_path"
  echo "# original zshrc" > "$bak_path"

  _run_uninstall "DRY_RUN=false; restore_link '${link_path}'"
  assert_success
  # Backup must now be a regular file at the link_path location
  assert [ -f "$link_path" ]
  assert [ ! -L "$link_path" ]
  run cat "$link_path"
  assert_output --partial "original zshrc"
}

# ── restore_link(): dry-run ────────────────────────────────────────────────────

@test "restore_link(): dry-run makes no filesystem change" {
  local link_path="${HOME_DIR}/.zshrc"
  local target="${FAKE_REPO}/config/zsh/.zshrc"
  mkdir -p "$(dirname "$target")"
  touch "$target"
  ln -sf "$target" "$link_path"

  _run_uninstall "DRY_RUN=true; restore_link '${link_path}'"
  assert_success
  # Symlink must still exist
  assert [ -L "$link_path" ]
}

@test "restore_link(): dry-run outputs [dry-run] marker" {
  local link_path="${HOME_DIR}/.zshrc"
  local target="${FAKE_REPO}/config/zsh/.zshrc"
  mkdir -p "$(dirname "$target")"
  touch "$target"
  ln -sf "$target" "$link_path"

  _run_uninstall "DRY_RUN=true; restore_link '${link_path}'"
  assert_success
  assert_output --partial "[dry-run]"
}
