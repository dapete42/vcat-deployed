vcat-deployed
=============

Under construction. This will contain the vCat installation as deployed on
Tool Labs.

Configuration
-------------

The configuration file `work/vcat.properties` is not complete in the repository,
because it contains information that can not be made public, namely:

* `jdbc.user` and `jdbc.password`, the login information for MariaDB database
  access. On Tool Labs, this can be found in ~/replica.my.cnf for each project.
* `redis.secret?`, the secret prefix used with Redis keys etc. It can be
  randomly chosen, e.g. with `openssl rand -base64 32`.

JAR for vcat-toollabs
---------------------

For licensing reasons, the repository does not contain the required file
`work/jar/vcat-toollabs.jar`, which can be built using the *vcat-toollabs*
Eclipse project/Maven artifact. You need the file created under the name
`target/vcat-toollabs-VERSION-with-depencencies.jar` (where `VERSION` is
the articact version number). This is available in a GitHub repository at
https://github.com/dapete42/vcat
