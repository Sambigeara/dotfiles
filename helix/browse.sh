#!/bin/sh
# Open current file on GitHub/GitLab (nvim <leader>go / GBrowse).
# $1 path, $2 location (N or N-M). Current branch; detached HEAD uses the SHA.
set -e
file=$1
loc=$2
dir=$(dirname -- "$file")
git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
	echo "not a git repository"
	exit 1
}
rel=$(git -C "$dir" rev-parse --show-prefix)$(basename -- "$file")

if up=$(git -C "$dir" rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null); then
	remote=${up%%/*}
else
	remote=origin
fi
giturl=$(git -C "$dir" remote get-url "$remote")
branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD)
if [ "$branch" = HEAD ]; then
	ref=$(git -C "$dir" rev-parse HEAD)
else
	ref=$branch
fi

u=${giturl%.git}
case $giturl in
git@*)
	rest=${u#git@}
	host=${rest%%:*}
	base=https://$host/${rest#*:}
	;;
ssh://*)
	rest=${u#ssh://}
	rest=${rest#*@}
	hp=${rest%%/*}
	host=${hp%%:*}
	base=https://$host/${rest#*/}
	;;
http://* | https://*)
	scheme=${u%%://*}
	rest=${u#*://}
	rest=${rest#*@}
	host=${rest%%/*}
	base=$scheme://$rest
	;;
*)
	echo "unrecognised remote: $giturl"
	exit 1
	;;
esac

enc=$(printf '%s' "$ref" | sed 's|/|%2F|g')
case $host in
github.com | github.* | *.github.com | *.github.*)
	mid=blob
	case $loc in
	*-*) frag=L${loc%-*}-L${loc#*-} ;;
	*) frag=L$loc ;;
	esac
	;;
*)
	mid=-/blob
	case $loc in
	*-*) frag=L${loc%-*}-${loc#*-} ;;
	*) frag=L$loc ;;
	esac
	;;
esac
url=$base/$mid/$enc/$rel#$frag

open "$url"
echo "$url"
