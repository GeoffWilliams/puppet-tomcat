define tomcat::instance($ensure = true,
                        $enable = true,
                        $https_port = false,
                        $http_port,
                        $jmx_port = false,
                        $shutdown_port,
                        $jmx_enabled = false,
                        $instance_user = "tomcat",
                        $service_prefix = "tomcat",
                        $instance_root_dir = "/var/tomcat/instances",
                        $instance_subdirs = ["bin", "conf", "lib", "temp", "webapps", "work"]) {


  # ensure ports are unique.  puppet takes care of this for us when we build 
  # the dependency graph.  Recall that type + title definitions must be unique 
  # within the catalogue.  Test optional ports if set.  Always test mandatory
  # ports
  if ($https_port) {
    tomcat::port{$https_port:}
  }
  
  if ($jmx_port) {
    tomcat::port{$jmx_port:}
  }

  tomcat::port{[$http_port, $shutdown_port]: }
  
  $owner = "root"
  $group = "root"
  $mode  = "0755"

  $instance_name = $title
  $service_name = "${service_prefix}_${instance_name}"
  $init_script = "/etc/init.d/${service_name}"
  $instance_dir = "${instance_root_dir}/${instance_name}"

  #
  # init script and service
  #
  file { $init_script:
    ensure  => file,
    content => "echo TOMCAT ${title} \$1",
    owner   => $owner,
    group   => $group,
    mode    => $mode,
  }

  service { $service_name:
    ensure    => $ensure,
    enable    => $enable,
    subscribe => File[$init_script],
  }

  #
  # directory structure
  #
  file { $instance_dir:
    ensure => directory,
    owner  => $owner,
    group  => $group,
    mode   => $mode,
  }

  tomcat::instance_dirs { $instance_subdirs:
    instance_dir => $instance_dir,
    owner        => $owner,
    group        => $group,
    mode         => $mode, 
  }
}
