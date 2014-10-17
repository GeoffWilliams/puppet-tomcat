require 'spec_helper'
describe 'tomcat::library', :type => :define do

  let :pre_condition do
    'class { "tomcat": }'
  end

  def_pre_condition = 'class { "tomcat": }'
  custom_pre_condition = <<-EOD
    class { "tomcat":
      shared_lib_dir   => "#{$custom_shared_lib_dir}",
      endorsed_lib_dir => "#{$custom_endorsed_lib_dir}",
    }
  EOD


  tests = {
    "ensure=>present (shared,default)" => {
      "params" => {
          "ensure"        => "present",
          "lib_type"      => "shared",
          "download_site" => "http://localhost/",
      },
      "target"  => $def_shared_lib_target,
      "trigger" => $def_shared_lib_trigger,
    },
    "ensure=>present (shared,custom)" => {
      "pre_condition" => custom_pre_condition,
      "params" => {
        "ensure"         => "present",
        "lib_type"       => "shared",
        "download_site"  => "http://localhost/",
        "shared_lib_dir" => $custom_shared_lib_dir,
      },
      "target"  => $custom_shared_lib_target,
      "trigger" => $custom_shared_lib_trigger,
    },
    "ensure=>present (endorsed,default)" => {
      "params" => {
        "ensure"        => "present",
        "lib_type"      => "endorsed",
        "download_site" => "http://localhost/",
      },
      "target"  => $def_endorsed_lib_target,
      "trigger" => $def_endorsed_lib_trigger,
    },
    "ensure=>present (endorsed,custom)" => {
      "pre_condition" => custom_pre_condition,
      "params" => {
        "ensure"           => "present",
        "lib_type"         => "endorsed",
        "download_site"    => "http://localhost/",
        "endorsed_lib_dir" => $custom_endorsed_lib_dir,
      },
      "target"  => $custom_endorsed_lib_target,
      "trigger" => $custom_endorsed_lib_trigger,
    },
    "ensure=>absent (shared,default)" => {
      "params" => {
        "ensure"   => "absent",
        "lib_type" => "shared",
      },
      "target"  => $def_shared_lib_target,
      "trigger" => $def_shared_lib_trigger,
    },
    "ensure=>absent (shared,custom)" => {
      "pre_condition" => custom_pre_condition,
      "params" => {
        "ensure"         => "absent",
        "lib_type"       => "shared",
        "shared_lib_dir" => $custom_shared_lib_dir,
      },
      "target"  => $custom_shared_lib_target,
      "trigger" => $custom_shared_lib_trigger,
    },
    "ensure=>absent (endorsed,default)" => {
      "params" => {
        "ensure"   => "absent",
        "lib_type" => "endorsed",
      },
      "target"  => $def_endorsed_lib_target,
      "trigger" => $def_endorsed_lib_trigger,
    },
    "ensure=>absent (endorsed,custom)" => {
      "pre_condition" => custom_pre_condition,
      "params" => {
        "ensure"           => "absent",
        "lib_type"         => "endorsed",
        "endorsed_lib_dir" => $custom_endorsed_lib_dir,
      },
      "target"  => $custom_endorsed_lib_target,
      "trigger" => $custom_endorsed_lib_trigger,
    },
  }

  tests.each do | test_name, test_data |
    context test_name do
      let :pre_condition do
        test_data.has_key?("pre_condition") ? 
          test_data["pre_condition"] : def_pre_condition
      end
      let :title do
        $lib_name
      end
      let :params do
        test_data["params"]
      end
      it {
        if test_data["params"]["ensure"] == "present"
          should contain_staging__file($lib_name).with(
            "target" => test_data["target"],
          )
        else
          should contain_file(test_data["target"]).with(
            "ensure" => "absent",
          )
        end
        should contain_exec($exec_trigger_title).that_comes_before(
          "File[#{test_data['trigger']}]",
        )
      }
    end
  end

end
