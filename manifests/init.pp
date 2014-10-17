# == Class: tomcat
# Sets up shared directories (if required) and loads the `tomcat::params` class
# into scope for use by the defined types.
#
# === Parameters
# [*shared_lib_dir*]
#   Directory to _create_ to store shared Java libraries in.  Set to false
#   if you don't want this directory to be created.
#
# [*endorsed_lib_dir*]
#   Directory to _create_ to store endorsed Java libraries in.  Set to false if
#   you don't want this directory to be created.
# 
# [*instance_root_dir*]
#   Directory to _creat_ to hold all of the individual tomcat instances.
#
# [*file_mode_regular*]
#   File mode used to create all files within this manifest (used as a resource
#   default)
#
# [*file_owner*]
#   File owner used to create all files within this manifest (used as a resource
#   default)
#
# [*file_group*]
#   File group used to create all files within this manifest (used as a resource
#   default)
#
# === Examples
#
# See README.me
#
# === Authors
#
# Geoff Williams <geoff.williams@puppetlabs.com>
#
# === Copyright
#
# Copyright 2014 Puppet Labs, unless otherwise noted.
#
class tomcat ($shared_lib_dir = $::tomcat::params::shared_lib_dir,
              $endorsed_lib_dir = $::tomcat::params::endorsed_lib_dir,
              $instance_root_dir = $::tomcat::params::instance_root_dir,
              $file_mode_regular = $::tomcat::params::file_mode_regular,
              $file_owner = $::tomcat::params::file_owner,
              $file_group = $::tomcat::params::file_group,
        ) inherits ::tomcat::params {

  if (! ($::osfamily in $::tomcat::params::supported_os)) {
    fail($::tomcat::params::unsupported_os_msg)
  }


  $endorsed_lib_trigger = "${endorsed_lib_dir}/${::tomcat::params::trigger_file}"
  $shared_lib_trigger = "${shared_lib_dir}/${::tomcat::params::trigger_file}"

  validate_absolute_path($instance_root_dir)

  if ($shared_lib_dir) {
    validate_absolute_path($shared_lib_dir)
  }

  if ($endorsed_lib_dir) {
    validate_absolute_path($endorsed_lib_dir)
  }

  File {
    owner => $file_owner,
    group => $file_group,
    mode  => $file_mode_regular,
  }


  if (! defined(Package["libxml2"])) {
    # install xmllint for validation
    package { "libxml2": 
      ensure => present
    }
  }

  # directory to hold the individual tomcat instances
  file { $instance_root_dir:
    ensure => directory,
  }


  #
  # Trigger files:
  # These files are set ensure=>absent and are "watched" by subscribing to them.
  # If we decided that some action needs to be taken, we have an exec {} touch
  # the trigger file BEFORE the trigger file is processed by puppet, this causes 
  # puppet to remove the file and notify the subscribers.
  #
  # this technique is used to restart all tomcat instances on a node if a 
  # shared or endorsed is altered
  #
  # In a nutshell: if something (exec) creates a trigger file, puppet will 
  # remove it and then restart all tomcat instances

  # shared lib dir and trigger file if shared libraries in use
  if ($shared_lib_dir) {
    file { $shared_lib_dir:
      ensure  => directory,
    }

    file { $shared_lib_trigger:
      ensure => absent,
      content => $filename,
    }
  }

  # endorsed lib dir and trigger file if endorsed libraries in use
  if ($endorsed_lib_dir) {
    file { $endorsed_lib_dir:
      ensure  => directory,
    }

    file { $endorsed_lib_trigger:
      ensure => absent,
      content => $filename,
    }

  }

}
