require 'spec_helper'
describe 'tomcat::install', :type => :define do

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
      "custom-apache-tomcat-7.0.55-1-1"
    end
    it {
      expect { subject }.to raise_error(/only supports the RedHat/)
    }
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

  context "symlink_source works (default o/g)" do
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
        "owner"    => $def_file_owner,
        "group"    => $def_file_group,
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
        "file_owner"     => $custom_file_owner,
        "file_group"     => $custom_file_group,
      }
    end
    it {
      should contain_file($def_tomcat).with(
        "ensure"   => "link",
        "target"   => "/baz",
        "owner"    => $custom_file_owner,
        "group"    => $custom_file_group,
      )
    }
  end

  context "install via staging (defaults)" do
    let :title do
      "custom-apache-tomcat-7.0.55-1.rpm"
    end
    let :params do
      {
        "download_site" => "http://foobar.com",
      }
    end
    it {
      should contain_file("/var/cache/tomcat_rpms").with(
        "ensure" => "directory",
      )
    }
    it {
      should contain_staging__file("custom-apache-tomcat-7.0.55-1.rpm").with(
        "source" => "http://foobar.com/custom-apache-tomcat-7.0.55-1.rpm",
        "target" => "/var/cache/tomcat_rpms/custom-apache-tomcat-7.0.55-1.rpm",
      )
    }
  end

  context "install via staging (custom local_dir)" do
    let :title do
      "custom-apache-tomcat-7.0.55-1.rpm"
    end
    let :params do 
      {
        "local_dir" => "/rpms",
        "download_site" => "http://foobar.com",
      }
    end
    it {
      should contain_file("/rpms").with(
        "ensure" => "directory",
      )
    }
    it {
      should contain_staging__file("custom-apache-tomcat-7.0.55-1.rpm").with(
        "source" => "http://foobar.com/custom-apache-tomcat-7.0.55-1.rpm",
        "target" => "/rpms/custom-apache-tomcat-7.0.55-1.rpm",
      )
    }
  end


end
