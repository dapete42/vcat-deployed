#!/bin/sh

java -Djavamelody.storage-directory=$HOME/javamelody -Xmx256M -jar "$HOME/vcat-toolforge-runner.jar"
