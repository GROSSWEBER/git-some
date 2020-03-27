# git-some

[![Build Status](https://travis-ci.org/GROSSWEBER/git-some.svg?branch=master)](https://travis-ci.org/GROSSWEBER/git-some)

A little helper script to quickly generate git commits.

## Usage

`git some [number of commits]` will generate `number of commits` commits in the
current directory.

Every commit creates one file named `file-x.txt`, where `x` is a string
representing the current commit number, from `A` to `Z` and `AA` to `ZZ`, etc.

If you omit `number of commits`, `git some` will default to generate one commit.
`git some` will not overwrite exiting files, but rather try to generate files
that do not exist yet.

## Installation

Somewhere on your machine (preferably your home directory), execute the
following commands:

```sh
$ git clone https://github.com/GROSSWEBER/git-some.git
$ cd git-some
$ ./install
```

`install` will set up the `git some` alias for you.
