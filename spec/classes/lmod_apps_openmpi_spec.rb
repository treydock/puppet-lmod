require 'spec_helper'

describe 'lmod::apps::openmpi' do
  include_context :defaults

  let(:facts) { default_facts }

  base_packages = []

  runtime_packages = [
    'libibverbs',
    'valgrind',
    'numactl',
    'db4',
    'libX11',
    'papi',
    'pciutils',
  ]

  build_packages = runtime_packages.map{|p| "#{p}-devel" }

  it { should create_class('lmod::apps::openmpi') }
  it { should contain_class('lmod') }
  it { should contain_class('java') }

  it { should have_package_resource_count(12) }

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
    let(:pre_condition) { "class { 'lmod': manage_build_packages => true}" }

    it { should have_package_resource_count(20) }

    build_packages.each do |package|
      it { should contain_package(package).with({ 'ensure' => 'present' }) }
    end
  end
end
