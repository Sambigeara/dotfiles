#!/bin/sh
# Compile the vendored parser into Helix's config runtime (searched first).
set -e
src="$(cd "$(dirname "$0")" && pwd)/src"
out="$(cd "$(dirname "$0")/../../runtime/grammars" && pwd)"
mkdir -p "$out"
cc -shared -fPIC -fno-exceptions -I "$src" -o "$out/git_blame.dylib" -xc -std=c11 "$src/parser.c"
