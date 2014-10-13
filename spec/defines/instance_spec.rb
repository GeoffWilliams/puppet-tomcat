require 'spec_helper'

instances = "/var/tomcat/instances"

describe 'tomcat::instance', :type => :define do

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
                    "#{instances}/myapp/bin/startup.sh",
                    "#{instances}/myapp/bin/shutdown.sh",
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

  #
  # server.xml
  #

  # shutdown
  context "shutdown port set correctly in template" do
    let :title do
      "myapp"
    end
    let :params do
      {
        "http_port"     => 8080,
        "shutdown_port" => 1234,
      }
    end
    it {
      should contain_file("#{instances}/myapp/conf/server.xml").with_content(
        /<Server port="1234" shutdown="SHUTDOWN">/
      )
    }
  end

  # http_port
  context "http port set correctly in template" do
    let :title do
      "myapp"
    end
    let :params do
      {
        "http_port"     => 1234,
        "shutdown_port" => 8088,
      }
    end
    it {
      should contain_file("#{instances}/myapp/conf/server.xml").with_content(
        /<Connector port="1234" protocol="HTTP\/1\.1"/
      )
    }
  end

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
        "auto_deploy"    => true,
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

end
