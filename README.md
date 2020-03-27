# git-some

[![Build Status](https://travis-ci.org/GROSSWEBER/git-some.svg?branch=master)](https://travis-ci.org/GROSSWEBER/git-some)

A little helper script to quickly generate git commits.

## Usage

`git some [number of commits]` will generate `number of commits` commits in the
current directory.

Every commit creates one file named `<x>.txt`, where `x` is a string
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

## Git training attendees

It is useful to have some aliases ready save some typing:

### git gl

`git gl` displays the whole graph.

```sh
git config --global alias.gl 'log --oneline --graph --all'
```

### git diverged

`git diverged` creates the graph that we mostly use as a base for our
discussion. It looks like [the one below](#Example).

```sh
git config --global alias.diverged '!git init && git some 2 && git checkout -b topic && git some 3 && git checkout - && git some'
```

I'm not using `git switch` here because you might have an older Git client (<
2.23) that only supports `git checkout`.

## Example

```sh
$ mkdir git-some-test

$ cd git-some-test

$ git init
Initialized empty Git repository in <somewhere>/git-some-test/.git/

$ git some 2 && \
  git checkout -b topic && \
  git some 3 && \
  git checkout - && \
  git-some
[master (root-commit) c540e60] master: A.txt
...

$ git log --oneline --graph --all
* 90ace40 (HEAD -> master) master: F.txt
| * 94042dd (topic) topic: E.txt
| * 8eb1751 topic: D.txt
| * 2c4b9f0 topic: C.txt
|/
* 644d9b9 master: B.txt
* c540e60 master: A.txt
```
