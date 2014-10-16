require 'spec_helper'
describe 'tomcat::install', :type => :define do
  let :pre_condition do
    'class { "tomcat": }'
  end

  context "named package installs" do
    let :title do
      "custom-apache-tomcat-7.0.55-1-1"
    end
    it {
      should contain_package("custom-apache-tomcat-7.0.55-1-1").with(
        "ensure"   => "present",
      )
    }
  end

  context "ensure => absent works" do
    let :title do
      "custom-apache-tomcat-7.0.55-1-1"
    end
    let :params do 
      {
        "ensure" => "absent",
      }
    end
    it {
      should contain_package("custom-apache-tomcat-7.0.55-1-1").with(
        "ensure"   => "absent",
      )
    }
  end

  context "symlink_source works" do
    let :title do
      "custom-apache-tomcat-7.0.55-1-1"
    end
    let :params do
      {
        "symlink_source" => "/foobar",
        "symlink_target" => "/baz",
      }
    end
    it {
      should contain_file("/foobar").with(
        "ensure"   => "link",
        "target"   => "/baz",
      )
    }
  end

  context "symlink_target works" do
    let :title do
      "custom-apache-tomcat-7.0.55-1-1"
    end
    let :params do
      {
        "symlink_target" => "/baz",
      }
    end
    it {
      should contain_file("/usr/local/apache-tomcat").with(
        "ensure"   => "link",
        "target"   => "/baz",
      )
    }
  end

end
