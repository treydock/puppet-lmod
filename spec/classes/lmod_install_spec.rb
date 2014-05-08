require 'spec_helper'

describe 'lmod::install' do
  include_context :defaults

  let(:facts) { default_facts }

  let(:pre_condition) { "class { 'lmod': }" }

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

  it { should create_class('lmod::install') }
  it { should contain_class('lmod') }

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
    let(:pre_condition) { "class { 'lmod': manage_build_packages => true }" }

    it { should have_package_resource_count(5) }

    build_packages.each do |package|
      it { should contain_package(package).with({ 'ensure' => 'present' }) }
    end
  end
end
