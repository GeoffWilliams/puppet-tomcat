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
end
