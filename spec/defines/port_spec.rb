require 'spec_helper'
describe 'tomcat::port', :type => :define do

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

  context "missing value fail" do
    let :title do
      ""
    end
    it { 
      expect { subject }.to raise_error(/invalid port/)
    }
  end

  context "non-numeric fail" do
    let :title do
      "41kda"
    end
    it  {
      expect { subject }.to raise_error(/invalid port/)
    }
  end

  context "too low fail" do
    let :title do
      "0"
    end
    it  {
      expect { subject }.to raise_error(/invalid port/)
    }
  end

  context "too high fail" do
    let :title do
      "65536"
    end
    it  {
      expect { subject }.to raise_error(/invalid port/)
    }
  end

end
