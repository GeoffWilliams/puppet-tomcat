define tomcat::library( $ensure = present,
                        $download_site,
                        $endorsed = false,
                        $shared_lib_dir = $::tomcat::params::shared_lib_dir,
                        $endorsed_lib_dir = $::tomcat::params::endorsed_lib_dir, ) { 
  $filename = $title
  $download_url = "${download_site}/${filename}"
  $trigger_title = "trigger_${filename}"
  $shared_lib_trigger = "${shared_lib_dir}/${::tomcat::params::trigger_file}"
  $endorsed_lib_trigger = "${endorsed_lib_dir}/${::tomcat::params::trigger_file}"


  if ($endorsed) {
    validate_absolute_path($endorsed_lib_dir)
    $local_file = "${endorsed_lib_dir}/$filename"
    $trigger_file = $endorsed_lib_trigger
  } else {
    validate_absolute_path($shared_lib_dir)
    $local_file = "${shared_lib_dir}/$filename"
    $trigger_file = $shared_lib_trigger
  }

  # just incase someone passed a string with strange chars...
  validate_absolute_path($local_file)

  if ($ensure == present) {
    staging::file { $filename:
      source => $download_url,
      target => $local_file,
      notify => Exec[$trigger_title],
    }
  } else {
    file { $local_file:
      ensure => absent,
      notify => Exec[$trigger_title],
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
