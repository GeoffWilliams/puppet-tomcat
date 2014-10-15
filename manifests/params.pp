class tomcat::params {

  # ensure the tomcat service (start/stop at boot)
  $service_ensure = true

  # enable the tomcat service (start/stop now)
  $service_enable = true

  $ajp_port = false

  # false or https port to open
  $https_port = false

  $https_attributes = 'protocol="org.apache.coyote.http11.Http11Protocol" maxThreads="150" SSLEnabled="true" scheme="https" secure="true" clientAuth="false" sslProtocol="TLS"'

  # false or jmx port to open
  $jmx_port = false

  $jmx_ssl = false
  
  $jmx_authenticate = false

  $jmx_password_file = ""
  
  $jmx_access_file = ""

  # unpack .war files detected in /webapps
  $unpack_wars = true

  # deploy applications detected in /webapps
  $auto_deploy = true

  # default directory to look for java
  $java_home = "/usr/java/default"

  # default directory to look for tomcat shared installation
  $catalina_home = "/usr/local/apache-tomcat-7.0.56"

  # additional options to pass to JDK when starting
  $java_opts = ""

  # additional options to pass to tomcat when starting
  $catalina_opts = ""

  # system user to run tomcat as
  $instance_user = "tomcat"

  # system group that $instance_user belongs to
  $instance_group = "tomcat"

  # prefix to apply to init scripts eg, "tomcat_" to create tomcat_myinstance
  $service_prefix = "tomcat_"

  # directory to keep pid files
  $pid_dir = "/var/run/tomcat"

  # where to store logs
  $log_dir = "/var/log/tomcat"

  $shared_lib_dir = "/usr/local/lib/tomcat_shared"
  $shared_lib_trigger = "${shared_lib_dir}/trigger.txt"

  $endorsed_lib_dir = "/usr/local/lib/tomcat_endorsed"
  $endorsed_lib_trigger = "${endorsed_lib_dir}/trigger.txt"

  # file for catalina.out (stdout/stderr) logging
  $catalina_out = "catalina.out"

  # directory to build tomcat instance's ($CATALINA_BASE's) under
  $instance_root_dir = "/var/lib/tomcat"

  # List of directories to create for each tomcat instance
  $instance_subdirs = [ "/bin",
                        "/conf", 
                        "/lib", 
                        "/temp", 
                        "/webapps", 
                        "/work"]

  # Default mode for regular files
  $file_mode_regular = "0644"

  # default mode for init scripts
  $file_mode_init = "0755"

  # Default mode for writable directories (group writable)
  $file_mode_group_write = "0775"

  # default owner for files
  $file_owner = "root"

  # default group for files
  $file_group = "root"

  # subdirectory within 'templates' to find tomcat 7 config files
  $tc7_templates = "tc7"

  # subdirectory within 'templates' to find tomcat 8 config files
  $tc8_templates = "tc8"
  
  # major version of tomcat we are setting up (used to load the correct 
  # templates)
  $major_version = 7  

  # where to read the init script template from
  $init_script_template = "${module_name}/tomcat_init_script.sh.erb"
  $setenv_sh = "/bin/setenv.sh"
  $setenv_sh_template = "${module_name}/setenv.sh.erb"
  $server_xml = "/conf/server.xml"
  $server_xml_template = "server.xml.erb"
  $catalina_properties = "/conf/catalina.properties"
  $catalina_properties_template = "catalina.properties.erb"
  $context_xml = "/conf/context.xml"
  $context_xml_template = "context.xml.erb"
  $logging_properties = "/conf/logging.properties"
  $logging_properties_template = "logging.properties.erb"
  $tomcat_users_xml = "/conf/tomcat-users.xml"
  $tomcat_users_xml_template = "tomcat-users.xml.erb"
  $web_xml = "/conf/web.xml"
  $web_xml_template = "web.xml.erb"
}
