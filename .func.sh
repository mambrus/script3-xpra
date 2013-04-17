#! /bin/bash

#Common helper functions for the xpra.* scripts

S3XPRA_DIR=~/.s3xpra

if [ ! -d "${S3XPRA_DIR}" ]; then
	mkdir -p "${S3XPRA_DIR}"
fi
if [ ! -f "${S3XPRA_DIR}/remotes" ]; then
	touch "${S3XPRA_DIR}/remotes"
fi

#Starts a new screen session in daemonized mode if needed
function start_screen() {
	#One screen session per user is quite enough (unless this is scripted which
	#it shouldn't be

	SCREEN_SESSION_NAME=${SCREEN_SESSION_NAME-"xpra-${USER}"}
	#echo ${SCREEN_SESSION_NAME}
	#exit 0

	CURR_SCREEN_SESSION_NAME=$(
		screen -ls | \
		grep "^[[:space:]][[:digit:]]\+\.${SCREEN_SESSION_NAME}[[:space:]]"
	)
	#echo "This is the current screen name: ${CURR_SCREEN_SESSION_NAME}"
	#exit 0
	if [ "X$(echo ${CURR_SCREEN_SESSION_NAME} | \
			grep ${SCREEN_SESSION_NAME} | wc -l)" == "X0" ]; then
		echo " Start a new daemonized screen"
		#Start a new daemonized screen
		screen -dmS ${SCREEN_SESSION_NAME}
	elif [ "X$(echo ${CURR_SCREEN_SESSION_NAME} | \
			grep ${SCREEN_SESSION_NAME} | wc -l)" == "X1" ]; then
		echo "Using screen-session " \
			"[`echo ${CURR_SCREEN_SESSION_NAME} | \
				sed -e 's/[[:space:]]/ /g'`]" 1>&2
	else
		echo "Error: More than one valid screen sessions found:" 1>&2
		echo ${CURR_SCREEN_SESSION_NAME} 1>&2
	fi
}

# Print current uid in numerical format. Can't use passwd as user might be a
# network (i.e for example NIS or ldap) user.
# Uses the fatct that ps will always contain at least one process for the user
# in question: ps itself
function uid {
	ps -lu $(echo $USER) | tail -n1 | awk '{print $3}'
}

# Prints a list of all current relevant session for the EUID askin. Presented
# unsorted as the order seems to be related to time of creation.
function xpra_list_sessions {
	xpra list | \
		egrep ':[[:digit:]]+$' | \
		sed -e 's/.*[[:space:]]//'
}


# Prints a list of the parameters for the xpra session asked for.
# $1     = <xpra session id>
# $2..$n = Space separated list of parameters to print. NOTE: Output order is
# the same as parameter order.
function xpra_info_session {
	local XPRA_SESSION="${1}"
	local XPRA_HDR=$(xpra list | grep "[[:space:]]${XPRA_SESSION}" | sed -e 's/^[[:space:]]\+//')

	echo -n "${HOSTNAME};"
	echo -n "${XPRA_SESSION};"
	echo -n "${XPRA_HDR};"
	shift
    xpra info "${XPRA_SESSION}" | util.param.sh -F";" "${@}"
}
