class tomcat ($shared_lib_dir = $::tomcat::params::shared_lib_dir,
              $shared_lib_trigger = $::tomcat::params::shared_lib_trigger,
              $endorsed_lib_dir = $::tomcat::params::endorsed_lib_dir,
              $endorsed_lib_trigger = $::tomcat::params::endorsed_lib_trigger,
              $instance_root_dir = $::tomcat::params::instance_root_dir,
              $file_mode_regular = $::tomcat::params::file_mode_regular,
              $file_owner = $::tomcat::params::file_owner,
              $file_group = $::tomcat::params::file_group,
        ) inherits ::tomcat::params {

  File {
    owner => $file_owner,
    group => $file_group,
    mode  => $file_mode_regular,
  }

  # directory to hold the individual tomcat instances
  file { $instance_root_dir:
    ensure => directory,
  }


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
