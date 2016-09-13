#!/usr/bin/env bash
#
# Generates git commits using randomly-named files, one file per commit.
#
# USAGE: git-some.sh <number of commits to generate>

# MY IMPORTANT FIX

# Fail script if something goes wrong.
set -o errexit

# Treat unset variables as an error, and immediately exit.
set -o nounset

# Default to 1 commit unless specified otherwise.
commit_count=${1-1}

if grep --quiet --invert-match '^[[:digit:]]*$' <<< $commit_count; then
  >&2 echo Need a positive number for number of commits to generate, got: $commit_count
  exit 1
fi

for ((commit = 1; commit <= $commit_count; commit++)); do
  # Try to find an untaken file between 0 and 99.
  while true; do
    up_to_100=$(($RANDOM % 100))
    filename=$(printf file-%02d.txt $up_to_100)

    [[ -f "$filename" ]] || break
  done

  # Create file.
  echo contents for $filename > "$filename"

  # Stage file.
  if ! git add -- "$filename"; then
    rm -f "$filename"
    exit 2
  fi

  # Commit
  git commit --message "commit message for $filename"

  echo
done
