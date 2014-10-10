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
                "ensure" => true,
                "enable" => true,
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
                "ensure" => true,
                "enable" => true,
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
                "ensure" => false,
                "enable" => true,
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
                "ensure" => true,
                "enable" => false,
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
                "ensure" => true,
                "enable" => true,
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
    instance_subdirs = ["bin",
                        "common",
                        "conf",
                        "Catalina",
                        "keystore",
                        "lib",
                        "logs",
                        "server",
                        "shared",
                        "temp",
                        "webapps",
                        "work"]

    instance_subdirs.each do | dir |

        context "instance subdir '#{dir}' created" do
            let :title do
                "myapp"
            end
            let :params do
                {
                    "instance_subdirs" => instance_subdirs
                }
            end
            it {
                should contain_file(
                    "/var/tomcat/instances/myapp/#{dir}",
                ).with(
                    "ensure" => "directory",
                )
            }
        end
    end
end
