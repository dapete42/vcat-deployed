#!/bin/bash

# Check if SGE job is running
JOBID=`job vcat-toollabs-daemon`

if [ -z "$JOBID" ]; then
	# If job is not running, start it
	$HOME/bin/start-job >/dev/null 2>&1
else
	# If job is running, check if it is still listening
	$HOME/bin/vcat-control-ping
	NOT_LISTENING="$?"
	if [ $NOT_LISTENING -eq 1 ]; then
		# If not listening, restart
		$HOME/bin/restart-job >/dev/null 2>&1
	fi

fi
