require 'spec_helper'

describe 'lmod::apps::ruby' do
  include_context :defaults

  let(:facts) { default_facts }

  base_packages = [
    'systemtap-sdt-devel',
  ]

  runtime_packages = [
    'commoncpp2',
    'libaio',
  ]

  build_packages = runtime_packages.map{|p| "#{p}-devel" }

  it { should create_class('lmod::apps::ruby') }
  it { should contain_class('lmod') }

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

    build_packages.each do |package|
      it { should contain_package(package).with({ 'ensure' => 'present' }) }
    end
  end
end
