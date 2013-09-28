#!/bin/sh

jstart -stderr -mem 2g -o /data/project/vcat/vcat-toollabs-daemon.log -j y -N vcat-toollabs-daemon java -Xms256m -Xmx256m -jar $HOME/work/jar/vcat-toollabs.jar $HOME/work/vcat.properties
