# == Define: tomcat::port
#
# Dummy class used to enforce the rule of not being able to allocate the same
# port more then once on a node
# === Parameters
#
# [*namevar*]
#   Port number to assign.  Since this is a title/namevar it MUST be a string!
#   We parse a number out of it as part of our own validation routines
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
define tomcat::port() {
  include ::tomcat::params

  if (!($::osfamily in $::tomcat::params::supported_os)) {
    fail($::tomcat::params::unsupported_os_msg)
  }

  if (! is_numeric($name)) {
    fail("Attempt to allocate invalid port to tomcat.  No integer could be parsed from: ${name}")
  }

  if ($name == "0") {
    $port_number = 0
  } else {
    $port_number = scanf($name, "%i")[0]
  }
  if (($port_number < 1) or ($port_number > 65535)) {
    fail("Attempt to allocate invalid port to tomcat.  Port out of range: ${port_number}")
  }
}
