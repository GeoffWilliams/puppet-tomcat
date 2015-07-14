# == Define: tomcat::instance
#
# Create a tomcat instance on a node
#
# === Parameters
#
# [*namevar*]
#   Name of this tomcat instance.  The name chosen will be used to create a
#   directory under `$instance_root_dir` and will also be visible in the 
#   process table
#
# [*service_ensure*]
#   Ensure parameter to pass to the service resource we will create to run this
#   instance.
#
# [*service_enable*]
#   Enable parameter to pass to the service resource we will create to run this
#   instance.
#
# [*https_port*]
#   Port to listen for HTTPS requests on or false to disable.
#
# [*https_attributes*]
#   Attributes to incorporate as-is into the https connector (if used).
#   Default:  $::tomcat::params::https_attributes (will not result in a working
#   system - needs keystore, etc)
#
# [*http_port*]
#   Port to listen for HTTP requests on
#
# [*ajp_port*]
#   Port to listen for AJP requests on or false to disable
#
# [*jmx_port*]
#   Port to listen for JMX requests on or false to disable
#
# [*jmx_ssl*]
#   Use SSL for JMX connections?
#
# [*jmx_authenticate*]
#   Set true to force JMX connections to be authenticated
#
# [*jmx_password_file*]
#   Supply a file to read JMX passwords from if using JMX and forcing 
#   authentication   
#
# [*jmx_access_file*]
#   Supply a file here with access rights if using JMX and authentication
#
# [*shutdown_port*]
#   Port to listen for the shutdown command on
#
# [*unpack_wars*]
#   Set true to unpack .war files found in the instance /webapps directory
#
# [*auto_deploy*]
#   Set true to automatically deploy applications found in the instance 
#   /webapps directory
#
# [*java_home*]
#   Path to root of a JDK installation to use for this tomcat instance
#
# [*catalina_home*]
#   Path to root of unpacked tomcat installation to use for this tomcat 
#   instance
#
# [*java_opts*]
#   Additional options to pass through to the java command we will run
#   this instance with
#
# [*catalina_opts*]
#   Additional options to pass through to the java command we will run
#   this instance with
#
# [*instance_user*]
#   User to run this tomcat instance as.  Won't be created here
#
# [*pid_file*]
#   If supplied, full path to a file where we will save the PID of this tomcat
#   instance
#
# [*instance_root_dir*]
#   Directory to create all tomcat instances under on this node.  Created by
#   the `::tomcat` class
#
# [*file_mode_regular*]
#   Mode to use for 'normal' files
#
# [*file_mode_script*]
#   Mode to use for scripts (other then the init script)
#
# [*file_mode_init*]
#   Mode to use for the init script
#
# [*file_owner*]
#   Non-writable directories and files will be owned by this user (except the
#   init script)
#
# [*file_group*]
#   Non-writable directories and files will be owned by this group
#
# [*major_version*]
#   Identify the major version of tomcat that this instance will be running.
#   Currently supports 7 or 8 (as integers)
#
# [*shared_lib_dir*]
#   Location of the directory used for shared Java libraries on this node or
#   false to disable this feature.  Must match the setting used when declaring
#   the ::tomcat class
#
# [*endorsed_lib_dir*]
#   Location of the directory used for endorsed Java libraries on this node or
#   false to disable this feature.  Must match the setting used when declaring
#   the ::tomcat class
#
# [*server_xml_jdbc*]
#   XML fragment to incorporate into server.xml to enable any required JDBC 
#   connections on this node
#
# [*context_xml_jdbc*]
#   XML fragment to incorporate into context.xml to enable JDBC connections 
#   defined in server.xml as required
#
# [*init_script_template*]
#   Set to the location of your own template to use for building the init 
#   script if the built-in version doesn't suit your needs
#
# [*setenv_sh_template*]
#   Set to the location of your own template to use for building the setenv.sh
#   file if the built-in version doesn't suit your needs
#
# [*server_xml_template*]
#   Set to the location of your own template to use for building the server.xml 
#   file if the built-in version doesn't suit your needs
#
# [*catalina_properties_template*]
#   Set to the location of your own template to use for building the 
#   catalina.properties file if the built-in version doesn't suit your needs
#
# [*context_xml_template*]
#   Set to the location of your own template to use for building the context.xml
#   file if the built-in version doesn't suit your needs
#
# [*logging_properties_template*]
#   Set to the location of your own template to use for building the 
#   logging.properties file if the built-in version doesn't suit your needs
#
# [*tomcat_users_xml_template*]
#   Set to the location of your own template to use for building the 
#   tomcat-users.xml file if the built-in version doesn't suit your needs
#
# [*web_xml_template*]
#   Set to the location of your own template to use for building the web.xml
#   file if the built-in version doesn't suit your needs
#
# [*log_dir*]
#   Set an alternate log directory.  Note that all tomcat instances generate
#   log files with the same filename, so you must come up with a naming 
#   convention that allows each tomcat instance to have its own log directory

# [*catalina_properties_extra_args*]
#   Extra arguments to add to catalina.properties
#
# [*tomcat_extra_setenv_args*]
#   Extra BASH script to add to the end of the setenv.sh script
#
# [*watch_tomcat*]
#   If true, the service for this instance will subscribe to the file at 
#   $catalina_home so that tomcat will be restarted if this file changes in
#   any way (eg new version).  If true, the referenced file must exist in the
#   catalog.  If false, no action will be taken if the file at $catalina_home 
#   changes
#
# [*watch_java*]
#   If true, the service for this instance will subscribe to the file at 
#   $java_home so that tomcat will be restarted if this file changes in
#   any way (eg new version).  If true, the referenced file must exist in the
#   catalog.  If false, no action will be taken if the file at $java_home 
#   changes

# === Examples
#
# Provide some examples on how to use this type:
#
# see README.md
#
# === Authors
#
# Geoff Williams <geoff.williams@puppetlabs.com>
#
# === Copyright
#
# Copyright 2014 Puppet Labs, unless otherwise noted.
#
define tomcat::instance($service_ensure = $::tomcat::params::service_ensure,
                        $service_enable = $::tomcat::params::service_enable,
                        $https_port = $::tomcat::params::https_port,
                        $https_attributes = $::tomcat::params::https_attributes,
                        $http_port,
                        $ajp_port = $::tomcat::params::ajp_port,
                        $jmx_port = $::tomcat::params::jmx_port,
                        $jmx_ssl = $::tomcat::params::jmx_ssl,
                        $jmx_authenticate = $::tomcat::params::jmx_authenticate,
                        $jmx_password_file = $::tomcat::params::jmx_password_file,
                        $jmx_access_file = $::tomcat::params::jmx_access_file,
                        $shutdown_port,
                        $unpack_wars = $::tomcat::params::unpack_wars,
                        $auto_deploy = $::tomcat::params::auto_deploy,
                        $java_home = $::tomcat::params::java_home,
                        $catalina_home = $::tomcat::params::catalina_home,
                        $java_opts = $::tomcat::params::java_opts,
                        $catalina_opts = $::tomcat::params::catalina_opts,
                        $instance_user = $::tomcat::params::instance_user,
                        $pid_file = false,
                        $instance_root_dir = $::tomcat::params::instance_root_dir,
                        $file_mode_regular = $::tomcat::params::file_mode_regular,
                        $file_mode_script = $::tomcat::params::file_mode_script,
                        $file_mode_init = $::tomcat::params::file_mode_init,
                        $file_owner = $::tomcat::params::file_owner,
                        $file_group = $::tomcat::params::file_group,
                        $major_version = $::tomcat::params::major_version,
                        $shared_lib_dir = $::tomcat::params::shared_lib_dir,
                        $endorsed_lib_dir = $::tomcat::params::endorsed_lib_dir,
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
                        $catalina_properties_extra_args = "",
                        $tomcat_extra_setenv_args = "",
                        $watch_tomcat = true,
                        $watch_java = true,
      ) { 
  include ::tomcat::params

  if (!($::osfamily in $::tomcat::params::supported_os)) {
    fail($::tomcat::params::unsupported_os_msg)
  }

  if ! defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat defined resources')
  }

  $instance_group = $instance_user
  $instance_subdirs_ro = $::tomcat::params::instance_subdirs_ro
  $instance_subdirs_rw = $::tomcat::params::instance_subdirs_rw

  # parameter validation
  validate_bool($service_ensure)
  validate_bool($service_enable)
  validate_bool($jmx_ssl)
  validate_bool($jmx_authenticate)
  validate_bool($unpack_wars)
  validate_bool($auto_deploy)
  if ($jmx_port and $jmx_authenticate) {
    validate_string($jmx_password_file)
    validate_string($jmx_access_file)
  }
  validate_absolute_path($java_home)
  validate_absolute_path($catalina_home)
  validate_string($java_opts)
  validate_string($catalina_opts)
  validate_string($instance_user)
  validate_string($instance_group)
  validate_absolute_path($instance_root_dir)
  validate_string($file_owner)
  validate_string($file_group)
  if ($pid_file) {
    validate_absolute_path($pid_file)
  } 
  if ($log_dir) {
    validate_absolute_path($log_dir)
  }
  if ($shared_lib_dir) {
    validate_absolute_path($shared_lib_dir)
  } 
  if ($endorsed_lib_dir) {
    validate_absolute_path($endorsed_lib_dir)
  }

  validate_string($catalina_properties_extra_args)
  validate_string($tomcat_extra_setenv_args)


  $instance_name = $title
  $service_prefix = $::tomcat::params::service_prefix
  $service_name = "${service_prefix}${instance_name}"
  $init_script_file = "/etc/init.d/${service_name}"
  $instance_dir = "${instance_root_dir}/${instance_name}"
  $xml_validate_command = $::tomcat::params::xml_validate_command
  $endorsed_lib_trigger = "${endorsed_lib_dir}/${::tomcat::params::trigger_file}"
  $shared_lib_trigger = "${shared_lib_dir}/${::tomcat::params::trigger_file}"

  # choose the PID file and logging directories for this instance.  If
  # user has specified something this will be used instead of the defaults. If
  # overriden, writable directories will still be created but never written to 
  # when we process the instance_subdirs_rw array.
  #
  # The PID file to use gets defined in the init script 
  #
  # The logging directory to use gets defined in logging.propperties and 
  # setenv.sh
  #
  # If user specified a location of either of these locations, they must ensure
  # any required directories exist themselves.

  # $_pid_file -- absolute path to PID file for this instance
  if ($pid_file) {
    $_pid_file = $pid_file
  } else {
    $_pid_file = 
      "${instance_dir}/${::tomcat::params::pid_dir}/${instance_name}.pid"
  }
  
  # $_log_dir -- absolute path to log directory for this instance
  if ($log_dir) {
    $_log_dir = $log_dir
  } else {
    $_log_dir = "${instance_dir}/${::tomcat::params::log_dir}"
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
    7: {
      $template_dir = $tomcat::params::tc7_templates
    }
    8: {
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

  # build a big array of "watched resources" that will cause this service
  # to reload if altered

  # basic resources to watch - present in all instances
  $basic_watched =  [  
    File[$init_script_file],
    File[$setenv_sh_file],
    File[$server_xml_file],
    File[$catalina_properties_file],
    File[$context_xml_file],
    File[$logging_properties_file],
    File[$tomcat_users_xml_file],
    File[$web_xml_file],
  ]


  # list of resources (trigger file) to watch if endorsed libs are in use
  if ($endorsed_lib_dir) {
    $endorsed_watched = [ 
      File[$endorsed_lib_trigger],
    ]
  } else {
    $endorsed_watched = []
  }

  # if shared libraries are in use, build the fragment to add to 
  # catalina.properties and add the trigger file to the list of watched
  # resources
  if ($shared_lib_dir) {
    $shared_watched = [
      File[$shared_lib_trigger]
    ]
    if ($major_version > 7) {
      # tomcat 8 and above should have path elements quoted
      $shared_lib_cfg = "\"${shared_lib_dir}\",\"${shared_lib_dir}/*.jar\","
    } else {
      $shared_lib_cfg = "${shared_lib_dir},${shared_lib_dir}/*.jar,"
    }
  } else {
    $shared_watched = []
    $shared_lib_cfg = ""
  }

  # if we are running against java and tomcat symlinks/directories that are 
  # puppet managed (not the same as packages installed by puppet!!), then we
  # will add these files to the list of "watched" resources so that if they 
  # are changed, puppet will restart tomcat for us.  This is good if (eg) we
  # installed tomcat at /usr/local/apache-tomcat and upgraded by changing
  # the symlink
  if ($watch_tomcat) {
    $tomcat_watched = [File[$catalina_home]]
  } else {
    $tomcat_watched = []
  }
  if ($watch_java) {
    $java_watched = [File[$java_home]]
  } else {
    $java_watched = []
  }
#  $install_watched = concat($tomcat_watched, $java_watched)

  # concatenate all the watched resources to one array
#  $lib_watched = concat($endorsed_lib_dir_watched, $shared_lib_dir_watched)
#  $shared_watched = concat($lib_watched, $install_watched)
#  $watched = concat($basic_watched, $install_watched)

  $watched = 
    concat($basic_watched,
      concat($endorsed_watched,
        concat($shared_watched,
          concat($tomcat_watched,$java_watched)
        )
      )
    )

  # ensure ports are unique.  puppet takes care of this for us when we build 
  # the dependency graph.  Recall that type + title definitions must be unique 
  # within the catalogue.  Test optional ports if set.  Always test mandatory
  # ports
  if ($https_port) {
    tomcat::port { "${https_port}": }
  }
  
  if ($jmx_port) {
    tomcat::port { "${jmx_port}": }
  }

  if ($ajp_port) {
    tomcat::port { "${ajp_port}": }
  }

  tomcat::port{ ["${http_port}", "${shutdown_port}"]: }
  
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
    ensure    => $service_ensure,
    enable    => $service_enable,
    subscribe => $watched,
  }

  #
  # directory structure
  #
  file { $instance_dir:
    ensure => directory,
  }

  # prefix the instance subdirs with the full path to this instance, then 
  # create them all as file resources.  Prefix() function comes from stdlib
  # see reference: https://forge.puppetlabs.com/puppetlabs/stdlib/readme#prefix
  $_instance_subdirs_ro = prefix($instance_subdirs_ro, $instance_dir)
  $_instance_subdirs_rw = prefix($instance_subdirs_rw, $instance_dir)
  file { $_instance_subdirs_ro:
    ensure => directory,
  }

  file { $_instance_subdirs_rw:
    ensure => directory,
    owner  => $instance_user,
    group  => $instance_group,
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
    ensure       => file,
    content      => template($_server_xml_template),
    validate_cmd => $xml_validate_command,
  }

  # catalina.properties
  file { $catalina_properties_file:
    ensure  => file,
    content => template($_catalina_properties_template),
  }

  # context.xml
  file { $context_xml_file: 
    ensure       => file,
    content      => template($_context_xml_template),
    validate_cmd => $xml_validate_command,
  }

  # logging.properties
  file { $logging_properties_file: 
    ensure  => file,
    content => template($_logging_properties_template),
  } 

  # tomcat-users.xml
  file { $tomcat_users_xml_file: 
    ensure       => file,
    content      => template($_tomcat_users_xml_template),
    validate_cmd => $xml_validate_command,
  }

  file { $web_xml_file:
    ensure       => file,
    content      => template($_web_xml_template),
    validate_cmd => $xml_validate_command,
  }

}
