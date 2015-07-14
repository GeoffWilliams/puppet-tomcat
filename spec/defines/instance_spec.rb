require 'spec_helper'

describe 'tomcat::instance', :type => :define do

  let :pre_condition do
    'class { "tomcat": }'
  end
  let :facts do
    {
      :osfamily => "RedHat",
    }
  end

  context "fails on non-redhat os family" do
    let :facts do
      {
        :osfamily => "debian",
      }
    end
    let :title do
      "myapp"
    end
    it {
      expect { should compile }.to raise_error(/only supports the RedHat/)
    }
  end


  #
  # service
  #
  context "service ensure=>false; enable=>true" do
    let :title do
      "myapp"
    end
    let :params do
      {
        "service_ensure" => false,
        "service_enable" => true,
        "http_port"      => 8080,
        "shutdown_port"  => 8088,
      }
    end
    it {
      should contain_service("tomcat_myapp").with(
        "ensure" => false,
        "enable" => true,
      )
    }
  end

  context "service ensure=>true; enable=>false" do
    let :title do
      "myapp"
    end
    let :params do
      {
        "service_ensure" => true,
        "service_enable" => false,
        "http_port"      => 8080,
        "shutdown_port"  => 8088,
      }
    end
    it {
      should contain_service("tomcat_myapp").with(
        "ensure" => true,
        "enable" => false,
      )
    }
  end

  # subscriptions
  tests = {
    "service restart shared_lib_dir trigger (default)" => {
      "params" => {
        "http_port"      => 8080,
        "shutdown_port"  => 8088,
      },
      "subscribe" => $def_shared_lib_trigger,
    },
    "service restart shared_lib_dir trigger (off)" => {
      "params" => {
        "http_port"      => 8080,
        "shutdown_port"  => 8088,
        "shared_lib_dir" => false,
      },
      "no_subscribe" => $def_shared_lib_trigger,
    },
    "service restart shared_lib_dir trigger (custom)" => {
      "pre_condition" => $custom_pre_condition,
      "params" => {
        "http_port"      => 8080,
        "shutdown_port"  => 8088,
        "shared_lib_dir" => $custom_shared_lib_dir,
      },
      "subscribe" => $custom_shared_lib_trigger,
    },
    "service restart endorsed_lib_dir trigger (default)" => {
      "params" => {
        "http_port"      => 8080,
        "shutdown_port"  => 8088,
      },
      "subscribe" => $def_endorsed_lib_trigger,
    },
    "service restart endorsed_lib_dir trigger (off)" => {
      "params" => {
        "http_port"        => 8080,
        "shutdown_port"    => 8088,
        "endorsed_lib_dir" => false,
      },
      "no_subscribe" => $def_endorsed_lib_trigger,
    },
    "service restart endorsed_lib_dir trigger (custom)" => {
      "pre_condition" => $custom_pre_condition,
      "params" => {
        "http_port"        => 8080,
        "shutdown_port"    => 8088,
        "endorsed_lib_dir" => $custom_endorsed_lib_dir,
      },
      "subscribe" => $custom_endorsed_lib_trigger,
    },
    "service restart java_home trigger (default)" => {
      "pre_condition" => $def_java_pre_condition,
      "params" => {
        "http_port"     => 8080,
        "shutdown_port" => 8088,
        "watch_java"    => true,
      },
      "subscribe" => $def_java,
    },
    "service restart java_home trigger (custom/unmanaged)" => {
      "pre_condition" => $custom_java_pre_condition,
      "params" => {
        "http_port"     => 8080,
        "shutdown_port" => 8088,
        "java_home"     => $custom_java,
        "watch_java"    => true,
      },
      "subscribe" => $custom_java,
    },
    "service restart java_home trigger (off)" => {
      "pre_condition" => $def_java_pre_condition,
      "params" => {
        "http_port"     => 8080,
        "shutdown_port" => 8088,
        "watch_java"    => false,
      },
      "no_subscribe" => $def_java,
    },
    "service restart catalina_home trigger (default)" => {
      "pre_condition" => $def_tomcat_pre_condition,
      "params" => {
        "http_port"        => 8080,
        "shutdown_port"    => 8088,
        "watch_tomcat"     => true,
      },
      "subscribe" => $def_tomcat,
    },
    "service restart catalina_home trigger (off)" => {
      "pre_condition" => $def_tomcat_pre_condition,
      "params" => {
        "http_port"        => 8080,
        "shutdown_port"    => 8088,
        "watch_tomcat"     => false,
      },
      "no_subscribe" => $def_tomcat,
    },
    "service restart catalina_home trigger (off)" => {
      "pre_condition" => $def_tomcat_pre_condition,
      "params" => {
        "http_port"        => 8080,
        "shutdown_port"    => 8088,
        "watch_tomcat"     => false,
      },
      "no_subscribe" => $def_tomcat,
    },
    "service restart catalina_home trigger (custom)" => {
      "pre_condition" => $custom_tomcat_pre_condition,
      "params" => {
        "http_port"        => 8080,
        "shutdown_port"    => 8088,
        "catalina_home"    => $custom_tomcat,
        "watch_tomcat"     => true,
      },
      "subscribe" => $custom_tomcat,
    },
  }

  tests.each do | test_name, test_data | 
    context test_name do
      let :pre_condition do
        test_data.has_key?("pre_condition") ? 
          test_data["pre_condition"] : $def_pre_condition
      end
      let :title do
        $default_title
      end
      let :params do
        test_data["params"]
      end
      it {
        if test_data.has_key?("subscribe")
          should contain_service("tomcat_myapp").that_subscribes_to(
            "File[#{test_data["subscribe"]}]"
          )
        elsif test_data.has_key?("no_subscribe")
          should_not contain_service("tomcat_myapp").that_subscribes_to(
            "File[#{test_data["no_subscribe"]}]"
          )
        else
          fail("test #{test_name} should supply subscribe/no_subscribe key")
        end

        # test the built-in files also cause a restart
        [ "/etc/init.d/tomcat_myapp",
          "#{$instances}/myapp/bin/setenv.sh",
          "#{$instances}/myapp/conf/catalina.properties",
          "#{$instances}/myapp/conf/context.xml",
          "#{$instances}/myapp/conf/logging.properties",
          "#{$instances}/myapp/conf/server.xml",
          "#{$instances}/myapp/conf/tomcat-users.xml",
          "#{$instances}/myapp/conf/web.xml" ].each do | subscribed_file |

          should contain_service("tomcat_myapp").that_subscribes_to(
            "File[#{subscribed_file}]"
          )
        end
      }
    end
  end

  #
  # major version
  # 
  context "fail on invalid major version" do
    let :title do
      "myapp"
    end
    let :params do
      {
        "http_port"      => 8080,
        "shutdown_port"  => 8088,
        "major_version"  => "x",
      }
    end
    it {
      expect { should compile }.to raise_error(/module doesn't support major version/)
    }
  end


  #
  # Files and directories
  #
  context "instance_root_dir works" do
    let :title do
      "myapp"
    end
    let :params do
      {
        "http_port"         => 8080,
        "shutdown_port"     => 8088,
        "instance_root_dir" => "/home/tomcat",
      }
    end
    it {
      should contain_file("/home/tomcat/myapp").with(
        "ensure" => "directory",
      )
    }
  end


  context "owners/groups/permissions (default)" do
    let :title do
      "myapp"
    end
    let :params do
      {
        "http_port"     => 8080,
        "shutdown_port" => 8088,
      }
    end
    it {
      # init script
      should contain_file("/etc/init.d/tomcat_myapp").with(
        "ensure" => "file",
        "owner"  => $def_file_owner,
        "group"  => $def_file_group,
        "mode"   => $def_file_mode_init,
      )

      # setenv.sh
      should contain_file("#{$instances}/myapp/bin/setenv.sh").with(
        "ensure" => "file",
        "owner"  => $def_file_owner,
        # needs group set to the owner of the tomcat process so the file
        # can be read and executed but advise against making it world readable
        # by default incase proxy passwords, etc are stored in here...
        "group"  => $def_file_group,
        "mode"   => $def_file_mode_script,
      )
      
      # catalina.properties
      should contain_file("#{$instances}/myapp/conf/catalina.properties").with(
        "ensure" => "file",
        "owner"  => $def_file_owner,
        "group"  => $def_file_group,
        "mode"   => $def_file_mode_regular,
      )

      # context.xml
      should contain_file("#{$instances}/myapp/conf/context.xml").with(
        "ensure" => "file",
        "owner"  => $def_file_owner,
        "group"  => $def_file_group,
        "mode"   => $def_file_mode_regular,
      )
      
      # logging.properties
      should contain_file("#{$instances}/myapp/conf/logging.properties").with(
        "ensure" => "file",
        "owner"  => $def_file_owner,
        "group"  => $def_file_group,
        "mode"   => $def_file_mode_regular,
      )

      # server.xml
      should contain_file("#{$instances}/myapp/conf/server.xml").with(
        "ensure" => "file",
        "owner"  => $def_file_owner,
        "group"  => $def_file_group,
        "mode"   => $def_file_mode_regular,
      )

      # tomcat-users.xml
      should contain_file("#{$instances}/myapp/conf/tomcat-users.xml").with(
        "ensure" => "file",
        "owner"  => $def_file_owner,
        "group"  => $def_file_group,
        "mode"   => $def_file_mode_regular,
      )

      # web.xml
      should contain_file("#{$instances}/myapp/conf/web.xml").with(
        "ensure" => "file",
        "owner"  => $def_file_owner,
        "group"  => $def_file_group,
        "mode"   => $def_file_mode_regular,
      )

      # /bin (ro)
      should contain_file("#{$instances}/myapp/bin").with(
        "ensure" => "directory",
        "owner"  => $def_file_owner,
        "group"  => $def_file_group,
        "mode"   => $def_file_mode_regular,
      )

      # /conf (ro)
      should contain_file("#{$instances}/myapp/conf").with(
        "ensure" => "directory",
        "owner"  => $def_file_owner,
        "group"  => $def_file_group,
        "mode"   => $def_file_mode_regular,
      )

      # /lib (ro)
      should contain_file("#{$instances}/myapp/lib").with(
        "ensure" => "directory",
        "owner"  => $def_file_owner,
        "group"  => $def_file_group,
        "mode"   => $def_file_mode_regular,
      )

      # /logs (rw)
      should contain_file("#{$instances}/myapp/logs").with(
        "ensure" => "directory",
        "owner"  => $def_instance_user,
        "group"  => $def_instance_user,
        "mode"   => $def_file_mode_regular,
      )
      # /run (rw)
      should contain_file("#{$instances}/myapp/run").with(
        "ensure" => "directory",
        "owner"  => $def_instance_user,
        "group"  => $def_instance_user,
        "mode"   => $def_file_mode_regular,
      )

      # /temp (rw)
      should contain_file("#{$instances}/myapp/temp").with(
        "ensure" => "directory",
        "owner"  => $def_instance_user,
        "group"  => $def_instance_user,
        "mode"   => $def_file_mode_regular,
      )

      # /webapps (rw)
      should contain_file("#{$instances}/myapp/webapps").with(
        "ensure" => "directory",
        "owner"  => $def_instance_user,
        "group"  => $def_instance_user,
        "mode"   => $def_file_mode_regular,
      )

      # /work (rw)
      should contain_file("#{$instances}/myapp/work").with(
        "ensure" => "directory",
        "owner"  => $def_instance_user,
        "group"  => $def_instance_user,
        "mode"   => $def_file_mode_regular,
      )
    }
  end
  context "owners/groups/permissions (custom)" do
    let :title do
      "myapp"
    end
    let :params do
      {
        "http_port"         => 8080,
        "shutdown_port"     => 8088,
        "file_owner"        => $custom_file_owner,
        "file_group"        => $custom_file_group,
        "instance_user"     => $custom_instance_user,
        "file_mode_init"    => $custom_file_mode_init,
        "file_mode_regular" => $custom_file_mode_regular,
        "file_mode_script"  => $custom_file_mode_script,
      }
    end
    it {
      # file should always be owned by root even if user set to tomcat. reason:
      # don't allow user to have init scripts owned by non-root
      should contain_file("/etc/init.d/tomcat_myapp").with(
        "ensure" => "file",
        "owner"  => $def_file_owner,
        "group"  => $custom_file_group,
        "mode"   => $custom_file_mode_init,
      )

      # setenv.sh
      should contain_file("#{$instances}/myapp/bin/setenv.sh").with(
        "ensure" => "file",
        "owner"  => $custom_file_owner,
        "group"  => $custom_file_group,
        "mode"   => $custom_file_mode_script,
      )

      # catalina.properties
      should contain_file("#{$instances}/myapp/conf/catalina.properties").with(
        "ensure" => "file",
        "owner"  => $custom_file_owner,
        "group"  => $custom_file_group,
        "mode"   => $custom_file_mode_regular,
      )

      # context.xml
      should contain_file("#{$instances}/myapp/conf/context.xml").with(
        "ensure" => "file",
        "owner"  => $custom_file_owner,
        "group"  => $custom_file_group,
        "mode"   => $custom_file_mode_regular,
      )

      # logging.properties
      should contain_file("#{$instances}/myapp/conf/logging.properties").with(
        "ensure" => "file",
        "owner"  => $custom_file_owner,
        "group"  => $custom_file_group,
        "mode"   => $custom_file_mode_regular,
      )

      # server.xml
      should contain_file("#{$instances}/myapp/conf/server.xml").with(
        "ensure" => "file",
        "owner"  => $custom_file_owner,
        "group"  => $custom_file_group,
        "mode"   => $custom_file_mode_regular,
      )

      # tomcat-users.xml
      should contain_file("#{$instances}/myapp/conf/tomcat-users.xml").with(
        "ensure" => "file",
        "owner"  => $custom_file_owner,
        "group"  => $custom_file_group,
        "mode"   => $custom_file_mode_regular,
      )

      # web.xml
      should contain_file("#{$instances}/myapp/conf/web.xml").with(
        "ensure" => "file",
        "owner"  => $custom_file_owner,
        "group"  => $custom_file_group,
        "mode"   => $custom_file_mode_regular,
      )

      # /bin (ro)
      should contain_file("#{$instances}/myapp/bin").with(
        "ensure" => "directory",
        "owner"  => $custom_file_owner,
        "group"  => $custom_file_group,
        "mode"   => $custom_file_mode_regular,
      )

      # /conf (ro)
      should contain_file("#{$instances}/myapp/conf").with(
        "ensure" => "directory",
        "owner"  => $custom_file_owner,
        "group"  => $custom_file_group,
        "mode"   => $custom_file_mode_regular,
      )

      # /lib (ro)
      should contain_file("#{$instances}/myapp/lib").with(
        "ensure" => "directory",
        "owner"  => $custom_file_owner,
        "group"  => $custom_file_group,
        "mode"   => $custom_file_mode_regular,
      )

      # /logs (rw)
      should contain_file("#{$instances}/myapp/logs").with(
        "ensure" => "directory",
        "owner"  => $custom_instance_user,
        "group"  => $custom_instance_group,
        "mode"   => $custom_file_mode_regular,
      )
      # /run (rw)
      should contain_file("#{$instances}/myapp/run").with(
        "ensure" => "directory",
        "owner"  => $custom_instance_user,
        "group"  => $custom_instance_group,
        "mode"   => $custom_file_mode_regular,
      )

      # /temp (rw)
      should contain_file("#{$instances}/myapp/temp").with(
        "ensure" => "directory",
        "owner"  => $custom_instance_user,
        "group"  => $custom_instance_group,
        "mode"   => $custom_file_mode_regular,
      )

      # /webapps (rw)
      should contain_file("#{$instances}/myapp/webapps").with(
        "ensure" => "directory",
        "owner"  => $custom_instance_user,
        "group"  => $custom_instance_group,
        "mode"   => $custom_file_mode_regular,
      )

      # /work (rw)
      should contain_file("#{$instances}/myapp/work").with(
        "ensure" => "directory",
        "owner"  => $custom_instance_user,
        "group"  => $custom_instance_group,
        "mode"   => $custom_file_mode_regular,
      )
    }
  end


  #
  # duplicate tcp port protection
  #
  context "failure on attempt to reallocate used tcp port" do
    let :title do
      "myapp"
    end
    let :params do 
      {
        "http_port"     => 8888,
        "shutdown_port" => 8888,
        "https_port"    => 8888,
        "jmx_port"      => 8888,
      }
    end
    it {
      expect { should compile }.to raise_error(/Duplicate declaration: Tomcat::Port/)
    }
  end
    
  # 
  # Template file contents
  # 
  tests = {

    #
    # init script
    #
    "provides (chkconfig) set in template" => {
      "file"   => "/etc/init.d/tomcat_myapp",
      "regexp" => /# Provides: tomcat_myapp/,
    },
    "description (chkconfig) set in template" => {
      "file"   => "/etc/init.d/tomcat_myapp",
      "regexp" => /init script for myapp/,
    },
    "INSTANCE_NAME (default)" => {
      "file"   => "/etc/init.d/tomcat_myapp",
      "regexp" => /export INSTANCE_NAME="myapp"/,
    },
    "CATALINA_BASE (default)" => {
      "file"   => "/etc/init.d/tomcat_myapp",
      "regexp" => /export CATALINA_BASE="#{$instances}\/myapp"/,
    },
    "CATALINA_BASE (custom)" => {
      "file"   => "/etc/init.d/tomcat_myapp",
      "params" => {
        "instance_root_dir" => "/home/tomcat",
      },
      "regexp" => /export CATALINA_BASE="\/home\/tomcat\/myapp"/,
    },
    "CATALINA_HOME (default)" => {
      "file"   => "/etc/init.d/tomcat_myapp",
      "regexp" => /export CATALINA_HOME="#{$def_tomcat}/,
    },
    "CATALINA_HOME (custom)" => {
      "file"   => "/etc/init.d/tomcat_myapp",
      "params" => {
        "catalina_home" => "/foobar",
      },
      "regexp" => /export CATALINA_HOME="\/foobar"/,
    },
    "PROCESS_OWNER (default)" => {
      "file"   => "/etc/init.d/tomcat_myapp",
      "regexp" => /PROCESS_OWNER="tomcat"/,
    },
    "PROCESS_OWNER (custom)" => {
      "file"   => "/etc/init.d/tomcat_myapp",
      "params" => {
        "instance_user" => "foobar",
      },
      "regexp" => /PROCESS_OWNER="foobar"/,
    },
    "CATALINA_PID (default)" => {
      "file"   => "/etc/init.d/tomcat_myapp",
      "regexp" =>  /export CATALINA_PID="#{$instances}\/myapp\/run\/myapp\.pid"/,
    },
    "CATALINA_PID (custom)" => {
      "file"   => "/etc/init.d/tomcat_myapp",
      "params" => {
        "pid_file" => "/foobar",
      },
      "regexp" =>  /export CATALINA_PID="\/foobar"/,
    },

    #
    # server.xml
    #
    "shutdown port (custom)" => {
      "file"   => "#{$instances}/myapp/conf/server.xml",
      "params" => {
        "shutdown_port" => 1234,
      },
      "regexp" => /<Server port="1234" shutdown="SHUTDOWN">/,
    },
    "http port set (custom)" => {
      "file"   => "#{$instances}/myapp/conf/server.xml",
      "params" => {
        "http_port"     => 1234,
      },
      "regexp" => /<Connector port="1234" protocol="HTTP\/1\.1"/,
    },
    "unpack_wars = true (custom)" => {
      "file"   => "#{$instances}/myapp/conf/server.xml",
      "params" => {
        "unpack_wars" => true,
      },
      "regexp" => /unpackWARs="true"/,
    },
    "unpack_wars = false (custom)" => {
      "file"   => "#{$instances}/myapp/conf/server.xml",
      "params" => {
        "unpack_wars" => false,
      },
      "regexp" => /unpackWARs="false"/,
    },
    "auto_deploy = true (custom)" => {
      "file"   => "#{$instances}/myapp/conf/server.xml",
      "params" => {
        "auto_deploy" => true,
      },
      "regexp" => /autoDeploy="true"/,
    },
    "auto_deploy = false (custom)" => {
      "file"   => "#{$instances}/myapp/conf/server.xml",
      "params" => {
        "auto_deploy" => false,
      },
      "regexp" => /autoDeploy="false"/,
    },
    "server_xml_jdbc (custom)" => {
      "file"   => "#{$instances}/myapp/conf/server.xml",
      "params" => {
        "server_xml_jdbc" => "<jdbc>",
      },
      "regexp" => /<jdbc>/,
    },
    "https_port (custom/on)" => {
      "file"   => "#{$instances}/myapp/conf/server.xml",
      "params" => {
        "https_port" => "4444",
      },
      "regexp" => /<Connector port="4444"/,
    },
    "https_port (custom attributes)" => {
      "file"   => "#{$instances}/myapp/conf/server.xml",
      "params" => {
        "https_port"       => "4444",
        "https_attributes" => "foobar",
      },
      "regexp" => /<Connector port="4444" foobar \/>/,
    },
    "ajp_port (default/off)" => {
      "file"   => "#{$instances}/myapp/conf/server.xml",
      "inv_regexp" => /protocol="AJP\/1\.3"/,
    },
    "ajp_port (custom/on)" => {
      "file"   => "#{$instances}/myapp/conf/server.xml",
      "params" => {
        "ajp_port" => "8888",
      },
      "regexp" => /<Connector port="8888" protocol="AJP\/1\.3" redirectPort="8443" \/>/,
    },

    #
    # setenv.sh
    #
    "JAVA_HOME (custom)" => {
      "file"   => "#{$instances}/myapp/bin/setenv.sh",
      "regexp" => /export JAVA_HOME="\/usr\/java\/default"/,
    },
    "JAVA_HOME (custom)" => {
      "file"   => "#{$instances}/myapp/bin/setenv.sh",
      "params" => {
        "java_home" => "/foobar",
      },
      "regexp" => /export JAVA_HOME="\/foobar"/,
    },
    "JAVA_OPTS (default)" => {
      "file"   => "#{$instances}/myapp/bin/setenv.sh",
      "regexp" => /export JAVA_OPTS=""/,
    },
    "JAVA_OPTS (custom)" => {
      "file"   => "#{$instances}/myapp/bin/setenv.sh",
      "params" => {
        "java_opts" => "foobar",
      },
      "regexp" => /export JAVA_OPTS="foobar"/,
    },
    "CATALINA_OUT (default)" => {
      "file"   => "#{$instances}/myapp/bin/setenv.sh",
      "regexp" => /export CATALINA_OUT="#{$instances}\/myapp\/logs\/catalina\.out"/,
    },
    "CATALINA_OUT (custom log_dir)" => {
      "file"   => "#{$instances}/myapp/bin/setenv.sh",
      "params" => {
        "log_dir" => "/foobar",
      },
      "regexp" => /export CATALINA_OUT="\/foobar\/catalina\.out"/,
    },
    "CATALINA_OPTS_JMX (defalt off)" => {
      "file"       => "#{$instances}/myapp/bin/setenv.sh",
      "inv_regexp" => /CATALINA_OPTS_JMX="/,
    },
    "CATALINA_OPTS_JMX jmxremote.port (custom/active)" => {
      "file"   => "#{$instances}/myapp/bin/setenv.sh",
      "params" => {
        "jmx_port" => 6666,
      },
      "regexp" => /-Dcom\.sun\.management\.jmxremote\.port=6666/,
    },
    "CATALINA_OPTS_JMX jmxremote.ssl (default off)" => {
      "file"   => "#{$instances}/myapp/bin/setenv.sh",
      "params" => {
        "jmx_port" => 6666,
      },
      "regexp" => /-Dcom.sun.management.jmxremote.ssl=false/,
    },
    "CATALINA_OPTS_JMX jmxremote.ssl (custom on)" => {
      "file"   => "#{$instances}/myapp/bin/setenv.sh",
      "params" => {
        "jmx_port" => 6666,
        "jmx_ssl"  => true,
      },
      "regexp" => /-Dcom\.sun\.management\.jmxremote\.ssl=true/,
    },
    "CATALINA_OPTS_JMX jmxremote.authenticate (default off)" => {
      "file"   => "#{$instances}/myapp/bin/setenv.sh",
      "params" => {
        "jmx_port"          => 6666,
      },
      "regexp" => /-Dcom\.sun\.management\.jmxremote\.authenticate=false/,
    },
    "CATALINA_OPTS_JMX jmxremote.authenticate (default off)" => {
      "file"   => "#{$instances}/myapp/bin/setenv.sh",
      "params" => {
        "jmx_port"          => 6666,
        "jmx_authenticate"  => true,
      },
      "regexp" => /-Dcom\.sun\.management\.jmxremote\.authenticate=true/,
    },
    "CATALINA_OPTS_JMX jmxremote.password.file (default blank)" => {
      "file"   => "#{$instances}/myapp/bin/setenv.sh",
      "params" => {
        "jmx_port" => 6666,
      },
      "regexp" => /-Dcom\.sun\.management\.jmxremote\.password\.file= \\$/,
    },
    "CATALINA_OPTS_JMX jmxremote.password.file (custom)" => {
      "file"   => "#{$instances}/myapp/bin/setenv.sh",
      "params" => {
        "jmx_port"          => 6666,
        "jmx_password_file" => "/foobar",
      },
      "regexp" => /-Dcom\.sun\.management\.jmxremote\.password\.file=\/foobar/,
    },
    "CATALINA_OPTS_JMX jmxremote.access.file (default blank)" => {
      "file"   => "#{$instances}/myapp/bin/setenv.sh",
      "params" => {
        "jmx_port" => 6666,
      },
      "regexp" => /-Dcom\.sun\.management\.jmxremote\.access\.file= \\$/,
    },
    "CATALINA_OPTS_JMX jmxremote.access.file (custom)" => {
      "file"   => "#{$instances}/myapp/bin/setenv.sh",
      "params" => {
        "jmx_port"          => 6666,
        "jmx_access_file" => "/foobar",
      },
      "regexp" => /-Dcom\.sun\.management\.jmxremote\.access\.file=\/foobar/,
    },
    "CATALINA_OPTS (default)" => {
      "file"   => "#{$instances}/myapp/bin/setenv.sh",
      "regexp" => /CATALINA_OPTS_CFG=""/,
    },
    "CATALINA_OPTS (custom)" => {
      "file"   => "#{$instances}/myapp/bin/setenv.sh",
      "params" => {
        "catalina_opts" => "foobar",
      },
      "regexp" => /CATALINA_OPTS_CFG="foobar"/,
    },
    "JAVA_ENDORSED_DIRS (default on)" => {
      "file"   => "#{$instances}/myapp/bin/setenv.sh",
      "regexp" => /export JAVA_ENDORSED_DIRS="\/usr\/local\/lib\/tomcat_endorsed"/,
    },
    "JAVA_ENDORSED_DIRS (set off)" => {
      "file"   => "#{$instances}/myapp/bin/setenv.sh",
      "params" => {
        "endorsed_lib_dir" => false,
      },
      "inv_regexp" => /export JAVA_ENDORSED_DIRS/,
    },
    "JAVA_ENDORSED_DIRS (set custom)" => {
      "file"   => "#{$instances}/myapp/bin/setenv.sh",
      "params" => {
        "endorsed_lib_dir" => "/foobar",
      },
      "regexp" => /export JAVA_ENDORSED_DIRS="\/foobar"/,
    },
    "tomcat_extra_setenv (set)" => {
      "file"   => "#{$instances}/myapp/bin/setenv.sh",
      "params" => {
        "tomcat_extra_setenv_args" => "foobar",
      },
      "regexp" => /^foobar$/,
    },

    #
    # context.xml
    #
    "jdbc xml fragment in template" => {
      "file"   => "#{$instances}/myapp/conf/context.xml",
      "params" => {
        "context_xml_jdbc" => "<jdbc>",
      },
      "regexp" => /<jdbc>/,
    },

    #
    # logging.properties
    #
    "1catalina.org.apache.juli.FileHandler.directory (default)" => {
      "file"   => "#{$instances}/myapp/conf/logging.properties",
      "regexp" =>
        /1catalina\.org\.apache\.juli\.FileHandler\.directory = #{$instances}\/myapp\/logs/,
    },
    "2localhost.org.apache.juli.FileHandler.directory (default)" => {
      "file"   => "#{$instances}/myapp/conf/logging.properties", 
      "regexp" => 
        /2localhost\.org\.apache\.juli\.FileHandler\.directory = #{$instances}\/myapp\/logs/,
    },
    "3manager.org.apache.juli.FileHandler.directory (default)" => {
      "file"   => "#{$instances}/myapp/conf/logging.properties",
      "regexp" => 
        /3manager\.org\.apache\.juli\.FileHandler\.directory = #{$instances}\/myapp\/logs/,
    },
    "4host-manager.org.apache.juli.FileHandler.directory (default)" => {
      "file"   => "#{$instances}/myapp/conf/logging.properties",
      "regexp" => 
        /4host-manager\.org\.apache\.juli\.FileHandler\.directory = #{$instances}\/myapp\/logs/,
    },
    "1catalina.org.apache.juli.FileHandler.directory (custom)" => {
      "file"   => "#{$instances}/myapp/conf/logging.properties",
      "params" => {
        "log_dir" => "/foobar",
      },
      "regexp" =>
        /1catalina\.org\.apache\.juli\.FileHandler\.directory = \/foobar/,
    },
    "2localhost.org.apache.juli.FileHandler.directory (custom)" => {
      "file"   => "#{$instances}/myapp/conf/logging.properties",
      "params" => {
        "log_dir" => "/foobar",
      },
      "regexp" =>
        /2localhost\.org\.apache\.juli\.FileHandler\.directory = \/foobar/,
    },
    "3manager.org.apache.juli.FileHandler.directory (custom)" => {
      "file"   => "#{$instances}/myapp/conf/logging.properties",
      "params" => {
        "log_dir" => "/foobar",
      },
      "regexp" =>
        /3manager\.org\.apache\.juli\.FileHandler\.directory = \/foobar/,
    },
    "4host-manager.org.apache.juli.FileHandler.directory (custom)" => {
      "file"   => "#{$instances}/myapp/conf/logging.properties",
      "params" => {
        "log_dir" => "/foobar",
      },
      "regexp" =>
        /4host-manager\.org\.apache\.juli\.FileHandler\.directory = \/foobar/,
    },

    #
    # catalina.properties
    #
    "common.loader (default)" => {
      "file"   => "#{$instances}/myapp/conf/catalina.properties",
      "regexp" =>
        /common.loader=\${catalina\.base}\/lib,\${catalina\.base}\/lib\/\*\.jar,\/usr\/local\/lib\/tomcat_shared,\/usr\/local\/lib\/tomcat_shared\/\*\.jar,\${catalina\.home}\/lib,\${catalina\.home}\/lib\/\*\.jar/,
    },
    "common.loader (shared_lib_dir off)" => {
      "file"   => "#{$instances}/myapp/conf/catalina.properties",
      "params" => {
        "shared_lib_dir" => false,
      },
      "regexp" => 
        /common.loader=\${catalina\.base}\/lib,\${catalina\.base}\/lib\/\*\.jar,\${catalina\.home}\/lib,\${catalina\.home}\/lib\/\*\.jar/,
    },
    "common.loader (shared_lib_dir custom)" => {
      "file"   => "#{$instances}/myapp/conf/catalina.properties",
      "params" => {
        "shared_lib_dir" => "/foobar",
      },
      "regexp" =>
        /common.loader=\${catalina\.base}\/lib,\${catalina\.base}\/lib\/\*\.jar,\/foobar,\/foobar\/\*\.jar,\${catalina\.home}\/lib,\${catalina\.home}\/lib\/\*\.jar/,
    },
    "catalina_properties_extra_args (custom)" => {
      "file"   => "#{$instances}/myapp/conf/catalina.properties",
      "params" => {
        "catalina_properties_extra_args" => "foobar",
      },
      "regexp" => /^foobar$/,
    },

    # skip tomcat-users.xml (no variables)
    # skip web.xml (no variables)

  }

  # process each test from the above hash
  tests.each do | test_name, test_data |
    context test_name do
      let :title do
        test_data["title"] ? test_data["title"] : $default_title
      end
      let :params do
        $default_params.merge(test_data["params"] ? test_data["params"] : {})
      end
      it {
        if test_data.has_key?("regexp") 
          # test regexp present
          should contain_file(test_data["file"]).with_content(
            test_data["regexp"]
          )
        elsif test_data.has_key?("inv_regexp")
          # test regexp not present
          should contain_file(test_data["file"]).without_content(
            test_data["inv_regexp"]
          )
        else
          # test fail - nothing to test
          fail("missing regexp/inv_regexp for test: #{test_name}")
        end
      }
    end
  end
  
  #
  # custom templates
  #
  template_param_name = [ "init_script_template", 
                          "setenv_sh_template",
                          "server_xml_template",
                          "catalina_properties_template",
                          "tomcat_users_xml_template",
                          "web_xml_template",]


  # test that each custom template is usable by attempting to load from a 
  # non-existant template and checking that the requested template name shows
  # up in the missing template file error message we expect
  template_param_name.each do | param_name |
    context "test custom template via #{param_name}" do
      let :title do
        $default_title
      end
      let :params do 
        $default_params.merge({param_name => "/not_here"})
      end
      it {
        expect { should compile }.to raise_error(/No such file or directory - \/not_here/)
      }
    end
  end

end
