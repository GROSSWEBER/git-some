#!/usr/bin/env bash

if [[ "$OSTYPE" == darwin* ]]; then
  script_dir="$(perl -e 'use Cwd "abs_path"; print abs_path(shift)' "$0")"
else
  script_dir="$(realpath "$0")"
fi

if [[ $? != 0 ]]; then
  >&2 echo "Unable to determine current directory"
  exit 1
fi

script_dir="$(dirname "$script_dir")"

git config --global alias.some "!'$script_dir/git-some.sh'"
if [[ $? -eq 0 ]]; then
  echo git-some successfully installed from $script_dir
  echo You can now use:
  echo
  echo '  git some [number of commits]'
else
  >&2 echo git-some installation unsuccessful from $script_dir.
  exit 1
fi
