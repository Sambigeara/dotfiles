#!/bin/sh
# Dump git blame for Helix <space>B. $1 path, $2 cursor line.
# Reprints hash/author/date/lineno in fixed columns so rename paths and
# "Not Committed Yet" cannot shove the source around.
set -e
file=$1
line=$2
dir=$(dirname -- "$file")
base=$(basename -- "$file")
f=$(mktemp /tmp/helix-blame.XXXXXX)
git -C "$dir" blame -- "$base" 2>&1 | awk '
function rtrim(s) { sub(/[ \t]+$/, "", s); return s }
function ltrim(s) { sub(/^[ \t]+/, "", s); return s }
{
	if (!match($0, /[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} [+-][0-9]{4}/)) {
		print
		next
	}
	ts = substr($0, RSTART, RLENGTH)
	left = substr($0, 1, RSTART - 1)
	right = ltrim(substr($0, RSTART + RLENGTH))
	hash = left
	sub(/[ \t].*/, "", hash)
	author = left
	sub(/^[^(]*\(/, "", author)
	author = rtrim(author)
	lineno = right
	sub(/\).*/, "", lineno)
	lineno = rtrim(lineno)
	code = right
	sub(/^[^)]*\) ?/, "", code)
	n++
	h[n] = hash
	a[n] = author
	t[n] = ts
	l[n] = lineno
	c[n] = code
	if (length(hash) > mh) mh = length(hash)
	if (length(author) > ma) ma = length(author)
	if (length(lineno) > ml) ml = length(lineno)
}
END {
	for (i = 1; i <= n; i++)
		printf "%-*s (%-*s %s %*s) %s\n", mh, h[i], ma, a[i], t[i], ml, l[i], c[i]
}
' >"$f"
mv "$f" "$f.git-blame"
echo "$f.git-blame:$line"
