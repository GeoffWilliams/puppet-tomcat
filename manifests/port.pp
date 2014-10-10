# Port is a dummy defined type to ensure that all ports are unique within
# a given catalog
define tomcat::port {
  $port_number = $title
  if ((! is_numeric($port_number)) or 
      ($port_number < 1) or 
      ($port_number > 65535)) {
    fail("Attempt to allocate invalid port to tomcat: ${port_number}")
  }
}
