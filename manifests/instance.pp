define tomcat::instance($ensure = $::tomcat::params::ensure,
                        $enable = $::tomcat::params::enable,
                        $https_port = $::tomcat::params::https_port,
                        $http_port,
                        $jmx_port = $::tomcat::params::jmx_port,
                        $shutdown_port,
                        $jmx_enabled = $::tomcat::params::jmx_enabled,
                        $unpack_wars = $::tomcat::params::unpack_wars,
                        $auto_deploy = $::tomcat::params::auto_deploy,
                        $java_home = $::tomcat::params::java_home,
                        $catalina_home = $::tomcat::params::catalina_home,
                        $java_opts = $::tomcat::params::java_opts,
                        $catalina_opts = $::tomcat::params::catalina_opts,
                        $instance_user = $::tomcat::params::instance_user,
                        $instance_group = $::tomcat::params::instance_group,
                        $service_prefix = $::tomcat::params::service_prefix,
                        $pid_dir = $::tomcat::params::pid_dir,
                        $instance_root_dir = $::tomcat::params::instance_root_dir,
                        $instance_subdirs = $::tomcat::params::instance_subdirs,
                        $file_mode_group_write = $::tomcat::params::file_mode_group_write,
                        $file_mode_regular = $::tomcat::params::file_mode_regular,
                        $file_mode_script = $::tomcat::params::file_mode_script,
                        $file_mode_init = $::tomcat::params::file_mode_init,
                        $file_owner = $::tomcat::params::file_owner,
                        $file_group = $::tomcat::params::file_group,
                        $major_version = $::tomcat::params::major_version,
                        $shared_lib_dir = $::tomcat::params::shared_lib_dir,
                        $shared_lib_trigger = $::tomcat::params::shared_lib_trigger,
                        $server_xml_jdbc = "",
                        $context_xml_jdbc = "",
                        $init_script_template = false,
                        $setenv_sh_template = false,
                        $server_xml_template = false,
                        $catalina_properties_template = false,
                        $context_xml_template = false,
                        $logging_properties_template = false,
                        $tomcat_users_xml_template = false,
                        $web_xml_template = false,
                        $log_dir = false,
      ) { 
  include ::tomcat::params

  if ! defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat defined resources')
  }


  $instance_name = $title
  $service_name = "${service_prefix}${instance_name}"
  $init_script_file = "/etc/init.d/${service_name}"
  $instance_dir = "${instance_root_dir}/${instance_name}"
  $instance_pid = "${pid_dir}/${instance_name}.pid"
  
  if ($log_dir) {
    $_log_dir = $log_dir
  } else {
    $_log_dir = "${::tomcat::params::log_dir}/${instance_name}"
    
    # make parent logdir here if needed
    if (! defined(File[$::tomcat::params::log_dir])) {
      file { $::tomcat::params::log_dir:
        ensure => directory,
      }
    }
  }

  if (! defined(File[$pid_dir])) {
    file { $pid_dir:
      ensure => directory,
      group  => $instance_group,
      mode   => $file_mode_group_write,
    }
  }

  $catalina_out = "${_log_dir}/${::tomcat::params::catalina_out}"

  # params defaults into scope
  $setenv_sh = $::tomcat::params::setenv_sh
  $server_xml = $::tomcat::params::server_xml
  $catalina_properties = $::tomcat::params::catalina_properties
  $context_xml = $::tomcat::params::context_xml
  $logging_properties = $::tomcat::params::logging_properties
  $tomcat_users_xml = $::tomcat::params::tomcat_users_xml
  $web_xml = $::tomcat::params::web_xml

  case $major_version {
    "7": {
      $template_dir = $tomcat::params::tc7_templates
    }
    "8": {
      $template_dir = $tomcat::params::tc8_templates
    }
    default: {
      fail("tomcat module doesn't support major version: ${major_version}")
    }
  }

  $default_templates = "${module_name}/${template_dir}/"

  # init script - template
  if ($init_script_template) {
    $_init_script_template = $init_script_template
  } else {
    $_init_script_template = 
      $::tomcat::params::init_script_template
  }
  
  # setenv.sh - template
  if ($setenv_sh_template) {
    $_setenv_sh_template = $setenv_sh_template
  } else {
    $_setenv_sh_template = 
      $::tomcat::params::setenv_sh_template
  }

  # server.xml - template
  if ($server_xml_template) {
    $_server_xml_template = $server_xml_template
  } else {
    $_server_xml_template = 
      "${default_templates}${::tomcat::params::server_xml_template}"
  }

  # catalina.properties - template
  if ($catalina_properties_template) {
    $_catalina_properties_template = $catalina_properties_template
  } else {
    $_catalina_properties_template = 
      "${default_templates}${::tomcat::params::catalina_properties_template}"
  }

  # context.xml - template
  if ($context_xml_template) {
    $_context_xml_template = $context_xml_template
  } else {
    $_context_xml_template = 
      "${default_templates}${::tomcat::params::context_xml_template}"
  }

  # logging.properties - template
  if ($logging_properties_template) {
    $_logging_properties_template = $logging_properties_template
  } else {
    $_logging_properties_template =
      "${default_templates}${::tomcat::params::logging_properties_template}"
  }

  # tomcat-users.xml -template
  if ($tomcat_users_xml_template) {
    $_tomcat_users_xml_template = $tomcat_users_xml_template
  } else {
    $_tomcat_users_xml_template =
      "${default_templates}${::tomcat::params::tomcat_users_xml_template}"
  }

  # web.xml -template
  if ($web_xml_template) {
    $_web_xml_template = $web_xml_template
  } else {
    $_web_xml_template = 
      "${default_templates}${::tomcat::params::web_xml_template}"
  }


  # full path + filename for each file
  $setenv_sh_file = "${instance_dir}${setenv_sh}"
  $server_xml_file = "${instance_dir}${server_xml}"
  $catalina_properties_file = "${instance_dir}${catalina_properties}"
  $context_xml_file = "${instance_dir}${context_xml}"
  $logging_properties_file = "${instance_dir}${logging_properties}"
  $tomcat_users_xml_file = "${instance_dir}${tomcat_users_xml}"
  $web_xml_file = "${instance_dir}${web_xml}"



  # ensure ports are unique.  puppet takes care of this for us when we build 
  # the dependency graph.  Recall that type + title definitions must be unique 
  # within the catalogue.  Test optional ports if set.  Always test mandatory
  # ports
  if ($https_port) {
    tomcat::port { $https_port: }
  }
  
  if ($jmx_port) {
    tomcat::port { $jmx_port: }
  }

  tomcat::port{ [$http_port, $shutdown_port]: }
  
  File {
    owner => $file_owner,
    group => $file_group,
    mode  => $file_mode_regular,
  }


  #
  # init script and service
  #
  file { $init_script_file:
    ensure  => file,
    content => template($_init_script_template),
    owner   => "root",
    group   => $file_group,
    mode    => $file_mode_init,
  }

  service { $service_name:
    ensure    => $ensure,
    enable    => $enable,
    subscribe => [  File[$init_script_file],
                    File[$setenv_sh_file],
                    File[$server_xml_file],
                    File[$catalina_properties_file],
                    File[$context_xml_file],
                    File[$logging_properties_file],
                    File[$tomcat_users_xml_file],
                    File[$web_xml_file], 
                    File[$shared_lib_trigger],  ]
  }

  #
  # directory structure
  #
  file { $instance_dir:
    ensure => directory,
  }

  # log directory (needs to be writable by GROUP of tomcat process)
  file { $_log_dir:
    ensure => directory,
    group  => $instance_group,
    mode   => $file_mode_group_write,
  }

  # prefix the instance subdirs with the full path to this instance, then 
  # create them all as file resources.  Prefix() function comes from stdlib
  # see reference: https://forge.puppetlabs.com/puppetlabs/stdlib/readme#prefix
  $_instance_subdirs = prefix($instance_subdirs, $instance_dir)
  file { $_instance_subdirs:
    ensure => directory,
  }

  #
  # Files from templates
  #

  # setenv.sh
  file { $setenv_sh_file:
    ensure  => file,
    mode    => $file_mode_script,
    content => template($_setenv_sh_template),
  }
  
  # server.xml
  file { $server_xml_file:
    ensure  => file,
    content => template($_server_xml_template),
  }

  # catalina.properties
  file { $catalina_properties_file:
    ensure  => file,
    content => template($_catalina_properties_template),
  }

  # context.xml
  file { $context_xml_file: 
    ensure  => file,
    content => template($_context_xml_template),
  }

  # logging.properties
  file { $logging_properties_file: 
    ensure  => file,
    content => template($_logging_properties_template),
  } 

  # tomcat-users.xml
  file { $tomcat_users_xml_file: 
    ensure  => file,
    content => template($_tomcat_users_xml_template),
  }

  file { $web_xml_file:
    ensure  => file,
    content => template($_web_xml_template),
  }

}
