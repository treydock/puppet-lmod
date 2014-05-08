require 'spec_helper'

describe 'lmod' do
  include_context :defaults

  let(:facts) { default_facts }

  base_packages = [
    'lua-filesystem',
    'lua-posix',
    'zsh',
  ]

  runtime_packages = [
    'lua',
  ]

  build_packages = [
    'lua-devel',
  ]

  it { should create_class('lmod') }
  it { should contain_class('lmod::params') }

  it { should have_package_resource_count(4) }

  base_packages.each do |package|
    it { should contain_package(package).with({ 'ensure' => 'present' }) }
  end

  runtime_packages.each do |package|
    it { should contain_package(package).with({ 'ensure' => 'present' }) }
  end

  build_packages.each do |package|
    it { should_not contain_package(package) }
  end
  
  context "manage_build_packages => true" do
    let(:params) {{ :manage_build_packages => true }}

    it { should have_package_resource_count(5) }

    build_packages.each do |package|
      it { should contain_package(package).with({ 'ensure' => 'present' }) }
    end
  end

  # Test verify_boolean parameters
  [
    'lmod_package_path',
    'manage_build_packages',
  ].each do |param|
    context "with #{param} => 'foo'" do
      let(:params) {{ param.to_sym => 'foo' }}
      it { expect { should create_class('lmod') }.to raise_error(Puppet::Error, /is not a boolean/) }
    end
  end
end
