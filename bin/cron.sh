#!/bin/bash

# Check if Tomcat is running
JOBID=`job tomcat-vcat`

if [ -z "$JOBID" ]; then
        # If job is not running, start it
        #webservice -tomcat start >/dev/null 2>&1
	qsub -e $HOME/error.log -o /dev/null -i /dev/null -q "webgrid-tomcat" -l h_vmem=4g -b y -N "tomcat-vcat" /usr/local/bin/tool-tomcat >/dev/null 2>&1
fi

