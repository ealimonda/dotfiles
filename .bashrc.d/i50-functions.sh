#*******************************************************************************************************************
#* Config files                                                                                                    *
#*******************************************************************************************************************
#* File:             50-functions.sh                                                                               *
#* Copyright:        (c) 2011-2012 alimonda.com; Emanuele Alimonda                                                 *
#*                   Public Domain                                                                                 *
#*******************************************************************************************************************

# Check for Mac OS X (it actually also catches Darwin, but I don't use that anyways)
UNAME="$(uname)"
if [ "$UNAME" == "Darwin" ]; then
	# Load mactrash if available
	[[ -f ~/.mactrash ]] && . ~/.mactrash

	# Italian alias for 'say'
	function dimmi {
		say -v Silvia $@
	}

	# Rebuild LaunchServices Database
	function lsrebuild {
		echo "Rebuilding LaunchServices Database"
		/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -kill -r -domain local -domain system -domain user
	}

	# Kill thumbnails cache
	function thumbcacherebuild {
		if [ "$TERM_PROGRAM" == "DTerm" ]; then
			echo "No, please don't.  You need a tty."
		else
			qlmanage -r cache
			sudo find /private/var/folders -name "thumbnails.data" -delete
			echo "Please restart (at least Finder.)"
		fi
	}

	# Terminate all wineskin child processes, in case of runaways
	function grimreapws {
		killall wine
		killall quartz-wm
		rm -rf /private/tmp/Wineskin
		rm -rf /private/tmp/.wine-*
	}
fi

# crc32 calculation, in case the OS doesn't offer that
if ! type crc32 >/dev/null 2>&1; then
	if [ "$UNAME" == "Darwin" ]; then
		function crc32 { cksum -o3 "$@" | ruby -e 'STDIN.each{|a|a=a.split;printf "%08X\t%s\n",a[0],a[2..-1].join(" ")}'; }
	else
		function crc32 { crc32sum.py -s "$@"; }
	fi
fi

# tree
if ! type tree >/dev/null 2>&1; then
	function tree {
		if [ -z "$1" ]; then
			TREEDIR="."
		else
			TREEDIR="$1"
		fi
		find "$TREEDIR" -print | sed -e 's;[^/]*/;|___ ;g;s;___ |; |;g'
	}
fi

# treedir
if ! type treedir >/dev/null 2>&1; then
	function treedir {
		if [ -z "$1" ]; then
			TREEDIR="."
		else
			TREEDIR="$1"
		fi
		#ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'
		pwd
		ls -R "$TREEDIR" | grep ":$" | \
			sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/ /' -e 's/-/|/'
		# 1st sed: remove colons
		# 2nd sed: replace higher level folder names with dashes
		# 3rd sed: indent graph three spaces
		# 4th sed: replace first dash with a vertical bar
		if [ `ls -F -1 | grep "/" | wc -l` = 0 ]; then
			# check if no folders
			echo " -> no sub-directories"
		fi
		echo
		return
	}
fi

if ! type truncate >/dev/null 2>&1; then
	function truncate {
		if [ -f "$1" ]; then
			dd if=/dev/null of="$1" >/dev/null 2>&1 || return 1
			return
		fi
		echo "File not found"
		return 1
	}
fi

# rsync over ssh with restore options.  And caffeinated in case we're on a Mac we don't want to sleep dorung the process
function safersync {
	if [ -z "$1" -o -z "$2" ]; then
		echo "Usage: safersync <source> <destination>"
		return 1
	fi
	if ! type caffeinate >/dev/null 2>&1; then
		rsync -avzP --progress -e ssh "$1" "$2"
	else
		caffeinate -s rsync -avzP --progress -e ssh "$1" "$2"
	fi
}

# Growl notification from iTerm
function growl {
	echo -e $'\e]9;'"${1}"'\007'
	return
}
# vim: ts=4 sw=4
