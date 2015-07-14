require 'spec_helper'
describe 'tomcat::port', :type => :define do
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
      "6666"
    end
    it {
      expect { should compile }.to raise_error(/only supports the RedHat/)
    }
  end


  context "low int" do
    let :title do
      "1"
    end
    it { should compile }
  end

  context "high int" do
    let :title do
      "65535"
    end
    it { should compile }
  end

  context "non-numeric fail" do
    let :title do
      "41kda"
    end
    it  {
      expect { should compile }.to raise_error(/invalid port/)
    }
  end

  context "too low fail" do
    let :title do
      "0"
    end
    it  {
      expect { should compile }.to raise_error(/invalid port/)
    }
  end

  context "too high fail" do
    let :title do
      "65536"
    end
    it  {
      expect { should compile }.to raise_error(/invalid port/)
    }
  end

end
