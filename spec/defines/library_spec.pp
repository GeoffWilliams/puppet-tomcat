require 'spec_helper'
describe 'tomcat::library', :type => :define do
  let :pre_condition do
    'class { "tomcat": }'
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
