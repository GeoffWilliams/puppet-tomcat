user { "tomcat":
  ensure => present,
  home   => "/var/tomcat",
  gid    => "tomcat",
}

group { "tomcat":
  ensure => present,
}


include ::tomcat
# Download a tarball and install it
::tomcat::install { "apache-tomcat-8.0.24.tar.gz":
  ensure         => present,
  symlink_target => "/usr/local/apache-tomcat-8.0.24",
  download_site  => "http://mirror.ventraip.net.au/apache/tomcat/tomcat-8/v8.0.24/bin",
}
