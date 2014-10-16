# == Class: tomcat
#
# Full description of class tomcat here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { tomcat:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2014 Your name here, unless otherwise noted.
#
define tomcat::install( $ensure = present,
                        $symlink_source = $::tomcat::params::catalina_home,
                        $symlink_target = false,) {
  include ::tomcat::params

  if ! defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat defined resources')
  }
  

  # if user has supplied a valid target to symlink to, then make this the 
  # default tomcat installation by creating a symlink
  if ($symlink_target) {
    validate_absolute_path($symlink_target)
    validate_absolute_path($symlink_source)

    file { $symlink_source:
      target => $symlink_target,
    }
  }

  $package = $title

  package { $package:
    ensure => $ensure,
  }

}
