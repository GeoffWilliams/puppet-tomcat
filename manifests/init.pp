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
