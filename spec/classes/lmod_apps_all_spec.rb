require 'spec_helper'

describe 'lmod::apps::all' do
  include_context :defaults

  let(:facts) { default_facts }

  it { should create_class('lmod::apps::all') }

  [
    'gcc',
    'openmpi',
    'ruby',
  ].each do |c|
    it { should contain_class("lmod::apps::#{c}") }
  end

end
