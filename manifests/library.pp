define tomcat::library( $ensure = present,
                        $download_site,
                        $endorsed = false,
                        $shared_lib_dir = $::tomcat::params::shared_lib_dir,
                        $shared_lib_trigger = $::tomcat::params::shared_lib_trigger,
                        $endorsed_lib_dir = $::tomcat::params::endorsed_lib_dir,
                        $endorsed_lib_trigger = $::tomcat::params::endorsed_lib_trigger,) {
  $filename = $title
  $download_url = "${download_site}/${filename}"

  if ($endorsed) {
    $local_file = "${endorsed_lib_dir}/$filename"
    $trigger_file = $endorsed_lib_trigger
  } else {
    $local_file = "${shared_lib_dir}/$filename"
    $trigger_file = $shared_lib_trigger
  }

  if (! defined(File[$shared_lib_dir])) {
    file { $shared_lib_dir:
      ensure  => directory,
#      purge   => false,
#      recurse => true,

    }
  }

  if (! defined(File[$endorsed_lib_dir])) {
    file { $endorsed_lib_dir:
      ensure  => directory,
 #     purge   => false,
 #     recurse => true,
    }
  }

  if ($ensure == present) {
    staging::file { $filename:
      source => $download_url,
      target => $local_file,
      notify => Exec["trigger"]
    }
  } else {
    file { $local_file:
      ensure => absent,
      notify => Exec["trigger"]
    }
  }

  # nasty hack to make puppet reload all managed tomcats when it adds
  # files to this directory.  each time a library is added to the system
  # this file is updated and this is the file that the tomcat::instance 
  # class watches.  - can anyone see a better way of doing this?
#  $time_formatted = strftime("%c")
#  file { $trigger_file:
#    ensure  => file,
#    content => "latest change:${filename} at ${time_formatted}",
#  }
#  exec { "trigger_${filename}":
#    command => "/usr/bin/md5sum ${shared_lib_dir}/* > ${shared_lib_trigger}"
#  }
  exec { "trigger":
    command     => "/bin/touch ${shared_lib_trigger}",
    refreshonly => true,
    before      => File[$shared_lib_trigger],
  }

  # trigger files for both directories must exist in the catalog at all
  # times otherwise there will be compile errors.
#  if (! defined(File[$shared_lib_trigger])) {
    file { $shared_lib_trigger:
      ensure => absent,
      content => $filename,
    }
 # }

  #if (! defined(File[$endorsed_lib_trigger])) {
    file { $endorsed_lib_trigger:
      ensure => absent,
      content => $filename,
    }
  #}
}
