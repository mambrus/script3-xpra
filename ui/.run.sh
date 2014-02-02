# UI part of rg.run.sh
# This is not even a script, stupid and can't exist alone. It is purely
# meant for being included.

#some defaults

function print_run_help() {
	cat <<EOF
Usage: $(basename $0) [options] any-x-program

Uses xpra to run a server with *one* attached application and to make it
visible on the current display (or display of your choice).

Options. Defautls within "[]":
  -R <remote>     Run application on remote host and (normally) attach to this.
  -t              Trust prerequisits. I.e. don't check. This makes start on
                  remote hosts faster. Default is to check.
  -H              Start hidden. This is the default xpra behaviour but
                  $(basename $0) defaults to the opposite i.e. visible.
  -d <display>    xpra DISPLAY. Defaults to the highest number in use +1.
  -D <display>    Physical X-display. Defaults to \$DISPLAY [$DISPLAY]. I.e.
                  you can preset this by altering the \$DISPLAY environment
                  variable before calling this script if all operations should
				  default so something else. This is useful mainly if host
                  displayinig sessions have more than one physical displays.

Example:
  #Start a xprad firefox on localhost
  $RUN_SH_INFO firefox

  #Start firefox on remote host as xprad session
  $RUN_SH_INFO -R firefox

EOF
}

	ORIG_ARGS="$@"

	while getopts hHD:R:td: OPTION; do
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
		t)
			TRUST_PREREQ='yes'
			;;
		R)
			RHOST=$OPTARG
			REMOTE_ARGS=${ORIG_ARGS/-R/}
			REMOTE_ARGS=${REMOTE_ARGS/$RHOST/}
			REMOTE_ARGS="-Ht ${REMOTE_ARGS}"
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
	TRUST_PREREQ=${TRUST_PREREQ-"no"}
	DISPLAY=${DISPLAY-":0"}
	RHOST=${RHOST-""}

	#echo "${REMOTE_ARGS}"
	echo "${TRUST_PREREQ}"
	#exit 0

