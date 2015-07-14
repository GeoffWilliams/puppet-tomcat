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
# [*download_site*]
#   Pass a location to download RPMs from using nanliu-staging (http/https/
#   ftp..).  If false (the default), RPMs will be sourced from whatever RPM
#   repositories you have enabled
#
# [*local_dir*]
#   If downloading RPMs manually, files will be saved to this directory
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
                        $file_group = $::tomcat::params::file_group,
                        $download_site = false,
                        $local_dir = $::tomcat::params::local_dir,
                        $install_dir = $::tomcat::params::install_dir) {
  include ::tomcat::params

  if (!($::osfamily in $::tomcat::params::supported_os)) {
    fail($::tomcat::params::unsupported_os_msg)
  }

  if ! defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat defined resources')
  }

  validate_absolute_path($local_dir)

  File {
    owner => $file_owner,
    group => $file_group,
  }
  
  if (! defined(File[$local_dir])) {
    file { $local_dir:
      ensure => directory,
      owner  => "root",
      group  => "root",
      mode   => "0755",
    }
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

  $file_name = $title
  $local_file = "${local_dir}/${file_name}"
  $remote_file = "${download_site}/${file_name}"
  $rpm_name = regsubst($file_name, '\.rpm', '')
  $tgz_name = regsubst($file_name, '\.tar\.gz', '')

  case $ensure {
    present: {
      if ($download_site) {
        staging::file { $file_name:
          source => $remote_file,
          target => $local_file,
        }

        case $title {
          /rpm$/: {
            package { $rpm_name:
              ensure   => present,
              provider => "rpm",
              source   => $local_file,
              require  => Staging::File[$local_file],
            }
          }
          /\.tar\.gz$/: {
            staging::extract { $file_name:
              target  => $install_dir,
              source  => $local_file,
              creates => "${install_dir}/${tgz_name}",
              require => Staging::File[$file_name],
            }
          }
          default: {
            fail("${module_name} does not support installation of file ${title}")
          }
        }
      } else {
        package { $rpm_name:
          ensure => present,
        }
      }
    }
    absent: {
      package { $rpm_name:
        ensure => absent,
      }
    }
    default: { 
      fail("ensure '${ensure}' unsupported in tomcat::install - try absent or present")
    }
  }
}
