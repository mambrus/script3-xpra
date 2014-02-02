#!/bin/bash

# Author: Michael Ambrus (ambrmi09@gmail.com)
# 2013-01-09

if [ -z $RUN_SH ]; then

RUN_SH="run.sh"
SCREEN_SESSION_NAME="xpra-${USER}"
XPRA_MIN=20
XPRA_MAX=1000

# Note: The following can be 500 on older UNIX systems. Might need tweaking until
# auto-detecting is complete. TBD
UID_START=1000

# Test if certain binary is installed
#
function test_installed () {
	local BINARY=${1-""}
	local RHOST=${2-""}
	if [ "X${RHOST}" == "X" ]; then
		if [ "X$(ssh ${RHOST} which ${BINARY})" == "X" ]; then
			echo "The executable [${BINARY}] is not installed/or not" \
				"in \$PATH on localhost" 1>&2
			return 1
		fi
	else
		RS=$(expr match "$(ssh ${RHOST} "bash -ic 'which '${BINARY}'' 2>/dev/null" | tail -n1)" ".*\(${BINARY}\)")
		if [ "X${RS}" == "X" ]; then
			echo "The executable [${BINARY}] is not installed/or not" \
				"in \$PATH on host [${RHOST}]" 1>&2
			return 1
		fi
	fi
	return 0
}

function check_prereq() {
	test_installed screen      ${RHOST} && \
	test_installed xpra        ${RHOST} && \
	test_installed xpra.run.sh ${RHOST} && return 0

	echo "Please install it, then try again." 1>&2
	return 1
}

function run() {
	source .xpra..func.sh
	if [ "X${START_HIDDEN}" != "Xyes" ]; then
		start_screen
	fi

	if [ "X${RHOST}" == "X" ]; then
		echo "Staring a local xpra on host [$(hostname)]..." 1>&2

		XPRA_SESSIONS=$(xpra_list_sessions)

		#First session ID to use if none found, start from current uid
		if [ "X${XPRA_SESSIONS}" == "X" ]; then
			(( XPRA_SESSIONS = $(uid) - $UID_START ))
			XPRA_SESSIONS=$(echo "$XPRA_SESSIONS * $XPRA_MAX" | bc)
			(( XPRA_SESSIONS += $XPRA_MIN ))
			(( XPRA_SESSIONS-- ))
		fi

		USE_XPRA_DISPLAY=$(
			echo ${XPRA_SESSIONS} | \
			sed -e 's/[[:space:]]/\n/g' | \
			sed -e 's/.*://' | \
			sort -n | \
			tail -n1
		)

		(( USE_XPRA_DISPLAY++ ))
		USE_XPRA_DISPLAY=":${USE_XPRA_DISPLAY}"

		XPRA_DISPLAY=${XPRA_DISPLAY-"${USE_XPRA_DISPLAY}"}

		# Deduct an application ID for the application. Useful if several
		# instances of the same application is  used and you need an easy way
		# to distinguish between them. Number for the last application will
		# always be the last number used + 1.
		local AID=$(
		local LS=$(xpra_list_sessions)
		for S in $LS; do
			xpra_info_session $S session_name
		done | \
			grep "${1}" | \
			awk -F";" '{print $4}' | \
			sed -e 's/:.*$//' | \
			sort -n | tail -n1
		)
		(( AID++ ))


		SESSION_NAME="$AID:${@}"

		xpra start \
			${XPRA_DISPLAY} \
			--exit-with-children \
			--start-child="$@" \
			--session-name="${SESSION_NAME}" \

		sleep 1
	else
		echo "Staring a remote xpra on [$RHOST] from this host [$(hostname)]..." 1>&2
		# Starting a remote xpra session.

		RLINE=$(grep ${RHOST} ${S3XPRA_DIR}/remotes)
		if [ "X${RLINE}" == "X" ]; then
			echo $RHOST >> ${S3XPRA_DIR}/remotes
		fi
		echo "Starting [xpra.run.sh ${REMOTE_ARGS}] @ [$RHOST]..." 1>&2

		XPRA_DISPLAY=$(
			(ssh $RHOST -- "export PATH=$PATH:~/bin/; xpra.run.sh ${REMOTE_ARGS}" 2>&1) | \
				egrep "\.log$" | sed -e 's/\.log$//' | sed -e 's/.*-//'
		)
		echo "Started on remote host at diplay [$XPRA_DISPLAY]." 1>&2
	fi

	# Note that the screen daemon on local side is handling attaching to
	# xpra.
	if [ "X${START_HIDDEN}" != "Xyes" ]; then

		if [ "X${RHOST}" == "X" ]; then
			screen \
				-S ${SCREEN_SESSION_NAME} \
				-p0 \
				-X stuff "xpra attach ${XPRA_DISPLAY} --title=\"@title@ (${SESSION_NAME}) on @client-machine@\" &"`echo -ne '\015'`
		else
			screen \
				-S ${SCREEN_SESSION_NAME} \
				-p0 \
				-X stuff "xpra attach ssh:${RHOST}:${XPRA_DISPLAY} --title=\"@title@ (${SESSION_NAME}) on @client-machine@\" &"`echo -ne '\015'`
			echo "Session should turn up on your display shortly." 1>&2
		fi
	fi
}

source s3.ebasename.sh
if [ "$RUN_SH" == $( ebasename $0 ) ]; then
	#Not sourced, do something with this.

	RUN_SH_INFO=${RUN_SH}
	echo "Session starting, Please wait..." 1>&2
	source .xpra.ui..run.sh

	if [ "X${TRUST_PREREQ}" != "Xyes" ]; then
		echo "Prerequisites check..." 1>&2
		check_prereq || (
			echo "Prerequisites check failed. Can't continue" 1>&2
			exit 1
		)
		echo "Prerequisites OK" 1>&2
	fi

	run "$@"
	RC=$?

	exit $RC
fi

fi
