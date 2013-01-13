# UI part of rg.run.sh
# This is not even a script, stupid and can't exist alone. It is purely
# ment for beeing included.

#some defaults

function print_run_help() {
	#clear
			cat <<EOF
Usage: $RUN_SH_INFO [options] any-x-program

Uses xpra to run a server with *one* attached application and to make it
visible on the current SCREEN.

Options. Defautls within []:
  -H              Start hidden. This is the default xpra behaviour.
  -d <display>    xpra DISPLAY. Defaults to the highest number in use +1.
  -D <display>    Physical X-display. Defaults to \$DISPLAY [$DISPLAY]. I.e.
                  you can preset this by altering the \$DISPLAY environment
                  variable before calling this script if all operations should
                  default so something else.
  -R <remote>     Run application on remote host and (normally) attach to this.

Example:
  $RUN_SH_INFO firefox

EOF
}

	ORIG_ARGS="$@"

	while getopts hHD:R: OPTION; do
		case $OPTION in
		h)
			print_run_help $0
			exit 0
			;;
		H)
			START_HIDDEN='yes'
			;;
		d)
			XPRA_DISPLAY=$OPTARG
			;;
		D)
			DISPLAY=$OPTARG
			;;
		R)
			RHOST=$OPTARG
			REMOTE_ARGS=${ORIG_ARGS/-R/}
			REMOTE_ARGS=${REMOTE_ARGS/$RHOST/}
			REMOTE_ARGS="-H ${REMOTE_ARGS}"
			;;
		?)
			echo "Syntax error:" 1>&2
			print_run_help $0 1>&2
			exit 2
			;;

		esac
	done
	shift $(($OPTIND - 1))

	if [ $# -eq 0 ]; then
		echo "Syntax error: $RUN_SH_INFO expects a X-program to run" 1>&2
		print_run_help $0 1>&2
		exit 2
	fi

	START_HIDDEN=${START_HIDDEN-"no"}
	DISPLAY=${DISPLAY-":0"}
	RHOST=${RHOST-""}
	
	#echo "${REMOTE_ARGS}"
	#exit 0

