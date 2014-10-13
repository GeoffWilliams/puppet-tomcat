require 'spec_helper'
describe 'tomcat::instance', :type => :define do

  #
  # service
  #
  context "service ensure=>true; enable=>true" do
    let :title do
      "myapp"
    end
    let :params do 
      {
        "ensure"        => true,
        "enable"        => true,
        "http_port"     => 8080,
        "shutdown_port" => 8088,
      }
    end
    it {
      should contain_service("tomcat_myapp").with(
        "ensure" => true,
        "enable" => true,
      )
    }
  end
    
  context "service ensure=>true; enable=>true" do
    let :title do
      "myapp"
    end
    let :params do
      {
        "ensure"        => true,
        "enable"        => true,
        "http_port"     => 8080,
        "shutdown_port" => 8088,
      }
    end
    it {
      should contain_service("tomcat_myapp").with(
        "ensure" => true,
        "enable" => true,
      )
    }
  end
  
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

  context "service ensure=>false; enable=>false" do
    let :title do
      "myapp"
    end
    let :params do
      {
        "ensure"        => true,
        "enable"        => true,
        "http_port"     => 8080,
        "shutdown_port" => 8088,
      }
    end
    it {
      should contain_service("tomcat_myapp").with(
        "ensure" => true,
        "enable" => true,
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
          "/var/tomcat/instances/myapp#{dir}",
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
  instance_files = ["/var/tomcat/instances/myapp/bin/setenv.sh",
                    "/var/tomcat/instances/myapp/bin/startup.sh",
                    "/var/tomcat/instances/myapp/bin/shutdown.sh",
                    "/var/tomcat/instances/myapp/conf/server.xml",
                    "/var/tomcat/instances/myapp/conf/catalina.properties",
                    "/var/tomcat/instances/myapp/conf/context.xml",
                    "/var/tomcat/instances/myapp/conf/logging.properties",
                    "/var/tomcat/instances/myapp/conf/tomcat-users.xml",
                    "/var/tomcat/instances/myapp/conf/web.xml"]

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
end
