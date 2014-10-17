$trigger_file = "reload_tomcat"
$lib_name = "libfoo.jar"
$instances = "/var/lib/tomcat"
$custom_endorsed_lib_dir = "/foo_endorsed"
$custom_endorsed_lib_trigger = "#{$custom_endorsed_lib_dir}/#{$trigger_file}"
$custom_file_group = "tomcat_group"
$custom_file_mode_init = "0740"
$custom_file_mode_regular = "0600"
$custom_file_mode_script  = "0700"
$custom_file_owner = "tomcat_user"
$custom_instance_user = "tomcat_instance_user"
$custom_instance_group = $custom_instance_user
$custom_java = "/java_foo"
$custom_shared_lib_dir = "/foo_shared"
$custom_shared_lib_trigger = "#{$custom_shared_lib_dir}/#{$trigger_file}"
$custom_tomcat = "/tomcat_foo"
$default_file = {}
$default_file["endorsed_lib_dir"] = "/usr/local/lib/tomcat_endorsed"
$default_file["shared_lib_dir"] = "/usr/local/lib/tomcat_shared"
$def_endorsed_lib_dir = "/usr/local/lib/tomcat_endorsed"
$def_endorsed_lib_trigger = "#{$def_endorsed_lib_dir}/#{$trigger_file}"
$def_file_group = "tomcat"
$def_file_mode_init = "0755"
$def_file_mode_regular = "0640"
$def_file_mode_script = "0750"
$def_file_owner = "root"
$def_instance_user = "tomcat"
$def_instance_group = $def_instance_user
$def_java = "/usr/java/default"
$def_shared_lib_dir = "/usr/local/lib/tomcat_shared"
$def_shared_lib_trigger = "#{$def_shared_lib_dir}/#{$trigger_file}"
$def_tomcat = "/usr/local/apache-tomcat"
$exec_trigger_title = "trigger_#{$lib_name}"
$default_params = {
  "http_port"     => 8080,
  "shutdown_port" => 8088,
}
$default_title = "myapp"
$def_shared_lib_target = "#{$def_shared_lib_dir}/#{$lib_name}"
$custom_shared_lib_target = "#{$custom_shared_lib_dir}/#{$lib_name}"
$def_endorsed_lib_target = "#{$def_endorsed_lib_dir}/#{$lib_name}"
$custom_endorsed_lib_target = "#{$custom_endorsed_lib_dir}/#{$lib_name}"

$def_pre_condition = 'class { "tomcat": }'
$custom_pre_condition = <<-EOD
  class { "tomcat":
    shared_lib_dir   => "#{$custom_shared_lib_dir}",
    endorsed_lib_dir => "#{$custom_endorsed_lib_dir}",
  }
EOD
$def_java_pre_condition = <<-EOD
  class { "tomcat":}
    file { "#{$def_java}":
      ensure => file,
  }
EOD
$custom_java_pre_condition = <<-EOD
  class { "tomcat":}
    file { "#{$custom_java}":
      ensure => file,
  }
EOD
$def_tomcat_pre_condition = <<-EOD
  class { "tomcat":}
  file { "#{$def_tomcat}":
    ensure => file,
  }
EOD
$custom_tomcat_pre_condition = <<-EOD
  class { "tomcat":}
  file { "#{$custom_tomcat}":
    ensure => file,
  }
EOD

