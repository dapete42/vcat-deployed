vcat-deployed
=============

Under construction. This contains the vCat installation as deployed on Tool
Labs.

Configuration
-------------

The configuration file `work/vcat.properties` is not included in the
repository, because it contains information that can not be made public, namely
`redis.secret`, the secret prefix used with Redis keys etc. It can be
randomly chosen, e.g. with `openssl rand -base64 32`.

The repository does however contain `work/vcat.properties.example` which
contains all the other settings and can be used as a template.

The login information for MariaDB database access is automatically read from
`~/replica.my.cnf`, which is automatically created for all projects on Tool
Labs.

JAR for vcat-toollabs
---------------------

For licensing reasons, the repository does not contain the required file
`work/jar/vcat-toollabs.jar`, which can be built using the *vcat-toollabs*
Eclipse project/Maven artifact. You need the file created under the name
`target/vcat-toollabs-VERSION-with-depencencies.jar` (where `VERSION` is
the artifact version number). This is available in a GitHub repository at
https://github.com/dapete42/vcat

Required packages
-----------------

The following packages have been installed on Tool Labs for vCat to work
properly. This list may not be a complete list of depencencies - packages may
have been installed before vCat existed. Descriptions are taken from the
Ubuntu packages.

* `graphviz` - rich set of graph drawing tools
