# test tomcat instance creation. Suggest testing with --noop to prevent 
# having to install the tomcat packages first

user { "tomcat": 
  ensure => present,
  gid    => "tomcat",
}

group { "tomcat":
  ensure => present,
}

class { "tomcat": }

# Create a tomcat instance
tomcat::instance { "myapp_dev":
  instance_user => "tomcat",
  https_port    => 8080,
  http_port     => 8081,
  jmx_port      => 8088,
  shutdown_port => 8089,
  watch_tomcat  => false,
  watch_java    => false,
}

# Create another tomcat instance
tomcat::instance { "myotherapp_prod":
  instance_user => "tomcat",
  https_port    => 8090,
  http_port     => 8091,
  jmx_port      => 8098,
  shutdown_port => 8099,
  watch_tomcat  => false,
  watch_java    => false,
}

# disabled tomcat instance
tomcat::instance { "mydisabledapp_dev":
  service_ensure => false,
  service_enable => false,
  instance_user  => "tomcat",
  https_port     => 8100,
  http_port      => 8101,
  jmx_port       => 8108,
  shutdown_port  => 8109,
  watch_tomcat  => false,
  watch_java    => false,
}

