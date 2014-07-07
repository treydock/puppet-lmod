require 'spec_helper'

describe 'lmod::install' do
  let(:facts) {{ :osfamily => "RedHat" }}

  let(:pre_condition) { "class { 'lmod': }" }

  base_packages = [
    'lua-filesystem',
    'lua-json',
    'lua-posix',
    'lua-term',
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

  it { should have_package_resource_count(base_packages.size + runtime_packages.size) }

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

    it { should have_package_resource_count(base_packages.size + runtime_packages.size + build_packages.size) }

    build_packages.each do |package|
      it { should contain_package(package).with({ 'ensure' => 'present' }) }
    end
  end
end
