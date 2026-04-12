bats_require_minimum_version 1.5.0

setup() {
  load 'helpers/load'
  REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"

  # Create a minimal fake GOOD_TRIP_DIR with required source files
  FAKE_REPO="${BATS_TEST_TMPDIR}/repo"
  mkdir -p "${FAKE_REPO}/config/zsh"
  mkdir -p "${FAKE_REPO}/config/git"
  mkdir -p "${FAKE_REPO}/config/aliases"
  echo "# zshrc stub" > "${FAKE_REPO}/config/zsh/.zshrc"
  echo "# gitconfig stub" > "${FAKE_REPO}/config/git/config"
  # aliases is a directory; touch a file inside so it exists
  touch "${FAKE_REPO}/config/aliases/.keep"

  HOME_DIR="${BATS_TEST_TMPDIR}/home"
  mkdir -p "$HOME_DIR"
}

# Helper: invoke link() in a subshell with isolatable state
_run_link() {
  # _run_link [--dry-run] <src_relative> <dst>
  local dry_run_flag=""
  if [[ "${1:-}" == "--dry-run" ]]; then
    dry_run_flag="DRY_RUN=true"
    shift
  fi
  local src="$1" dst="$2"
  run bash -c "
    export HOME='${HOME_DIR}'
    GOOD_TRIP_DIR='${FAKE_REPO}'
    export GT_LOG_LABEL='symlinks'
    source '${REPO_ROOT}/lib/common.sh'
    source '${REPO_ROOT}/scripts/symlinks.sh'
    ${dry_run_flag}
    link '${src}' '${dst}'
  "
}

# ── link(): source not found ───────────────────────────────────────────────────

@test "link(): warns and returns 0 when source file does not exist" {
  _run_link "config/zsh/nonexistent" "${HOME_DIR}/.zshrc"
  assert_success
  assert_output --partial "Source not found"
}

# ── link(): normal creation ────────────────────────────────────────────────────

@test "link(): creates a symlink pointing to the repo source" {
  _run_link "config/zsh/.zshrc" "${HOME_DIR}/.zshrc"
  assert_success
  assert [ -L "${HOME_DIR}/.zshrc" ]
  run readlink "${HOME_DIR}/.zshrc"
  assert_output "${FAKE_REPO}/config/zsh/.zshrc"
}

@test "link(): reports success after creating the symlink" {
  _run_link "config/zsh/.zshrc" "${HOME_DIR}/.zshrc"
  assert_success
  assert_output --partial "Linked"
}

# ── link(): idempotency ────────────────────────────────────────────────────────

@test "link(): is idempotent when symlink already points to the correct target" {
  # Pre-create the correct symlink
  ln -sf "${FAKE_REPO}/config/zsh/.zshrc" "${HOME_DIR}/.zshrc"

  _run_link "config/zsh/.zshrc" "${HOME_DIR}/.zshrc"
  assert_success
  assert_output --partial "Already linked"
  # Symlink still points to the correct target
  run readlink "${HOME_DIR}/.zshrc"
  assert_output "${FAKE_REPO}/config/zsh/.zshrc"
}

# ── link(): backup of existing regular file ──────────────────────────────────

@test "link(): backs up an existing regular file before linking" {
  echo "# old zshrc" > "${HOME_DIR}/.zshrc"

  _run_link "config/zsh/.zshrc" "${HOME_DIR}/.zshrc"
  assert_success

  # Backup must exist alongside the symlink
  local bak_count
  bak_count="$(ls -1 "${HOME_DIR}/.zshrc.good-trip.bak."* 2>/dev/null | wc -l)"
  [[ "$bak_count" -eq 1 ]]

  # Backup must contain the original content
  run cat "${HOME_DIR}/.zshrc.good-trip.bak."*
  assert_output --partial "old zshrc"
}

@test "link(): the destination is a symlink after backing up a regular file" {
  echo "# old zshrc" > "${HOME_DIR}/.zshrc"
  _run_link "config/zsh/.zshrc" "${HOME_DIR}/.zshrc"
  assert_success
  assert [ -L "${HOME_DIR}/.zshrc" ]
}

# ── link(): stale symlink replacement ─────────────────────────────────────────

@test "link(): replaces a stale symlink pointing to a different target" {
  ln -sf "/tmp/some-other-target" "${HOME_DIR}/.zshrc"

  _run_link "config/zsh/.zshrc" "${HOME_DIR}/.zshrc"
  assert_success
  run readlink "${HOME_DIR}/.zshrc"
  assert_output "${FAKE_REPO}/config/zsh/.zshrc"
}

# ── link(): dry-run ────────────────────────────────────────────────────────────

@test "link(): dry-run makes no filesystem change when dst is absent" {
  _run_link --dry-run "config/zsh/.zshrc" "${HOME_DIR}/.zshrc"
  assert_success
  # dst must NOT have been created
  assert [ ! -e "${HOME_DIR}/.zshrc" ]
}

@test "link(): dry-run output contains [dry-run] marker" {
  _run_link --dry-run "config/zsh/.zshrc" "${HOME_DIR}/.zshrc"
  assert_success
  assert_output --partial "[dry-run]"
}

@test "link(): dry-run does not overwrite an existing regular file" {
  echo "# original content" > "${HOME_DIR}/.zshrc"
  _run_link --dry-run "config/zsh/.zshrc" "${HOME_DIR}/.zshrc"
  assert_success
  # Original file must be untouched
  assert [ -f "${HOME_DIR}/.zshrc" ]
  assert [ ! -L "${HOME_DIR}/.zshrc" ]
  run cat "${HOME_DIR}/.zshrc"
  assert_output --partial "original content"
}
