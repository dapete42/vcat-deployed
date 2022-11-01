#!/bin/bash

setenv -e

cd "$( dirname $0)"

tomcat_major=9
tomcat_version=9.0.65

tomcat_zip=apache-tomcat-$tomcat_version.zip

wget "https://dlcdn.apache.org/tomcat/tomcat-$tomcat_major/v$tomcat_version/bin/$tomcat_zip" -c

rm -rf work
unzip apache-tomcat-$tomcat_version.zip -d work -x "apache-tomcat-$tomcat_version/webapps/*"

workdir=work/apache-tomcat-$tomcat_version

cp -p setenv.sh $workdir/bin/
cp -p server.xml $workdir/conf/
mkdir -p $workdir/webapps
cp -p vcat.war $workdir/webapps/ROOT.war
chmod +x $workdir/bin/*.sh

rsync -av --delete $workdir/ $HOME/tomcat-$tomcat_version/

for zip in apache-tomcat-*.zip
do
	if [ "$zip" != "apache-tomcat-$tomcat_version.zip" ]
	then
		rm "$zip"
	fi
done
rm -rf work
