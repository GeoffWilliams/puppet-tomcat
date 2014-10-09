define tomcat::instance(
    $catalina_base,
    $catalina_home,
    $instance_bin = "${catalina_base}/${tomcat::params::bin_dir}"
    $instance_user = $tomcat::params::tomcat_user,
    $instance_group = $tomcat::params::tomcat_group,
    $instance_mode = $tomcat::params::tomcat_mode,


    ) inherits tomcat::params {
     
    File {
        owner => $instance_user,
        group => $instance_group,
        mode  => $instance_mode,
    }
   
    file { $catalina_base:
        ensure => directory,
    }
}
