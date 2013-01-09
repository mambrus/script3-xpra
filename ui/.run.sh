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
  -d              xpra DISPLAY. Defaults to the highest number in use +1.
  -D              Physical X-display. Defaults to \$DISPLAY [$DISPLAY]. I.e.
                  you can preset this by altering the \$DISPLAY environment
				  variable before calling this script if all operations should
				  default so something else.

Example:
  $RUN_SH_INFO firefox

EOF
}
	while getopts hHD: OPTION; do
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
		?)
			echo "Syntax error:" 1>&2
			print_run_help $0 1>&2
			exit 2
			;;

		esac
	done
	shift $(($OPTIND - 1))

	START_HIDDEN=${START_HIDDEN-"no"}
	DISPLAY=${DISPLAY-":0"}

