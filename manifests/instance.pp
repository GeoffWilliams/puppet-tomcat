define tomcat::instance($ensure = true,
                        $enable = true,
                        $https_port = "fixme",
                        $http_port = "fixme",
                        $jmx_port = "fixme",
                        $shutdown_port = "fixme",
                        $jmx_enabled = false,
                        $instance_user = "tomcat",
                        $service_prefix = "tomcat",
                        $instance_root_dir = "/var/tomcat/instances",
                        $instance_subdirs = ["bin", "conf", "lib", "temp", "webapps", "work"]) {

    
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
