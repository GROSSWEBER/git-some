#! /bin/bash
#
# Generates git commits using randomly-named files, one file per commit.
#
# USAGE: git-some.sh <number of commits to generate>

# Fail script if something goes wrong.
set -o errexit

# Treat unset variables as an error, and immediately exit.
set -o nounset

# Disable filename expansion.
set -o noglob

# Make pipelines fail or succeed as a whole.
set -o pipefail

# Default to 1 commit unless specified otherwise.
commit_count=${1-1}

for ((commit = 1; commit <= $commit_count; commit++))
do
  # Try to find an untaken file between 0 and 99.
  while : ; do
    up_to_100=$(($RANDOM % 100))
    file=$(printf file-%02d.txt $up_to_100)

    [[ -f $file ]] || break
  done

  echo $file > $file
  git add --all
  git commit --message "commit message for $file"

  echo
done
