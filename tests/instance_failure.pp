#
tomcat::instance { "myapp":
  http_port     => 8888,
  https_port    => 8888,
  jmx_port      => 8888,
  shutdown_port => 8888,
}
