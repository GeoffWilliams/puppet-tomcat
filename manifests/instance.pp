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
                        $instance_subdirs = [ "/bin", 
                                              "/conf", 
                                              "/lib", 
                                              "/temp", 
                                              "/webapps", 
                                              "/work"],
                        $file_mode_regular = "0644",
                        $file_mode_init = "0755",
                        $file_mode_script = "0755",
                        $file_owner = "root",
                        $file_group = "root",
                        $templates = {
                          "/bin/setenv.sh"   => {
                            "mode"     => "0755",
                            "template" => "${module_name}/bin/setenv.sh.erb",
                          },
                          "/bin/startup.sh"  => {
                            "mode"     => "0755",
                            "template" => "${module_name}/bin/startup.sh.erb",
                          },
                          "/bin/shutdown.sh" => {
                            "mode"     => "0755",
                            "template" => "${module_name}/bin/shutdown.sh.erb",
                          },
                          "/conf/server.xml"  => {
                            "template" => "${module_name}/conf/server.xml.erb",
                          },
                          "/conf/catalina.properties" => {
                            "template" => "${module_name}/conf/catalina.properties.erb",
                          },
                          "/conf/catalina.policy" => {
                            "template" => "${module_name}/conf/catalina.policy.erb",
                          },
                          "/conf/context.xml" => {
                            "template" => "${module_name}/conf/context.xml.erb",
                          },
                          "/conf/logging.properties" => {
                            "template" => "${module_name}/conf/logging.properties.erb",
                          },
                          "/conf/tomcat-users.xml" => {
                              "template" => "${module_name}/conf/tomcat-users.xml.erb",
                          },
                          "/conf/web.xml" => {
                            "template" => "${module_name}/conf/web.xml.erb",
                          }
                        }) {

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
    owner   => "root",
    group   => $file_group,
    mode    => $file_mode_init,
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

  # go through the $templates variable and find all the key names, then store
  # them in an array.  keys() is defined in stdlib, see reference: 
  # https://forge.puppetlabs.com/puppetlabs/stdlib/readme#keys
  $keys = keys($templates)

  # list of the full path for each of the files to create.  This is produced 
  # by adding the instance_dir to the each key using the prefix function from 
  # stdlib.
  $files = prefix($keys, $instance_dir)

  # Use the zip() and hash() functions from stdlib to build a hash of full
  # filenames to keys, so that these can be passed to the tomcat::template_file
  # defined type so that it can find the correct template for each file.  See
  # reference links below for function documentation
  # hash: https://forge.puppetlabs.com/puppetlabs/stdlib/readme#hash
  # zip: https://forge.puppetlabs.com/puppetlabs/stdlib/readme#zip
  $key_file_pairs = zip($files,$keys)
  $file_key_map = hash($key_file_pairs)

  # Create each of the files from templates
  tomcat::template_file { $files:
    templates    => $templates,
    file_key_map => $file_key_map,
  }


}
