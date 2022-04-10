#!/usr/bin/env bash
set -eu -o pipefail

inotifywait -m -e close_write,moved_to,create /etc/cups | 
while read -r directory events filename; do
	if [[ "$filename" = "$(basename "$1")" ]]; then
    echo "Change detected. Copy $1 to $2"
		cp "$1" "$2"
	fi
done
