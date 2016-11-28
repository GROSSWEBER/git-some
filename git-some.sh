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

# Limit to 100 files (file-00.txt to file-99.txt).
commit_limit=100
max_index=$(($commit_limit - 1))
placeholder_length=${#max_index}

if grep --quiet --invert-match '^[[:digit:]]*$' <<< $commit_count; then
  >&2 echo Need a positive number for number of commits to generate, got: $commit_count
  exit 1
fi

search_pattern=
for ((i = 1; i <= $placeholder_length; i++)); do
  search_pattern=$search_pattern?;
done
search_pattern=file-$search_pattern.txt

file_count=$(find . -maxdepth 1 -name "$search_pattern" | wc -l)
if [[ $(($file_count + $commit_count)) -gt $commit_limit ]]; then
  >&2 echo Cannot create $commit_count file\(s\). $commit_limit file\(s\) are permitted and $file_count file\(s\) have already been created. $(($commit_limit - $file_count)) file\(s\) left.
  exit 3
fi

for ((commit = 1; commit <= $commit_count; commit++)); do
  # Try to find an untaken file between 0 and ($commit_limit -1).
  while true; do
    up_to_limit=$(($RANDOM % $commit_limit))
    filename=$(printf "file-%0${placeholder_length}d.txt" $up_to_limit)

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
  if ! git commit --message "commit message for $filename"; then
    git rm --force "$filename" > /dev/null
    exit 4
  fi

  echo
done
