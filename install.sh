#!/usr/bin/env bash

script_dir="$(dirname "$(realpath "$0")")"

git config --global alias.some "!'$script_dir/git-some.sh'"
if [[ $? -eq 0 ]]; then
  echo git-some successfully installed from $script_dir.
  echo You can now use:
  echo
  echo '  git some [number of commits]'
else
  >&2 echo git-some installation unsuccessful from $script_dir.
  exit 1
fi
