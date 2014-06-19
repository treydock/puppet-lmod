require 'spec_helper'

describe 'lmod::apps::gcc' do
  include_context :defaults

  let(:facts) { default_facts }

  base_packages = [
    'texinfo',
    'dejagnu',
  ]

  runtime_packages = [
    'gmp',
    'libmpc',
    'mpfr',
    'libgcj',
    'elfutils-libelf',
    'ppl',
    'cloog-ppl',
  ]

  build_packages = runtime_packages.map{|p| "#{p}-devel" }

  it { should create_class('lmod::apps::gcc') }
  it { should contain_class('lmod') }
  it { should_not contain_class('devtools') }

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

    it { should contain_class('devtools') }

    build_packages.each do |package|
      it { should contain_package(package).with({ 'ensure' => 'present' }) }
    end
  end
end
