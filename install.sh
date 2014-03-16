#!/bin/bash

# Fail script if something goes wrong.
set -o errexit

pushd `dirname $0` > /dev/null
BIN_DIR=`pwd`
popd > /dev/null

git config --global alias.some "!sh -c \"$BIN_DIR/git-some.sh\""
echo 'git-some successfully installed.'
echo 'You can now use "git some".'
