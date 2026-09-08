#!/usr/bin/env bats

# Bats is a testing framework for Bash
# Documentation https://bats-core.readthedocs.io/en/stable/
# Bats libraries documentation https://github.com/ztombol/bats-docs

# For local tests, install bats-core, bats-assert, bats-file, bats-support
# And run this in the add-on root directory:
#   bats ./tests/test.bats
# To exclude release tests:
#   bats ./tests/test.bats --filter-tags '!release'
# For debugging:
#   bats ./tests/test.bats --show-output-of-passing-tests --verbose-run --print-output-on-failure

setup() {
  set -eu -o pipefail

  export GITHUB_REPO=rlhawk/ddev-zsh

  TEST_BREW_PREFIX="$(brew --prefix 2>/dev/null || true)"
  export BATS_LIB_PATH="${BATS_LIB_PATH}:${TEST_BREW_PREFIX}/lib:/usr/lib/bats"
  bats_load_library bats-assert
  bats_load_library bats-file
  bats_load_library bats-support

  export DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." >/dev/null 2>&1 && pwd)"
  export PROJNAME="test-$(basename "${GITHUB_REPO}")"
  mkdir -p "${HOME}/tmp"
  export TESTDIR="$(mktemp -d "${HOME}/tmp/${PROJNAME}.XXXXXX")"
  export DDEV_NONINTERACTIVE=true
  export DDEV_NO_INSTRUMENTATION=true
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  run ddev config --project-name="${PROJNAME}" --project-tld=ddev.site
  assert_success
  run ddev start -y
  assert_success
}

teardown() {
  set -eu -o pipefail
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1
  # Persist TESTDIR if running inside GitHub Actions. Useful for uploading test result artifacts
  # See example at https://github.com/ddev/github-action-add-on-test#preserving-artifacts
  if [ -n "${GITHUB_ENV:-}" ]; then
    [ -e "${GITHUB_ENV:-}" ] && echo "TESTDIR=${HOME}/tmp/${PROJNAME}" >> "${GITHUB_ENV}"
  else
    [ "${TESTDIR}" != "" ] && rm -rf "${TESTDIR}"
  fi
}

health_checks() {
  set -eu -o pipefail

  # Verify zsh-doctor succeeds.
  run ddev zsh-doctor
  [ "$status" -eq 0 ]

  # Verify installed tools.
  ddev exec command -v zsh
  ddev exec command -v fzf
  ddev exec command -v starship

  # Verify bundled libraries.
  ddev exec test -r /usr/local/share/antidote/antidote.zsh
  ddev exec test -r /usr/local/share/oh-my-zsh/oh-my-zsh.sh

  # Verify persistent storage mount exists and is writable.
  ddev exec test -d /mnt/ddev-zsh
  ddev exec test -w /mnt/ddev-zsh
  ddev exec sh -c 'echo test >/mnt/ddev-zsh/testfile'
  ddev exec test -f /mnt/ddev-zsh/testfile

  # Verify persistent storage survives restart.
  ddev restart >/dev/null
  ddev exec test -f /mnt/ddev-zsh/testfile

  # Verify zsh starts interactively.
  run ddev exec zsh -ic 'echo success'
  [ "$status" -eq 0 ]
  [[ "$output" =~ success ]]

  # Verify pinned Starship version.
  run ddev exec starship --version
  [ "$status" -eq 0 ]
  [[ "$output" =~ 1\.26\.0 ]]

  # Verify user-facing commands exist.
  run ddev describe
  [ "$status" -eq 0 ]
  [[ "$output" =~ zsh ]]
}

@test "install from directory" {
  set -eu -o pipefail

  cd "$TESTDIR"
  echo "# ddev add-on get $DIR with project $PROJNAME in $TESTDIR ($(pwd))" >&3

  ddev add-on get "$DIR"
  ddev restart >/dev/null
  health_checks
}

# bats test_tags=release
@test "install from release" {
  set -eu -o pipefail

  cd "$TESTDIR"
  echo "# ddev add-on get rlhawk/ddev-zsh with project $PROJNAME in $TESTDIR ($(pwd))" >&3

  ddev add-on get "$GITHUB_REPO"
  ddev restart >/dev/null
  health_checks
}
