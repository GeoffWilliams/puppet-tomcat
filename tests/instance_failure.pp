class { "tomcat" : }

# fail to create instance due to duplicate ports
tomcat::instance { "myapp":
  http_port     => 8888,
  https_port    => 8888,
  jmx_port      => 8888,
  shutdown_port => 8888,
  watch_tomcat  => false,
  watch_java    => false,
}
