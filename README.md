vcat-deployed
=============

Under construction. This contains the vCat installation as deployed on
Wikimedia Toolforge.

WAR for vcat-toolforge-webapp
----------------------------

For licensing reasons, the repository does not contain the required file
`public_tomcat/webapp/vcat.war`, which can be built using the
*vcat-toolforge-webapp* Maven artifact. You need the file created under the
name `target/webapp.war`. This is available in a GitHub repository at
https://github.com/dapete42/vcat

Required packages
-----------------

The following packages have been installed on Tool Labs for vCat to work
properly. This list may not be a complete list of depencencies - packages may
have been installed before vCat existed. Descriptions are taken from the
Ubuntu packages.

* `graphviz` - rich set of graph drawing tools
