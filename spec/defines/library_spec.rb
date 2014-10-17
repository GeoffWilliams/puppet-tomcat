require 'spec_helper'
describe 'tomcat::library', :type => :define do

  #
  # shared/endorsed dirs default/on
  #
  let :pre_condition do
    'class { "tomcat": }'
  end

  context "ensure=>present (shared,default)" do
    let :title do
      $lib_name
    end
    let :params do
      {
        "ensure"        => "present",
        "lib_type"      => "shared",
        "download_site" => "http://localhost/",
      }
    end
    it {
      should contain_staging__file($lib_name).with(
        "target" => "#{$def_shared_lib_dir}/#{$lib_name}",
      )
      should contain_exec($exec_trigger_title).that_comes_before(
        "File[#{$def_shared_lib_trigger}]",
      )
    }
  end

  context "ensure=>present (shared,custom)" do
    let :pre_condition do
      <<-EOD
      class { "tomcat":
        shared_lib_dir   => "#{$custom_shared_lib_dir}",
        endorsed_lib_dir => "#{$custom_endorsed_lib_dir}",
      }
      EOD
    end
    let :title do
      $lib_name
    end
    let :params do
      {
        "ensure"         => "present",
        "lib_type"       => "shared",
        "download_site"  => "http://localhost/",
        "shared_lib_dir" => $custom_shared_lib_dir,
      }
    end
    it {
      should contain_staging__file($lib_name).with(
        "target" => "#{$custom_shared_lib_dir}/#{$lib_name}",
      )
      should contain_exec($exec_trigger_title).that_comes_before(
        "File[#{$custom_shared_lib_trigger}]",
      )
    }
  end

  context "ensure=>present (endorsed,default)" do
    let :title do
      $lib_name
    end
    let :params do
      {
        "ensure"        => "present",
        "lib_type"      => "endorsed",
        "download_site" => "http://localhost/",
      }
    end
    it {
      should contain_staging__file($lib_name).with(
        "target" => "#{$def_endorsed_lib_dir}/#{$lib_name}",
      )
      should contain_exec($exec_trigger_title).that_comes_before(
        "File[#{$def_endorsed_lib_trigger}]"
      )
    }
  end

  context "ensure=>present (endorsed,custom)" do
    let :pre_condition do
      <<-EOD
      class { "tomcat":
        shared_lib_dir   => "#{$custom_shared_lib_dir}",
        endorsed_lib_dir => "#{$custom_endorsed_lib_dir}",
      }
      EOD
    end
    let :title do
      $lib_name
    end
    let :params do
      {
        "ensure"           => "present",
        "lib_type"         => "endorsed",
        "download_site"    => "http://localhost/",
        "endorsed_lib_dir" => $custom_endorsed_lib_dir,
      }
    end
    it {
      should contain_staging__file($lib_name).with(
        "target" => "#{$custom_endorsed_lib_dir}/#{$lib_name}",
      )
      should contain_exec($exec_trigger_title).that_comes_before(
        "File[#{$custom_endorsed_lib_trigger}]"
      )
    }
  end

  context "ensure=>absent (shared,default)" do
    let :title do
      $lib_name
    end
    let :params do
      {
        "ensure"   => "absent",
        "lib_type" => "shared",
      }
    end
    it {
      should contain_file("#{$def_shared_lib_dir}/#{$lib_name}").with(
        "ensure" => "absent",
      )
      should contain_exec($exec_trigger_title).that_comes_before(
        "File[#{$def_shared_lib_trigger}]"
      )
    }
  end

  context "ensure=>absent (shared,custom)" do
    let :pre_condition do
      <<-EOD
      class { "tomcat":
        shared_lib_dir   => "#{$custom_shared_lib_dir}",
        endorsed_lib_dir => "#{$custom_endorsed_lib_dir}",
      }
      EOD
    end
    let :title do
      $lib_name
    end
    let :params do
      {
        "ensure"         => "absent",
        "lib_type"       => "shared",
        "shared_lib_dir" => $custom_shared_lib_dir,
      }
    end
    it {
      should contain_file("#{$custom_shared_lib_dir}/#{$lib_name}").with(
        "ensure" => "absent",
      )
      should contain_exec($exec_trigger_title).that_comes_before(
        "File[#{$custom_shared_lib_trigger}]"
      )
    }
  end

  context "ensure=>absent (endorsed,default)" do
    let :title do
      $lib_name
    end
    let :params do
      {
        "ensure"   => "absent",
        "lib_type" => "endorsed",
      }
    end
    it {
      should contain_file("#{$def_endorsed_lib_dir}/#{$lib_name}").with(
        "ensure" => "absent",
      )
      should contain_exec($exec_trigger_title).that_comes_before(
        "File[#{$def_endorsed_lib_trigger}]"
      )
    }
  end


  context "ensure=>absent (endorsed,custom)" do
    let :pre_condition do
      <<-EOD
      class { "tomcat":
        shared_lib_dir   => "#{$custom_shared_lib_dir}",
        endorsed_lib_dir => "#{$custom_endorsed_lib_dir}",
      }
      EOD
    end

    let :title do
      $lib_name
    end
    let :params do
      {
        "ensure"           => "absent",
        "lib_type"         => "endorsed",
        "endorsed_lib_dir" => $custom_endorsed_lib_dir,
      }
    end
    it {
      should contain_file("#{$custom_endorsed_lib_dir}/#{$lib_name}").with(
        "ensure" => "absent",
      )
      should contain_exec($exec_trigger_title).that_comes_before(
        "File[#{$custom_endorsed_lib_trigger}]"
      )
    }
  end


end
