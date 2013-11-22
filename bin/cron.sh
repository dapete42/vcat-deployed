#!/bin/bash

$HOME/bin/vcat-control-ping
NOT_LISTENING="$?"

if [ $NOT_LISTENING -eq 1 ]; then
	$HOME/bin/restart-job >/dev/null 2>&1
else
	$HOME/bin/start-job >/dev/null 2>&1
fi
