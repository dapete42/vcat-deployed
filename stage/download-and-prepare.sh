#!/bin/bash

setenv -e

cd "$( dirname $0)"

tomcat_major=8
tomcat_version=8.5.46

tomcat_zip=apache-tomcat-$tomcat_version.zip

wget "https://www-us.apache.org/dist/tomcat/tomcat-$tomcat_major/v$tomcat_version/bin/$tomcat_zip" -c

rm -rf work
unzip apache-tomcat-$tomcat_version.zip -d work -x "apache-tomcat-$tomcat_version/webapps/*"

workdir=work/apache-tomcat-$tomcat_version

cp -p setenv.sh $workdir/bin/
cp -p server.xml $workdir/conf/
rm -rf $workdir/webapps/*
mkdir -p $workdir/webapps/vcat
#unzip vcat.war -d $workdir/webapps/vcat
cp -p vcat.war $workdir/webapps/
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

