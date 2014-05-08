require 'spec_helper'

describe 'lmod::apps::all' do
  include_context :defaults

  let(:facts) { default_facts }

  # Classes referenced by included classes
  extra_classes = [
    'lmod',
    'lmod::load',
    'lmod::params',
    'java',
    'java::params',
    'java::config',
  ]

  app_classes = [
    'gcc',
    'openmpi',
    'ruby',
  ]

  count = extra_classes.size + app_classes.size + 1

  it { should have_class_count(count) }

  it { should create_class('lmod::apps::all') }

  extra_classes.each do |c|
    it { should contain_class(c) }
  end

  app_classes.each do |c|
    it { should contain_class("lmod::apps::#{c}") }
  end

end
