#!/bin/bash

# Check if Tomcat is running
JOBID=`job tomcat-vcat`

if [ -z "$JOBID" ]; then
        # If job is not running, start it
        webservice -tomcat start >/dev/null 2>&1
fi

