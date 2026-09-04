#!/bin/sh
# stdin: selected text. $1 path, $2 location (N or N-M). Copies nvim <leader>y format.
path=$1
loc=$2
case $path in
  *.*) ext=${path##*.} ;;
  *) ext= ;;
esac
# $(cat) drops trailing newlines, then we add one so the fence matches nvim.
{
	printf '%s:%s\n```%s\n%s\n```\n' "$path" "$loc" "$ext" "$(cat)"
} | pbcopy
