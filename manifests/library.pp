define tomcat::library( $ensure = present,
                        $download_site = "",
                        $lib_type = "shared",
                        $shared_lib_dir = $::tomcat::params::shared_lib_dir,
                        $endorsed_lib_dir = $::tomcat::params::endorsed_lib_dir, ) { 
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
