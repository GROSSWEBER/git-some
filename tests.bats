#!/usr/bin/env bats

load 'test/helpers/assert/load'
load 'test/helpers/support/load'
load 'test/helpers/mocks/stub'

stubs=(git)
cwd="$PWD"
tmp="$(mktemp -d)"

setup() {
  # There might be leftovers from previous runs.
  for stub in "${stubs[@]}"; do
    unstub "$stub"  2> /dev/null || true
  done

  pushd "$tmp" > /dev/null
}

teardown() {
  popd > /dev/null
  rm -rf "$tmp"

  for stub in "${stubs[@]}"; do
    unstub "$stub" || true
  done
}

@test 'no arguments' {
  git init
  git config --local user.name test
  git config --local user.email test@example.com

  run "$cwd/git-some"

  assert_success
  assert_line --partial --index 0 '[master (root-commit)'
  assert [ -f file-??.txt ]
}

@test 'number of commits' {
  git init
  git config --local user.name test
  git config --local user.email test@example.com

  run "$cwd/git-some" 2

  assert_success
  assert_line --partial --index 0 '[master (root-commit)'
  assert_line --partial --index 3 '[master '
}

@test 'number of commits > 100' {
  run "$cwd/git-some" 101

  assert_failure 3
  assert_line 'Cannot create 101 file(s). 100 file(s) are permitted and 0 file(s) have already been created. 100 file(s) left.'
}

@test 'number of commits would create more than 100 files' {
  git init
  git config --local user.name test
  git config --local user.email test@example.com
  "$cwd/git-some" 2

  run "$cwd/git-some" 100

  assert_failure 3
  assert_line 'Cannot create 100 file(s). 100 file(s) are permitted and 2 file(s) have already been created. 98 file(s) left.'
}

@test 'number of commits is negative' {
  run "$cwd/git-some" -1

  assert_failure 129
  assert_line "error: unknown switch \`1'"
}

@test 'number of commits is a character' {
  run "$cwd/git-some" a

  assert_failure 1
  assert_line 'Need a positive number for number of commits to generate, got: a'
}

@test 'number of commits is a numeric expression' {
  run "$cwd/git-some" 1+1

  assert_failure 1
  assert_line 'Need a positive number for number of commits to generate, got: 1+1'
}

@test 'number of commits is non-numeric' {
  run "$cwd/git-some" 42a

  assert_failure 1
  assert_line 'Need a positive number for number of commits to generate, got: 42a'
}

@test 'git add fails' {
  git init
  git config --local user.name test
  git config --local user.email test@example.com

  stub git \
       "rev-parse : echo set -- --" \
       'add : exit 1'

  run "$cwd/git-some"

  assert_failure 2

  # There should be no leftovers.
  refute [ -f file-*.txt ]
}

@test 'git commit fails' {
  git init
  git config --local user.name test
  git config --local user.email test@example.com

  # Need to reimplement with system git here, because the git stub cannot
  # delegate to it.
  git="$(which git)"

  stub git \
       "rev-parse : echo set -- --" \
       "add : '$git' add ." \
       'commit : exit 1' \
       "rm : '$git' rm --force -- file-*.txt"

  run "$cwd/git-some"

  assert_failure 4

  # There should be no leftovers.
  refute [ -f file-*.txt ]
}

@test 'default commit message prefix' {
  git init
  git config --local user.name test
  git config --local user.email test@example.com
  "$cwd/git-some" 2

  run git log --oneline --format=%s

  assert_success
  assert_line --partial 'commit message for file-'
}

@test 'custom commit message prefix' {
  git init
  git config --local user.name test
  git config --local user.email test@example.com
  "$cwd/git-some" --message 'some prefix' 2

  run git log --oneline --format=%s

  assert_success
  assert_line --partial 'some prefix file-'
}
