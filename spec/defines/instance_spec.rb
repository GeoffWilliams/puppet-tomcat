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
        "http_port"     => 8080,
        "shutdown_port" => 1234,
      },
      "regexp" => /<Server port="1234" shutdown="SHUTDOWN">/,
    },
    "http port set correctly in template" => {
      "file"   => "#{instances}/myapp/conf/server.xml",
      "params" => {
        "http_port"     => 1234,
        "shutdown_port" => 8088,
      },
      "regexp" => /<Connector port="1234" protocol="HTTP\/1\.1"/,
    }
  }

  # process each test from the above hash
  tests.each do | test_name, test_data |
    context test_name do
      let :title do
        test_data["title"] ? test_data["title"] : default_title
      end
      let :params do
        test_data["params"] ? test_data["params"] : default_params
      end
      it {
        should contain_file(test_data["file"]).with_content(
          test_data["regexp"]
        )
      }
    end
  end

#  context "shutdown port set correctly in template" do
#    let :title do
#      "myapp"
#    end
#    let :params do
#      {
#        "http_port"     => 8080,
#        "shutdown_port" => 1234,
#      }
#    end
#    it {
#      should contain_file("#{instances}/myapp/conf/server.xml").with_content(
#        /<Server port="1234" shutdown="SHUTDOWN">/
#      )
#    }
#  end

  # http_port
#  context "http port set correctly in template" do
#    let :title do
#      "myapp"
#    end
#    let :params do
#      {
#        "http_port"     => 1234,
#        "shutdown_port" => 8088,
#      }
#    end
#    it {
#      should contain_file("#{instances}/myapp/conf/server.xml").with_content(
#        /<Connector port="1234" protocol="HTTP\/1\.1"/
#      )
#    }
#  end

  # unpack_wars true
  context "unpack_wars = true set correctly in template" do
    let :title do
      "myapp"
    end
    let :params do
      {
        "http_port"     => 8080,
        "shutdown_port" => 8088,
        "unpack_wars"   => true,
      }
    end
    it {
      should contain_file("#{instances}/myapp/conf/server.xml").with_content(
        /unpackWARs="true"/
      )
    }
  end

  # unpack_wars false
  context "unpack_wars = false set correctly in template" do
    let :title do
      "myapp"
    end
    let :params do
      {
        "http_port"     => 8080,
        "shutdown_port" => 8088,
        "unpack_wars"   => false,
      }
    end
    it {
      should contain_file("#{instances}/myapp/conf/server.xml").with_content(
        /unpackWARs="false"/
      )
    }
  end

  # autodeploy true
  context "auto_deploy = true set correctly in template" do
    let :title do
      "myapp"
    end
    let :params do
      {
        "http_port"     => 8080,
        "shutdown_port" => 8088,
        "auto_deploy"   => true,
      }
    end
    it {
      should contain_file("#{instances}/myapp/conf/server.xml").with_content(
        /autoDeploy="true"/
      )
    }
  end

  # autodeploy false
  context "auto_deploy = false set correctly in template" do
    let :title do
      "myapp"
    end
    let :params do
      {
        "http_port"     => 8080,
        "shutdown_port" => 8088,
        "auto_deploy"    => false,
      }
    end
    it {
      should contain_file("#{instances}/myapp/conf/server.xml").with_content(
        /autoDeploy="false"/
      )
    }
  end

#
# setenv.sh
#

# java_home
  context "JAVA_HOME set correctly in template" do
    let :title do
      "myapp"
    end
    let :params do
      {
        "http_port"     => 8080,
        "shutdown_port" => 8088,
        "java_home"     => "foobar",
      }
    end
    it {
      should contain_file("#{instances}/myapp/bin/setenv.sh").with_content(
        /export JAVA_HOME="foobar"/
      )
    }
  end

# java_opts
  context "JAVA_OPTS set correctly in template" do
    let :title do
      "myapp"
    end
    let :params do
      {
        "http_port"     => 8080,
        "shutdown_port" => 8088,
        "java_opts"     => "foobar",
      }
    end
    it {
      should contain_file("#{instances}/myapp/bin/setenv.sh").with_content(
        /export JAVA_OPTS="foobar"/
      )
    }
  end

# catalina_opts
  context "CATALINA_OPTS set correctly in template" do
    let :title do
      "myapp"
    end
    let :params do
      {
        "http_port"     => 8080,
        "shutdown_port" => 8088,
        "catalina_opts" => "foobar",
      }
    end
    it {
      should contain_file("#{instances}/myapp/bin/setenv.sh").with_content(
        /export CATALINA_OPTS="foobar"/
      )
    }
  end

# catalina_pid


end
