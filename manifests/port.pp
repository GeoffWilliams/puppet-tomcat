# == Define: tomcat::port
#
# Dummy class used to enforce the rule of not being able to allocate the same
# port more then once on a node
# === Parameters
#
# [*namevar*]
#   Port number to assign
#
# === Examples
#
# This class is used internally
#
# === Authors
#
# Geoff Williams <geoff.williams@puppetlabs.com>
#
# === Copyright
#
# Copyright 2014 Puppet Labs, unless otherwise noted.
#
define tomcat::port {
  include ::tomcat::params

  if (!($::osfamily in $::tomcat::params::supported_os)) {
    fail($::tomcat::params::unsupported_os_msg)
  }

  $port_number = $title
  if ((! is_numeric($port_number)) or 
      ($port_number < 1) or 
      ($port_number > 65535)) {
    fail("Attempt to allocate invalid port to tomcat: ${port_number}")
  }
}
