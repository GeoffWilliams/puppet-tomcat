# tests side-by-side and rpm file download package installation and package
# removal.  suggest run test with --noop otherwise all referenced file must
# really exist

# side-by-side install of tomcat from yum repo (RPM must be packaged to 
# allow this - eg version number built into package name)

class { "tomcat" : }

::tomcat::install { ["myorg-apache-tomcat-7.0.55", "myorg-apache-tomcat-7.0.56"]: }

# remove a specific version of tomcat
::tomcat::install { "myorg-apache-tomcat-7.0.54":
  ensure => absent,
}

# install an RPM directly
::tomcat::install { "myorg-apache-tomcat-7.0.56-1-1.x86_64.rpm":
  download_site => "http://172.16.1.101",
}
