# == Define: tomcat::install
#
# Installs the tomcat RPM and optionally symlinks it to a default location
#
# === Parameters
# [*namevar*]
#   Name of tomcat package to install (with yum)
#
# [*ensure*]
#   `present` to install this version of tomcat, `absent` to remove.
#
# [*$symlink_source*]
#   If creating a symlink to this installation (`$symlink_target` set), create
#   the symlink at this location.
#
# [*symlink_target*]
#   If set, attempt to create a symlink at `$symlink_source` pointing to the
#   file specified here.
#
# [*file_owner*]
#   Owner of the symlink (if created)
#
# [*file_group*]
#   Group of the symlink (if created)
#
# === Examples
#
# see README.md
#
# === Authors
#
# Geoff Williams <geoff.williams@puppetlabs.com>
#
# === Copyright
#
# Copyright 2014 Puppet Labs, unless otherwise noted.
#
define tomcat::install( $ensure = present,
                        $symlink_source = $::tomcat::params::catalina_home,
                        $symlink_target = false,
                        $file_owner = $::tomcat::params::file_owner,
                        $file_group = $::tomcat::params::file_group,) {
  include ::tomcat::params

  if (!($::osfamily in $::tomcat::params::supported_os)) {
    fail($::tomcat::params::unsupported_os_msg)
  }

  if ! defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat defined resources')
  }

  File {
    owner => $file_owner,
    group => $file_group,
  }
  

  # if user has supplied a valid target to symlink to, then make this the 
  # default tomcat installation by creating a symlink
  if ($symlink_target) {
    validate_absolute_path($symlink_target)
    validate_absolute_path($symlink_source)

    file { $symlink_source:
      ensure => link,
      target => $symlink_target,
    }
  }

  $package = $title

  package { $package:
    ensure => $ensure,
  }

}
