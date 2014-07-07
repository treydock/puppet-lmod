require 'spec_helper'

describe 'lmod' do
  include_context :defaults

  let(:facts) { default_facts }

  it { should create_class('lmod') }
  it { should contain_class('lmod::params') }
  it { should contain_class('epel') }

  it { should contain_anchor('lmod::start').that_comes_before('Yumrepo[epel]') }
  it { should contain_anchor('lmod::end') }

  it { should contain_yumrepo('epel').that_comes_before('Class[lmod::install]') }
  it { should contain_class('lmod::install').that_comes_before('Class[lmod::load]') }
  it { should contain_class('lmod::load').that_comes_before('Anchor[lmod::end]') }

  # Test verify_boolean parameters
  [
    'set_lmod_package_path',
    'manage_build_packages',
  ].each do |param|
    context "with #{param} => 'foo'" do
      let(:params) {{ param.to_sym => 'foo' }}
      it { expect { should create_class('lmod') }.to raise_error(Puppet::Error, /is not a boolean/) }
    end
  end
end
