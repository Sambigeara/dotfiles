#!/bin/sh
# Dump git diff vs index for Helix <space>G. $1 path.
# Named .diff so Helix's shipped tree-sitter-diff grammar highlights it.
set -e
file=$1
dir=$(dirname -- "$file")
base=$(basename -- "$file")
f=$(mktemp /tmp/helix-diff.XXXXXX)
git -C "$dir" --no-pager diff --no-ext-diff -- "$base" >"$f" 2>&1
mv "$f" "$f.diff"
echo "$f.diff"
