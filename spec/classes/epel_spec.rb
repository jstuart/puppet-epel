require 'spec_helper'

describe 'epel' do
  context "operatingsystem => #{default_facts[:operatingsystem]}" do

    context 'operatingsystemmajrelease => 6' do
      let :facts do
        default_facts.merge({
          :operatingsystemrelease     => '6.4',
          :operatingsystemmajrelease  => '6',
        })
      end

	  it { should create_class('epel') }

      it do
	    should contain_file("/etc/yum.repos.d/epel.repo").with({
	      'ensure' => 'file',
	    })
	  end
	  
      it do
	    should contain_file("/etc/yum.repos.d/epel-testing.repo").with({
	      'ensure' => 'file',
	    })
	  end
	  
      it do
        should contain_package('epel-release').with('ensure' => 'latest')
      end

    end

  end
end