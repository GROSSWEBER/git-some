#!/usr/bin/env bash
#
# Generates git commits using randomly-named files, one file per commit.
#
# USAGE: git-some.sh <number of commits to generate>

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
  # instead of finding a file between 0 and 99 
  # we can also use mktemp to generate a uniq filename
  # this should be much faster and it will also works for more
  # than 100 files
  
  # Create file in current directory with 8 random characters
  filename=$(mktemp -p . git-some.XXXXXXXX)
  
  # fill the file with some content
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
