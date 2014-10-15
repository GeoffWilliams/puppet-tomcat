require 'spec_helper'

instances = "/var/lib/tomcat"

describe 'tomcat::instance', :type => :define do
  let :pre_condition do
    'class { "tomcat": }'
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
        "ensure"        => false,
        "enable"        => true,
        "http_port"     => 8080,
        "shutdown_port" => 8088,
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
        "ensure"        => true,
        "enable"        => false,
        "http_port"     => 8080,
        "shutdown_port" => 8088,
      }
    end
    it {
      should contain_service("tomcat_myapp").with(
        "ensure" => true,
        "enable" => false,
      )
    }
  end

  #
  # init script
  #
  context "init script created" do
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
      should contain_file("/etc/init.d/tomcat_myapp").with(
        "ensure" => "file",
        "owner"  => "root",
        "group"  => "root",
        "mode"   => "0755",
      )
    }
  end

  #
  # Directory structure
  #
   instance_subdirs = [ "/bin",
                        "/common",
                        "/conf",
                        "/Catalina",
                        "/keystore",
                        "/lib",
                        "/logs",
                        "/server",
                        "/shared",
                        "/temp",
                        "/webapps",
                        "/work"]

  instance_subdirs.each do | dir |

    context "instance subdir '#{dir}' created" do
      let :title do
        "myapp"
      end
      let :params do
        {
          "instance_subdirs" => instance_subdirs,
          "http_port"        => 8080,
          "shutdown_port"    => 8088,
        }
      end
      it {
        should contain_file(
          "#{instances}/myapp#{dir}",
        ).with(
          "ensure" => "directory",
        )
      }
    end
  end

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
      expect { should compile }.to raise_error(Puppet::Error, /Duplicate declaration: Tomcat::Port/)
    }
  end
    
  #
  # Instance files (excludes init script - already checked)
  #
  instance_files = ["#{instances}/myapp/bin/setenv.sh",
                    "#{instances}/myapp/conf/server.xml",
                    "#{instances}/myapp/conf/catalina.properties",
                    "#{instances}/myapp/conf/context.xml",
                    "#{instances}/myapp/conf/logging.properties",
                    "#{instances}/myapp/conf/tomcat-users.xml",
                    "#{instances}/myapp/conf/web.xml"]

  instance_files.each do | file |
    context "check file #{file} created" do

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
        should contain_file(file).with(
          "ensure" => "file",
        )
      }
    end
  end

  # 
  # Template file contents
  # 
  default_params = {
    "http_port"     => 8080,
    "shutdown_port" => 8088,
  }
  default_title = "myapp"

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
    "INSTANCE_NAME set in template" => {
      "file"   => "/etc/init.d/tomcat_myapp",
      "regexp" => /export INSTANCE_NAME="myapp"/,
    },
    "CATALINA_BASE set in template" => {
      "file"   => "/etc/init.d/tomcat_myapp",
      "regexp" => /export CATALINA_BASE="\/var\/lib\/tomcat\/myapp"/,
    },
    "CATALINA_HOME set in template" => {
      "file"   => "/etc/init.d/tomcat_myapp",
      "regexp" => /export CATALINA_HOME="\/usr\/local\/apache-tomcat-7\.0\.56"/,
    },
    "PROCESS_OWNER set in template" => {
      "file"   => "/etc/init.d/tomcat_myapp",
      "regexp" => /PROCESS_OWNER="tomcat"/,
    },
    "CATALINA_PID set in template" => {
      "file"   => "/etc/init.d/tomcat_myapp",
      "regexp" =>  /export CATALINA_PID="\/var\/run\/tomcat\/myapp\.pid"/,
    },

    #
    # server.xml
    #
    "shutdown port set correctly in template" => {
      "file"   => "#{instances}/myapp/conf/server.xml",
      "params" => {
        "shutdown_port" => 1234,
      },
      "regexp" => /<Server port="1234" shutdown="SHUTDOWN">/,
    },
    "http port set correctly in template" => {
      "file"   => "#{instances}/myapp/conf/server.xml",
      "params" => {
        "http_port"     => 1234,
      },
      "regexp" => /<Connector port="1234" protocol="HTTP\/1\.1"/,
    },
    "unpack_wars = true set correctly in template" => {
      "file"   => "#{instances}/myapp/conf/server.xml",
      "params" => {
        "unpack_wars" => true,
      },
      "regexp" => /unpackWARs="true"/,
    },
    "unpack_wars = false set correctly in template" => {
      "file"   => "#{instances}/myapp/conf/server.xml",
      "params" => {
        "unpack_wars" => false,
      },
      "regexp" => /unpackWARs="false"/,
    },
    "auto_deploy = true set correctly in template" => {
      "file"   => "#{instances}/myapp/conf/server.xml",
      "params" => {
        "auto_deploy" => true,
      },
      "regexp" => /autoDeploy="true"/,
    },
    "auto_deploy = false set correctly in template" => {
      "file"   => "#{instances}/myapp/conf/server.xml",
      "params" => {
        "auto_deploy" => false,
      },
      "regexp" => /autoDeploy="false"/,
    },

    #
    # setenv.sh
    #
    "JAVA_HOME set correctly in template" => {
      "file"   => "#{instances}/myapp/bin/setenv.sh",
      "params" => {
        "java_home" => "foobar",
      },
      "regexp" => /export JAVA_HOME="foobar"/,
    },
    "JAVA_OPTS set correctly in template" => {
      "file"   => "#{instances}/myapp/bin/setenv.sh",
      "params" => {
        "java_opts" => "foobar",
      },
      "regexp" => /export JAVA_OPTS="foobar"/,
    },
    "CATALINA_OPTS set correctly in template" => {
      "file"   => "#{instances}/myapp/bin/setenv.sh",
      "params" => {
        "catalina_opts" => "foobar",
      },
      "regexp" => /export CATALINA_OPTS="foobar"/,
    },

    #
    # context.xml
    #
    "jdbc xml fragment in template" => {
      "file"   => "#{instances}/myapp/conf/context.xml",
      "params" => {
        "context_xml_jdbc" => "<jdbc>",
      },
      "regexp" => /<jdbc>/,
    },

    #
    # logging.properties
    #
    "1catalina.org.apache.juli.FileHandler.directory set via default" => {
      "file"   => "#{instances}/myapp/conf/logging.properties",
      "regexp" =>
        /1catalina\.org\.apache\.juli\.FileHandler\.directory = \/var\/log\/tomcat\/myapp/,
    },
    "2localhost.org.apache.juli.FileHandler.directory set via default" => {
      "file"   => "#{instances}/myapp/conf/logging.properties", 
      "regexp" => 
        /2localhost\.org\.apache\.juli\.FileHandler\.directory = \/var\/log\/tomcat\/myapp/,
    },
    "3manager.org.apache.juli.FileHandler.directory set via default" => {
      "file"   => "#{instances}/myapp/conf/logging.properties",
      "regexp" => 
        /3manager\.org\.apache\.juli\.FileHandler\.directory = \/var\/log\/tomcat\/myapp/,
    },
    "4host-manager.org.apache.juli.FileHandler.directory set via default" => {
      "file"   => "#{instances}/myapp/conf/logging.properties",
      "regexp" => 
        /4host-manager\.org\.apache\.juli\.FileHandler\.directory = \/var\/log\/tomcat\/myapp/,
    },
    "1catalina.org.apache.juli.FileHandler.directory set via param" => {
      "file"   => "#{instances}/myapp/conf/logging.properties",
      "params" => {
        "log_dir" => "foobar",
      },
      "regexp" =>
        /1catalina\.org\.apache\.juli\.FileHandler\.directory = foobar/,
    },
    "2localhost.org.apache.juli.FileHandler.directory set via param" => {
      "file"   => "#{instances}/myapp/conf/logging.properties",
      "params" => {
        "log_dir" => "foobar",
      },
      "regexp" =>
        /2localhost\.org\.apache\.juli\.FileHandler\.directory = foobar/,
    },
    "3manager.org.apache.juli.FileHandler.directory set via param" => {
      "file"   => "#{instances}/myapp/conf/logging.properties",
      "params" => {
        "log_dir" => "foobar",
      },
      "regexp" =>
        /3manager\.org\.apache\.juli\.FileHandler\.directory = foobar/,
    },
    "4host-manager.org.apache.juli.FileHandler.directory set via param" => {
      "file"   => "#{instances}/myapp/conf/logging.properties",
      "params" => {
        "log_dir" => "foobar",
      },
      "regexp" =>
        /4host-manager\.org\.apache\.juli\.FileHandler\.directory = foobar/,
    },


    # skip tomcat-users.xml (no variables)
    # skip web.xml (no variables)

  }

  # process each test from the above hash
  tests.each do | test_name, test_data |
    context test_name do
      let :title do
        test_data["title"] ? test_data["title"] : default_title
      end
      let :params do
        default_params.merge(test_data["params"] ? test_data["params"] : {})
      end
      it {
        should contain_file(test_data["file"]).with_content(
          test_data["regexp"]
        )
      }
    end
  end


end
