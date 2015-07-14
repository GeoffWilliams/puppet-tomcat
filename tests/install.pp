# tests side-by-side and rpm file download package installation and package
# removal.  suggest run test with --noop otherwise all referenced file must
# really exist

# side-by-side install of tomcat from yum repo (RPM must be packaged to 
# allow this - eg version number built into package name)

class { "tomcat" : }


# install multiple tomcat packages using system package manager
::tomcat::install { ["myorg-apache-tomcat-7.0.55", "myorg-apache-tomcat-7.0.56"]: }

# remove a specific version of tomcat
::tomcat::install { "myorg-apache-tomcat-7.0.54":
  ensure => absent,
}

# install an RPM by attempting direct download.  This allows installation
# of vendored RPMs for organisations without a working yum repository
::tomcat::install { "tomcat7-7.0.37-4.el6.noarch.rpm":
  download_site => "ftp://ftp.pbone.net/mirror/ftp5.gwdg.de/pub/opensuse/repositories/home:/felfert:/CentOS-Utils/CentOS_CentOS-6/noarch",
}

