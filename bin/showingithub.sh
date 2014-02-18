#!/bin/bash

function usage() {
	echo "Usage: $0 {<repository directory>|<GitHub username> <GitHub repository>} <sha1>"
	exit 1
}

if [ $# -ge 1 -a $# -le 2 ]; then
	if [ $# -eq 2 ]; then
		REPODIR="$1"
		shift
		if [ ! -d "$REPODIR" ]; then
			usage
		fi
		cd "$REPODIR" || usage
	fi
	BRANCH="$(git branch | grep '^\*' | cut -d' ' -f2)"
	if [ -z "$BRANCH" ]; then
		BRANCH='master'
	fi
	REMOTE="$(git config --get "branch.${BRANCH}.remote")"
	if [ -z "$REMOTE" ]; then
		REMOTE="origin"
	fi
	REMOTEURL="$(git config --get "remote.${REMOTE}.url")"
	REMOTEURL="${REMOTEURL%.git}"
	if [ -z "$REMOTEURL" ]; then
		usage
	fi
	case "$REMOTEURL" in
		http*)
			REPOURL="$REMOTEURL/"
			;;
		*)
			REPOURL="http://github.com/$(echo "$REMOTEURL" | cut -d: -f2)"
			;;
	esac
elif [ $# -eq 3 ]; then
	REPOURL="http://github.com/$1/$2"
	shift 2
else
	usage
fi

SHA1="$1"

if type open >/dev/null 2>&1; then
	open "$REPOURL/commit/$SHA1"
else
	echo "$REPOURL/commit/$SHA1"
fi
