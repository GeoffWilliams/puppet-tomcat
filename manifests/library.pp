# == Define: tomcat::library
#
# Installs or removes a shared/endorsed library from a node
#
# === Parameters
#
# [*namevar*]
#   Filename of library to install/remove
# 
# [*ensure*]
#   `present` to install a library or `absent` to remove it
#
# [*download_site*]
#   URL of site to download library file from (must be supported by 
#   nanliu-staging module)
#
# [*lib_type*]
#   "shared" to install a shared Java library, "endorsed" to install an 
#   endorsed library
#
# [*shared_lib_dir*]
#   Location of the directory used for shared Java libraries on this node or
#   false to disable this feature.  Must match the setting used when declaring
#   the ::tomcat class
#
# [*endorsed_lib_dir*]
#   Location of the directory used for endorsed Java libraries on this node or
#   false to disable this feature.  Must match the setting used when declaring
#   the ::tomcat class
#
# [*file_owner*]
#   Non-writable directories and files will be owned by this user (except the
#   init script)
#
# [*file_group*]
#   Non-writable directories and files will be owned by this group
#
# [*file_mode_regular*]
#   Mode to use for 'normal' files
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
define tomcat::library( $ensure = present,
                        $download_site = "",
                        $lib_type = "shared",
                        $shared_lib_dir = $::tomcat::params::shared_lib_dir,
                        $endorsed_lib_dir = $::tomcat::params::endorsed_lib_dir,
                        $file_owner = $::tomcat::params::file_owner,
                        $file_group = $::tomcat::params::file_group,
                        $file_mode_regular = $::tomcat::params::file_mode_regular ) {


  if (!($::osfamily in $::tomcat::params::supported_os)) {
    fail($::tomcat::params::unsupported_os_msg)
  }

  if ! defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat defined resources')
  }


  File {
    owner => $file_owner,
    group => $file_group,
    mode  => $file_mode_regular,
  }

  $filename = $title
  $download_url = "${download_site}/${filename}"
  $trigger_title = "trigger_${filename}"
  $shared_lib_trigger = "${shared_lib_dir}/${::tomcat::params::trigger_file}"
  $endorsed_lib_trigger = "${endorsed_lib_dir}/${::tomcat::params::trigger_file}"

  case ($lib_type) {
    "shared": {
      validate_absolute_path($shared_lib_dir)
      $local_file = "${shared_lib_dir}/$filename"
      $trigger_file = $shared_lib_trigger
    }
    "endorsed": {
      validate_absolute_path($endorsed_lib_dir)
      $local_file = "${endorsed_lib_dir}/$filename"
      $trigger_file = $endorsed_lib_trigger
    }
    default : {
      fail("lib_type '${lib_type}' not supported, try 'shared' or 'endorsed'")
    }
  }
  # just incase someone passed a string with strange chars...
  validate_absolute_path($local_file)
  
  case ($ensure) {
    present: {
      validate_string($download_site)
      staging::file { $filename:
        source => $download_url,
        target => $local_file,
        notify => Exec[$trigger_title],
      }
      
      # fix permissions on files placed by staging::file
      file { $local_file:
        ensure  => file,
        owner   => $file_owner,
        group   => $file_group,
        mode    => $file_mode_regular,
        require => Staging::File[$filename],
        notify  => Exec[$trigger_title],
      }
    }
    absent: {
      file { $local_file:
        ensure => absent,
        notify => Exec[$trigger_title],
      }
    }
    default: {
      fail("ensure=>${ensure} not supported, try present or absent")
    }
  }

  # nasty hack to make puppet reload all managed tomcats when it adds
  # files to this directory.  each time a library is added to the system
  # this file is updated and this is the file that the tomcat::instance 
  # class watches.  - can anyone see a better way of doing this?
  exec { $trigger_title:
    command     => "/bin/touch ${trigger_file}",
    refreshonly => true,
    before      => File[$trigger_file],
  }

}
