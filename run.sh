#!/bin/bash

# Author: Michael Ambrus (ambrmi09@gmail.com)
# 2013-01-09

if [ -z $RUN_SH ]; then

RUN_SH="run.sh"
SCREEN_SESSION_NAME="xpra-${USER}"

function run() {
	source .xpra..func.sh
	start_screen

	XPRA_SESSIONS=$(
		xpra list | \
			egrep ':[[:digit:]]+$' | \
			sed -e 's/.*[[:space:]]//'
	)
	USE_XPRA_DISPLAY=$(echo ${XPRA_SESSIONS} | sed -e 's/.*://' | sort)

	XPRA_DISPLAY=${XPRA_DISPLAY-"${USE_XPRA_DISPLAY}"}
	[[ XPRA_DISPLAY++ ]]

	xpra start \
		--exit-with-children \
		--start-child="$@" \
		--session-name="$@" \
		${XPRA_DISPLAY} \

	if [ "X${START_HIDDEN}" != "Xyes"]; then
		screen \
			-S ${SCREEN_SESSION_NAME} \
			-p0 \
			-X stuff "xpra attach ${XPRA_DISPLAY} &"`echo -ne '\015'`
	fi
}

source s3.ebasename.sh
if [ "$RUN_SH" == $( ebasename $0 ) ]; then
	#Not sourced, do something with this.

	RUN_SH_INFO=${RUN_SH}
	source .xpra.ui..run.sh

	run "$@"
	RC=$?

	exit $RC
fi

fi
