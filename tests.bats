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
  assert [ -f A.txt ]
}

@test 'number of commits' {
  git init
  git config --local user.name test
  git config --local user.email test@example.com

  run "$cwd/git-some" 2

  assert_success
  assert_line --partial --index 0 '[master (root-commit)'
  assert_line --partial --index 3 '[master '
  assert [ -f A.txt ]
  assert [ -f B.txt ]
}

@test 'number of commits is larger than can be represented by a single character' {
  git init
  git config --local user.name test
  git config --local user.email test@example.com

  run "$cwd/git-some" $((26 + 1))

  assert_success
  assert [ -f AA.txt ]
}

@test 'number of commits is much larger than can be represented by a single character' {
  git init
  git config --local user.name test
  git config --local user.email test@example.com

  run "$cwd/git-some" 100

  assert_success
  assert [ -f CV.txt ]
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

@test 'file to generate already exists' {
  git init
  git config --local user.name test
  git config --local user.email test@example.com

  touch A.txt

  run "$cwd/git-some"

  assert_failure 1
  assert_line 'A.txt already exists but it should not.'
}

@test 'git add fails' {
  git init
  git config --local user.name test
  git config --local user.email test@example.com

  stub git \
       "rev-parse : echo set -- --" \
       "symbolic-ref : echo master" \
       "rev-list : echo 0" \
       'add : exit 1'

  run "$cwd/git-some"

  assert_failure 2

  # There should be no leftovers.
  refute [ -f *.txt ]
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
       "symbolic-ref : echo master" \
       "rev-list : echo 0" \
       "add : '$git' add ." \
       'commit : exit 1' \
       "rm : '$git' rm --force -- *.txt"

  run "$cwd/git-some"

  assert_failure 4

  # There should be no leftovers.
  refute [ -f *.txt ]
}

@test 'default commit message prefix on master' {
  git init
  git config --local user.name test
  git config --local user.email test@example.com
  "$cwd/git-some"

  run git log --oneline --format=%s

  assert_success
  assert_line --partial 'master: '
}

@test 'default commit message prefix on topic' {
  git init
  git config --local user.name test
  git config --local user.email test@example.com
  git checkout -b topic
  "$cwd/git-some"

  run git log --oneline --format=%s

  assert_success
  assert_line --partial 'topic: '
}

@test 'default commit message prefix in detached HEAD state' {
  git init
  git config --local user.name test
  git config --local user.email test@example.com
  "$cwd/git-some"
  git checkout --detach
  "$cwd/git-some"

  run git log --oneline --format=%s

  assert_success
  assert_line --partial 'detached HEAD: '
}

@test 'custom commit message prefix' {
  git init
  git config --local user.name test
  git config --local user.email test@example.com
  "$cwd/git-some" --message 'some prefix' 2

  run git log --oneline --format=%s

  assert_success
  assert_line --partial 'some prefix: '
}
