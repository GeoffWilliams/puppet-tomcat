require 'spec_helper'
describe 'tomcat', :type => :class do

  context "libxml2 installed" do
    let :title do
      "custom-apache-tomcat-7.0.55-1-1"
    end
    it {
      should contain_package("libxml2").with(
        "ensure"   => "present",
      )
    }
  end

  context "instances directory created (default)" do
    let :title do
      "custom-apache-tomcat-7.0.55-1-1"
    end
    let :params do 
      {
      }
    end
    it {
      should contain_file($instances).with(
        "ensure" => "directory",
        "owner"  => $def_file_owner,
        "group"  => $def_file_group,
        "mode"   => $def_file_mode_regular,
      )
    }
  end

  context "instances directory created (custom)" do
    let :title do
      "custom-apache-tomcat-7.0.55-1-1"
    end
    let :params do 
      {
        "instance_root_dir" => "/foobar",
        "file_mode_regular" => $custom_file_mode_regular,
        "file_owner"        => $custom_file_owner,
        "file_group"        => $custom_file_group,
      }
    end
    it {
      should contain_file("/foobar").with(
        "ensure" => "directory",
        "owner"  => $custom_file_owner,
        "group"  => $custom_file_group,
        "mode"   => $custom_file_mode_regular,
      )
    }
  end

  ["shared_lib_dir", "endorsed_lib_dir"].each do | lib_dir |
    context "#{lib_dir} created (default)" do
      let :title do
        "custom-apache-tomcat-7.0.55-1-1"
      end
      it {
        should contain_file($default_file[lib_dir]).with(
          "ensure" => "directory",
          "owner"  => $def_file_owner,
          "group"  => $def_file_group,
          "mode"   => $def_file_mode_regular,
        )
        should contain_file("#{$default_file[lib_dir]}/#{$trigger_file}").with(
          "ensure" => "absent",
        )
      }
    end

    context "#{lib_dir} not created (set off)" do
      let :title do
        "custom-apache-tomcat-7.0.55-1-1"
      end
      let :params do
        {
          lib_dir => false,
        }
      end
      it {
        should_not contain_file($default_file[lib_dir])
      }
    end

    context "#{lib_dir} created (custom)" do
      let :title do
        "custom-apache-tomcat-7.0.55-1-1"
      end
      let :params do
        {
          lib_dir => "/foo",
          "file_mode_regular" => $custom_file_mode_regular,
          "file_owner"        => $custom_file_owner,
          "file_group"        => $custom_file_group,
        }
      end
      it {
        should contain_file("/foo").with(
          "ensure" => "directory",
          "owner"  => $custom_file_owner,
          "group"  => $custom_file_group,
          "mode"   => $custom_file_mode_regular,
        )
        should contain_file("/foo/#{$trigger_file}").with(
          "ensure" => "absent",
        )
      }
    end

  end
end
