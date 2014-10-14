define tomcat::library( $ensure = present,
                        $download_site,
                        $shared_lib_dir = $::tomcat::params::shared_lib_dir,
                        $shared_lib_trigger = $::tomcat::params::shared_lib_trigger,) {
  $filename = $title
  $download_url = "${download_site}/${filename}"
  $local_file = "${shared_lib_dir}/${filename}"

  if (! defined(File[$shared_lib_dir])) {
    file { $shared_lib_dir:
      ensure => directory,
    }
  }

  if ($ensure == present) {
    staging::file { $filename:
      source => $download_url,
      target => $local_file,
    }
  } else {
    file { $local_file:
      ensure => absent,
    }
  }

  # nasty hack to make puppet reload all managed tomcats when it adds
  # files to this directory.  each time a library is added to the system
  # this file is updated and this is the file that the tomcat::instance 
  # class watches.  - can anyone see a better way of doing this?
  $time_formatted = strftime("%c")
  file { $shared_lib_trigger:
    ensure  => file,
    content => "latest change:${filename} at ${time_formatted}",
  }
}
