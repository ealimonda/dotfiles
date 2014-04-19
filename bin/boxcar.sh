#!/bin/bash

# Notify by Boxcar
# http://www.process-one.net

usage() {
	echo -e "\nUsage: $0 -a AccessToken -t MessageTitle -d MessageDetails -s SoundID"
	echo -e "Example: -$0 -a LuckJewacat6 -t \"Some message\" -d \"Message details\" -s 21\n"
	exit 1;

}

while getopts "a:t:d:s:" optionName; do
	case "$optionName" in
		a) token="$OPTARG" ;;
	t) title="$OPTARG" ;;
d) details="$OPTARG" ;;
s) soundid="$OPTARG" ;;
\?) exit 2;;
esac
done

[ -z "$token" ] && [ -f "$HOME/.boxcartoken" ] && token="$( head -n 1 < "$HOME/.boxcartoken" )"

if [ -z "$token" ]; then echo -e "\nMissing AuthToken. See you Boxcar App Settings!"; usage;fi
if [ -z "$title" ]; then echo -e "\nMissing Title. Provide some text to display in push message!"; usage;fi
if [ -z "$details" ]; then echo -e "\nMissing MessageDetails. This is displayed in detail view of Boxcar App"; usage;fi
#if [ -z "$soundid" ]; then echo -e "\nMissing SoundID. This is integer number. Test yourself!"; usage;fi

soundargs=""
[ -n "$soundid" ] && soundargs="--data-urlencode \"notification[sound]=$soundid\" "

curl -d user_credentials=$token \
	--data-urlencode "notification[title]=$title" \
	--data-urlencode "notification[message]=$title" \
	--data-urlencode "notification[long_message]=$details" \
	$soundargs \
	https://new.boxcar.io/api/notifications

echo -e
exit 0
