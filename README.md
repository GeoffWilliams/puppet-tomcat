# tomcat
[![Build Status](https://travis-ci.org/GeoffWilliams/puppet-tomcat.svg?branch=master)](https://travis-ci.org/GeoffWilliams/puppet-tomcat)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with tomcat](#setup)
    * [What tomcat affects](#what-tomcat-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with tomcat](#beginning-with-tomcat)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

Support for running multiple intances of [apache tomcat](http://tomcat.apache.org/).

Currently supports RedHat boxes and Apache Tomcat 7.x

## Module Description

Module features:
* Multiple Tomcat instances
* Choose the user to run each Tomcat instance as
* Installation/removal of endorsed Java libraries (eg XML parsers)
* Installation/removal of shared Java libraries (eg database drivers)
* JNDI/JDBC support (edit server.xml and context.xml)
* Choose the port(s) tomcat runs on
* HTTPs connector support (won't work out of the box as you must setup 
  keystore and tell tomcat about it)
* Choose your own file permissions
* Supply and use your own templates for server.xml, setenv.sh, etc
* Support controlling auto deployment/unpacking of .war files
* Side-by-side installation of multiple apache-tomcat package (assuming you 
  have access to a correctly packaged version)
* Choose to run a specific Java version for each Tomcat instance
* Choose to run a specific Tomcat version for each Tomcat instance
* Remove specified versions of tomcat from the system
* System init script for each tomcat instance
* Tomcats that don't shut down correctly after 60 seconds will be killed
* Restart Tomcat automatically after altering shared/endorsed libraries, Java
  or Tomcat
* JMX support
* AJP connector support

## Setup

### What tomcat affects

Packages:
* libxml2 for XML configuration file validation
* Tomcat package(s) as instructed by user

Services:
* Installs one service per tomcat instance as instructed by user

Files:
* Tomcat instances under `/var/tomcat` (configurable)
* Shared Java libraries under `/usr/local/lib/tomcat_shared` (configurable)
* Endorsed Java libraries under `/usr/local/lib/tomcat_endorsed` (configurable)
* System init script(s) at `/etc/init.d/tomcat_*`
* Symlink to the default tomcat at `/usr/local/apache-tomcat` (configurable)

### Setup Requirements

You should have access to a yum repository hosting the apache-tomcat packages
you wish to install.  A sample .spec file you can use to build an RPM file is
available [here](https://gist.github.com/GeoffWilliams/4b367b2722d369bbdd4e)

Your system must have Java installed.  Puppet Labs supports a 
[Java module](https://forge.puppetlabs.com/puppetlabs/java) or if you need to 
have side-by-side Java installations from RPMs this 
[alternate (unsupported) Java module](https://forge.puppetlabs.com/geoffwilliams/java)
can install it.

You must create the user(s) to run any required tomcat instances yourself.  By
default, this module expects a user called `tomcat` which you could create like
this:

```
  user { "tomcat":
    ensure => present,
    home   => "/var/tomcat",
    gid    => "tomcat",
  }

  group { "tomcat":
    ensure => present,
  }
```

If wanting to use this module to install shared/endorsed libraries, you must 
put the .jar files somewhere Puppet can download them from.  An HTTP server is
ideal for this purpose.

## Usage

### Minimal

The code snippits below will give you a functional tomcat instance.  Don't 
forget to have the [Setup Requirements](#setup-requirements) in place first

```
  class { "::tomcat":}
```

Setup directories for shared and endorsed libraries, load variables used by
other manifests into memory

```
  ::tomcat::install { "myvendor-apache-tomcat-7.0.56":
    symlink_target => "/usr/local/apache-tomcat-7.0.56",
  }
```

Use yum to install a copy of "myvendor-apache-tomcat-7.0.56" and create a
symlink from `/usr/local/apache-tomcat` to `/usr/local/apache-tomcat-7.0.56`

The file at `/usr/local/apache-tomcat-7.0.56` is created by the installation of
the RPM package.

```
  ::tomcat::instance { "main":
    http_port     => 8080,
    shutdown_port => 8009,
  }
```

Create a tomcat instance called `main` running on port 8080 under the `tomcat`
user.

The above setup will:
* Run as the user `tomcat`
* Be controlled by an init script at `/etc/init.d/tomcat-main`
* Run the Tomcat HTTP connector on port 8080
* Shutdown via port 8009
* Store all instance files under /var/tomcat/main (name taken from resource 
  title) with the sub-directories:
  * bin - shell script(s) to run when starting/stopping the instance
  * conf - configuration files
  * lib - instance wide .class and .jar files to load
  * logs - all logs for this instance will be created here
  * run - contains the PID (process ID) of this tomcat instance
  * temp - temp data
  * webapps - deployment directory (automatic by default)
  * work - tomcat persistent state
* Use the JDK provided at `/usr/java/default`
* Use the apache tomcat installation at `/usr/local/apache-tomcat`

### Multiple instances

You can have as many Tomcat instances as you like running on each node 
simultaneously, you just have to remember to choose different ports to run them
on.  If you mess up the port assignments by allocating the same port more then
once, you will get an error from Puppet that looks like this:

```
  Error: Could not retrieve catalog from remote server: Error 400 on SERVER: Duplicate declaration: Tomcat::Port[8080] is already declared in file /etc/puppetlabs/puppet/modules/tomcat/manifests/instance.pp:310; cannot redeclare at /etc/puppetlabs/puppet/modules/tomcat/manifests/instance.pp:321 on node agent-0.puppetlabs.vm
  Warning: Not using cache on failed catalog
  Error: Could not retrieve catalog; skipping run
```

This protects you from destroying working Tomcat installations by trying to
re-allocate the port.  To resolve this error, simply make sure that each port 
assigned only once per host.

Using multiple instances protects you against the "bad apple" problem of a 
single badly behaved webapp crashing your entire tomcat installation, as often
happens when organisations run huge shared instances of tomcat with lots of 
webapps running.  By isolating each webapp (or group of webapps...) to its own
container, you both limit the risk of complete failure and gain visibility of 
the webapp(s) causing problems - because now they only kill themselves, not 
everything.  See [](http://tomcat.apache.org/tomcat-7.0-doc/RUNNING.txt) for
comprehensive information.

### Running as different users

You can run each tomcat instance as a different user if you want to provide 
better protection and separation of sensitive data.  

```
  ::tomcat::instance { "myapp1":
    http_port     => 8080,
    shutdown_port => 8009,
    instance_user => "myapp1",
  }

  ::tomcat::instance { "myapp2":
    http_port     => 8081,
    shutdown_port => 8010,
    instance_user => "myapp2"
  }
```

In the above example, tomcat will run the first instance as the user `myapp1` 
and the second instance as `myapp2`.  Note that you must create any users and 
groups your instance uses yourself.  See [Setup Requirements](#setup-requirements)
for an example.


Put the classes, types, and resources for customizing, configuring, and doing
the fancy stuff with your module here.

### Library installation/removal

The module supports the installation of shared/endorsed libraries to grant access 
to libraries such as XML parsers (must be put in 'endorsed') and database drivers.  
Libraries are preserved across upgrades and once installed are available to all 
Tomcat intances managed by this module automatically

```
  ::tomcat::library { "postgresql-9.3-1102.jdbc41.jar":
    download_site => "http://172.16.1.101",
  }
```

The above example would attempt to download the postgres database driver from a
web server running at `http://172.16.1.101`.  Once installed, all running tomcat 
instances managed by this module will be restarted so they can use the new library.

Libraries can also be removed by setting the `ensure` parameter to `absent`:

```
  ::tomcat::library { "postgresql-9.3-1102.jdbc41.jar":
    ensure => absent,
  }
```

Tomcat will also be restarted after libraries are removed.

Endorsed libraries are installed/removed in exactly the same way by setting the
parameter `lib_type` to `endorsed`, for example:

```
  ::tomcat::library { "jaxb-impl-2.2.3.jar":
    download_site => "http://172.16.1.101",
    lib_type      => "endorsed",
  }
```

### JNDI/JDBC support

JNDI/JDBC support in tomcat is normally achieved by editing server.xml, 
context.xml and copying a database driver into the lib directory.  You can use
this puppet module to do all of these tasks.

Once a suitable database driver has been installed (see above example), you can
pass fragments of XML to the `::tomcat::instance` resource and it will include
them in it's configuration file.  This gives you the full flexibility of XML to
specify all required database parameters.

Rather then keeping these XML fragments in the puppet manifests, its a good
idea to keep them separate using hiera, which could look something like this for
an Oracle data source:

```
  ---
  tomcat:instance:main:server_xml_jdbc: |
    <Resource name="jdbc/application"
              auth="Container"
              factory="oracle.ucp.jdbc.PoolDataSourceImpl"
              type="oracle.ucp.jdbc.PoolDataSource"
              description="Application"
              connectionFactoryClassName="oracle.jdbc.pool.OracleDataSource"
              minPoolSize="2"
              maxPoolSize="30"
              inactiveConnectionTimeout="20"
              user="tomcat"
              password="t0ps3cr3t :)"
              url="jdbc:oracle:thin:@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=db.bigcorp.com)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=PROD)))"
              connectionPoolName="applicationConnectionPool"
              validateConnectionOnBorrow="true"
              sqlForValidateConnection="select 1 from DUAL" />

  tomcat:instance:main:context_xml_jdbc: |
    <ResourceLink name="jdbc/application"
              global="jdbc/application"
              type="javax.sql.DataSource"/>
```

The manifest (for your tomcat [role...?](http://garylarizza.com/blog/2014/02/17/puppet-workflow-part-2/)) would then lookup pass the XML 
fragments to the tomcat instance and the relevant section will be included in
the `server.xml` and `context.xml` files.

```
  $server_xml_jdbc = hiera("tomcat:instance:main:server_xml_jdbc")
  $context_xml_jdbc = hiera("tomcat:instance:main:context_xml_jdbc")

  ::tomcat::instance { "main":
    http_port        => 8080,
    shutdown_port    => 8009,
    server_xml_jdbc  => $server_xml_jdbc,
    context_xml_jdbc => $context_xml_jdbc,
  }
```

*Don't forget to install the database driver!*

### HTTPs connector support
The HTTPs connector is configured for a `tomcat::instance` by allocating a port
wit the `https_port` parameter and then supplying any additional require XML in
the `https_attributes` parameter.

The user is responsible for setting up any required key stores, etc.  There is
comprehensive documentation in the tomcat [SSL HOW-TO](http://tomcat.apache.org/tomcat-7.0-doc/ssl-howto.html).

It's a good idea to put the required SSL attributes in your node's hiera file
like this:

```
  ---
  # all of the attributes from the SSL-HOWTO *except* the port
  :tomcat:instance:main:ssl_attributes: |
     protocol="HTTP/1.1"
     maxThreads="200"
     scheme="https" secure="true" SSLEnabled="true"
     keystoreFile="${user.home}/.keystore" keystorePass="changeit"
     clientAuth="false" sslProtocol="TLS"
```

So that you have easy access to them in your manifests:

```
  $https_attributes = hiera(":tomcat:instance:main:ssl_attributes:")

  ::tomcat::instance { "main":
    http_port        => 8080,
    shutdown_port    => 8009,
    https_port       => 8081,
    https_attributes => $https_attributes,
  }
```

*If it doesn't work, make sure your keystore is created and readable and that 
you haven't specified the connector port more then once*

### Choose your own file owner/group/permissions
By default, the module creates files and directories with the following owners,
 groups and permissions:

| Item             | Owner           | Group           | Mode                |
|------------------|-----------------|-----------------|---------------------|
| init script      | always root     | `file_group`    | `file_mode_init`    |
| setenv.sh        | `file_owner`    | `file_group`    | `file_mode_script`  |
| instance RO dirs | `file_owner`    | `file_group`    | `file_mode_regular` |
| instance RW dirs | `instance_user` | `instance_user` | `file_mode_regular` |
| regular files    | `file_owner`    | `file_group`    | `file_mode_regular` |

* The init script is always owned by root.  Be careful with the permissions on
  this file - recall that init scripts are run as `root` at boot time
* `setenv.sh` has additional execute permission
* Instance RO dirs contain files that tomcat needs to read but not alter and
  the tomcat process itself shouldn't be able to write to these directories
* Instance RW dirs need to be writable by the owner of the Java process 
  running tomcat for the server to work properly as they contain items such as
  log files and temporary storage
* Regular files are all other files that puppet installs regarding tomcat

_Default values_
The authorative default values of these fields are set in the `params.pp` file 
and are currently:

```
  $file_mode_regular = "0640"
  $file_mode_script  = "0750"
  $file_mode_init    = "0755"
  $file_owner        = "root"
  $file_group        = "tomcat"
  $instance_user     = "tomcat"
```

Don't forget that when the Puppet agent runs, it will "add one" to directories
which have the read bit set, so directories created with a `$file_mode_regular` 
of `0640` will end up with a final mode of `0750` so that you can `cd` into
them.

If you wish to change any of these values from the defaults, refer to the 
following table.  If you need to make changes, be sure to set the parameter
in for all applicable defined resources at the same time to avoid getting an
unpredictable mix of explict and default permissions.

| Parameter           | tomcat | tomcat::install | tomcat::instance | tomcat::library |
|---------------------|--------|-----------------|------------------|-----------------|
| `file_owner`        | YES    | YES             | YES              | YES             |
| `file_group`        | YES    | YES             | YES              | YES             |
| `file_mode_regular` | YES    |                 | YES              | YES             |
| `file_mode_script`  |        |                 | YES              |                 |
| `file_mode_init`    |        |                 | YES              |                 |
| `instance_user`     |        |                 | YES              |                 |

* `file_mode` and `file_group` only change the ownership of the symlink to the
  default tomcat version when used with tomcat::install.  It is up to the RPM
  package to set suitable permissions for the files under `$CATALINA_HOME` when 
  packaging tomcat.

### Choose your own installation directories
By default, the module installs to the following main directories:
* `/var/tomcat` -- instances
* `/usr/local/lib/tomcat_shared` -- shared Java libraries
* `/usr/local/lib/tomcat_endorsed` -- endorsed Java libraries

Its possible to override each of these locations, *however* you must do so
for each of the resource types that manages tomcat on the system.

Say we wanted to install a tomcat on a node at the following locations instead:
* `/home/tomcat` -- instances
* `/home/tomcat/lib` -- shared Java libraries
* `/home/tomcat/endorsed` -- endorsed Java libraries

We could do that like this:

```
  # set the system-wide locations for this node
  class { "::tomcat":
    instance_root_dir => "/home/tomcat",
    shared_lib_dir    => "/home/tomcat/lib",
    endorsed_lib_dir  => "/home/tomcat/endorsed",
  }

  # Install a version of tomcat
  tomcat { "apache-tomcat-7.0.56": }

  # create a tomcat instance using the directories created when the tomcat
  # class was declared
  ::tomcat::instance { "main":
    http_port        => 8080,
    shutdown_port    => 8009,
    shared_lib_dir   => "/home/tomcat/lib",
    endorsed_lib_dir => "/home/tomcat/endorsed",
  }
```

It's also possible to disable system-wide shared/endorsed libraries by setting 
the `shared_lib_dir` or `endorsed_lib_dir` parameter to false on the tomcat 
class declaration and all `::tomcat::instance` resources on the node.  

If you do so, note that you still have access to an individual `/lib` directory
within each tomcat instance.

### Supply and use your own templates for server.xml, setenv.sh, etc

If you find the supplied templates don't meet your needs, you are able to 
substitute any or all of them via the `::tomcat::instance` resource

eg:

```
  ::tomcat::instance { "main":
    http_port                    => 8080,
    shutdown_port                => 8009,
    init_script_template         => "myorg_tomcat/init_script.erb",
    setenv_sh_template           => "myorg_tomcat/setenv.sh.erb,
    server_xml_template          => "myorg_tomcat/server.xml.erb,
    catalina_properties_template => "myorg_tomcat/catalina.properties.erb",
    context_xml_template         => "myorg_tomcat/context.xml.erb",
    logging_properties_template  => "myorg_tomcat/logging.properties.erb",
    tomcat_users_xml_template    => "myorg_tomcat/tomcat-users.xml.erb",
    web_xml_template             => "myorg_tomcat/web.xml.erb"
```

In this imaginary scenario, we have replaced the default templates with our own 
from a module we have made ourselves called `myorg_tomcat`.  Recall that 
templates are expected to be found in a sub-directory of the module called 
`templates`

### Controlling auto deployment/unpacking of .war files

By default, any `.war` files found in the `webapps` directory of an instance
will be unpacked and deployed.  If you don't want this to happen, you can turn
this behavour off:

```
  ::tomcat::instance { "main":
    http_port     => 8080,
    shutdown_port => 8009,
    unpack_wars   => false,
    auto_deploy   => flase,
```

### Side-by-side installation of multiple apache-tomcat packages

You can install as many side-by-side version of apache tomcat on the node as
you like *as long as your packaging allows it!*.

To install multiple tomcat versions, simply specify the tomcat packages to 
install.

eg:

```
  ::tomcat::install { "myorg-apache-tomcat-7.0.55": 
    symlink_target => "/usr/local/apache-tomcat-7.0.55"
  }
  ::tomcat::install { "myorg-apache-tomcat-7.0.56": } 
```
  
In this example, we installed two tomcat versions and set the older version
7.0.55 to be the default by supplying the `symlink_target` parameter.  We have
to tell Puppet where to point the symlink it creates because it doesn't know
what files are in the package

### Choosing a specific Java version

To make a tomcat instance use a specific version of Java, set it's `java_home`
parameter.

eg:

```
  ::tomcat::instance { "main":
    http_port     => 8080,
    shutdown_port => 8009,
    java_home     => "/usr/java/jdk1.7.0_67",
  }
```

Would force this Tomcat instance to run Java from `/usr/java/jdk1.7.0_67`

*Don't forget to install Java at the location specified!*

### Choosing a specific Tomcat version

To make a tomcat instance use a specific version of Apache Tomcat, set it's
`catalina_home` parameter.

eg:

```
  ::tomcat::instance { "main":
    http_port     => 8080,
    shutdown_port => 8009,
    catalina_home => "/usr/local/apache-tomcat-7.0.56",
  }
```

Would force this tomcat instance to run Tomcat from `/usr/local/apache-tomcat-7.0.56`

### Removing specified version(s) of tomcat from the system

To remove old versions of Tomcat from a node, simply set the `ensure` parameter
to `absent` on the `::tomcat::install` resource you want to get rid of.

eg:

```
  ::tomcat::install { "myorg-apache-tomcat-7.0.40": 
    ensure => absent
  }
```

Would remove tomcat 7.0.40 from the system

### JMX support

[JMX](http://tomcat.apache.org/tomcat-7.0-doc/monitoring.html) allows you to
monitor and control your tomcat instance which can be useful if you need to 
debug a problem.  Be aware that some monitoring programs could trigger 
excessive slowdowns depending on what they are doing and also be aware of the 
security implications of granting access.

To enable JMX, set the `jmx_port` parameter to the TCP port you wish to listen
on.

eg:

```
  ::tomcat::instance { "main":
    http_port     => 8080,
    shutdown_port => 8009,
    jmx_port      => 6666,
  }
```

Would start an un-authenticated listener on port 6666.  If you need 
authentication and/or SSL, read the ::tomcat::instance documentation inside
the manifest and look at the `jmx_authenticate`, `jmx_ssl`, `jmx_password_file`
and `jmx_access_file` parameters.

### AJP support

AJP ([`mod_jk`](http://tomcat.apache.org/connectors-doc/reference/apache.html))
can be enabled by setting the `ajp_port` parameter on an instance to be the TCP
port you want to listen on.

eg:

```
  ::tomcat::instance { "main":
    http_port     => 8080,
    shutdown_port => 8009,
    ajp_port      => 8005,
  }
```

Would start an AJP listener on port 8005.

Note that in a lot of cases, it's quicker and easier to skip AJP altogether and
just use the HTTP/1.1 connector.

## Reference

*todo*
Here, list the classes, types, providers, facts, etc contained in your module.
This section should include all of the under-the-hood workings of your module so
people know what the module is touching on their system but don't need to mess
with things. (We are working on automating this section!)

## Limitations

Only supports RedHat OS family and Tomcat 7

## Development

Patches welcome if accompanied by relevant spec test(s)

## Contributors 

Geoff Williams
