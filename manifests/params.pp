class tomcat::params {

  $service_ensure = true
  $service_enable = true
  $ajp_port = false
  $https_port = false
  
  # will result in a broken ssl configuration if used verbatim - needs keystore
  $https_attributes = 'protocol="org.apache.coyote.http11.Http11Protocol" maxThreads="150" SSLEnabled="true" scheme="https" secure="true" clientAuth="false" sslProtocol="TLS"'

  $jmx_port = false
  $jmx_ssl = false
  $jmx_authenticate = false
  $jmx_password_file = ""
  $jmx_access_file = ""
  $unpack_wars = true
  $auto_deploy = true
  $java_home = "/usr/lib/jvm/java"
  $catalina_home = "/usr/local/apache-tomcat"
  $java_opts = ""
  $catalina_opts = ""
  $instance_user = "tomcat"
  $service_prefix = "tomcat_"
  
  # filename of "trigger file" that will force a tomcat reload if found during
  # a puppet run in one of the shared or endorsed library directories.
  $trigger_file = "reload_tomcat"
  $shared_lib_dir = "/usr/local/lib/tomcat_shared"
  $endorsed_lib_dir = "/usr/local/lib/tomcat_endorsed"

  # file for catalina.out (stdout/stderr) logging
  $catalina_out = "catalina.out"

  $instance_root_dir = "/var/tomcat"


  # List of RO directories to create for each tomcat instance
  $instance_subdirs_ro = ["/bin",
                          "/conf", 
                          "/lib", ]

  # list of RW directories to create for each tomcat instance
  $log_dir = "logs"
  $pid_dir = "run"
  $instance_subdirs_rw = ["/${log_dir}",
                          "/${pid_dir}",
                          "/temp",
                          "/work",
                          "/webapps",
                          "/conf/Catalina", ]

  $file_mode_regular = "0640"
  $file_mode_script = "0750"
  $file_mode_init = "0755"
  $file_owner = "root"
  $file_group = "tomcat"
  
  # subdirectory within 'templates' to find tomcat 7 config files
  $tc7_templates = "tc7"

  # subdirectory within 'templates' to find tomcat 8 config files
  $tc8_templates = "tc8"
  
  # major version of tomcat we are setting up (used to load the correct 
  # default templates)
  $major_version = 8  

  # validate XML config files before reloading tomcat.  Invalid files will
  # be rejected.  xmllint command comes from libxml2 on redhat
  $xml_validate_command = "xmllint --noout %"

  # filenames and templates
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

  # list of supported OS families
  $supported_os = [
    "RedHat"
  ]
  
  # messsage given on attempt to run on unsupported OS
  $unsupported_os_msg = "This Java module only supports the RedHat OS family"

  # where to download RPMs locally if using using direct download to install 
  # rpms
  $local_dir = "/var/cache/tomcat_rpms"

  # installation diretory when using tarballs
  $install_dir = "/usr/local"
}
