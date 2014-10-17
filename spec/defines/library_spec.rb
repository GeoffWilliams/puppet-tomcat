require 'spec_helper'
describe 'tomcat::library', :type => :define do
  instances = "/var/lib/tomcat"
  catalina_home = "/usr/local/apache-tomcat"
  def_file_owner = "root"
  def_file_group = "tomcat"
  def_instance_user = "tomcat"
  def_instance_group = def_instance_user
  def_file_mode_regular = "0640"
  def_file_mode_script = "0750"
  def_file_mode_init = "0755"
  custom_file_owner = "tomcat_user"
  custom_file_group = "tomcat_group"
  custom_instance_user = "tomcat_instance_user"
  custom_instance_group = custom_instance_user
  custom_file_mode_regular = "0600"
  custom_file_mode_script  = "0700"
  custom_file_mode_init = "0740"
  def_shared_lib_dir = "/usr/local/lib/tomcat_shared"
  def_endorsed_lib_dir = "/usr/local/lib/tomcat_endorsed"
  custom_shared_lib_dir = "/foo_shared"
  custom_endorsed_lib_dir = "/foo_endorsed"


  let :pre_condition do
    'class { "tomcat": }'
  end

  context "ensure=>present (shared,default)" do
    let :title do
      "libfoo.jar"
    end
    let :params do
      {
        "ensure"        => "present",
        "lib_type"      => "shared",
        "download_site" => "http://localhost/",
      }
    end
    it {
      should contain_staging__file("libfoo.jar").with(
        "target" => "#{def_shared_lib_dir}/libfoo.jar",
      )
    }
  end

  context "ensure=>present (shared,custom)" do
    let :title do
      "libfoo.jar"
    end
    let :params do
      {
        "ensure"         => "present",
        "lib_type"       => "shared",
        "download_site"  => "http://localhost/",
        "shared_lib_dir" => custom_shared_lib_dir,
      }
    end
    it {
      should contain_staging__file("libfoo.jar").with(
        "target" => "#{custom_shared_lib_dir}/libfoo.jar",
      )
    }
  end

  context "ensure=>present (endorsed,default)" do
    let :title do
      "libfoo.jar"
    end
    let :params do
      {
        "ensure"        => "present",
        "lib_type"      => "endorsed",
        "download_site" => "http://localhost/",
      }
    end
    it {
      should contain_staging__file("libfoo.jar").with(
        "target" => "#{def_endorsed_lib_dir}/libfoo.jar",
      )
    }
  end

  context "ensure=>present (endorsed,custom)" do
    let :title do
      "libfoo.jar"
    end
    let :params do
      {
        "ensure"           => "present",
        "lib_type"         => "endorsed",
        "download_site"    => "http://localhost/",
        "endorsed_lib_dir" => custom_endorsed_lib_dir,
      }
    end
    it {
      should contain_staging__file("libfoo.jar").with(
        "target" => "#{custom_endorsed_lib_dir}/libfoo.jar",
      )
    }
  end

  context "ensure=>absent (shared,default)" do
    let :title do
      "libfoo.jar"
    end
    let :params do
      {
        "ensure"   => "absent",
        "lib_type" => "shared",
      }
    end
    it {
      should contain_file("#{def_shared_lib_dir}/libfoo.jar").with(
        "ensure" => "absent",
      )
    }
  end

  context "ensure=>absent (shared,custom)" do
    let :title do
      "libfoo.jar"
    end
    let :params do
      {
        "ensure"         => "absent",
        "lib_type"       => "shared",
        "shared_lib_dir" => custom_shared_lib_dir,
      }
    end
    it {
      should contain_file("#{custom_shared_lib_dir}/libfoo.jar").with(
        "ensure" => "absent",
      )
    }
  end

  context "ensure=>absent (endorsed,default)" do
    let :title do
      "libfoo.jar"
    end
    let :params do
      {
        "ensure"   => "absent",
        "lib_type" => "endorsed",
      }
    end
    it {
      should contain_file("#{def_endorsed_lib_dir}/libfoo.jar").with(
        "ensure" => "absent",
      )
    }
  end

  context "ensure=>absent (endorsed,custom)" do
    let :title do
      "libfoo.jar"
    end
    let :params do
      {
        "ensure"           => "absent",
        "lib_type"         => "endorsed",
        "endorsed_lib_dir" => custom_endorsed_lib_dir,
      }
    end
    it {
      should contain_file("#{custom_endorsed_lib_dir}/libfoo.jar").with(
        "ensure" => "absent",
      )
    }
  end

end
