require 'spec_helper_acceptance'

describe 'lmod class:' do
  context 'default parameters' do
    it 'should run successfully' do
      pp =<<-EOS
        class { 'lmod': }
      EOS

      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    [
      'lua',
      'lua-filesystem',
      'lua-posix',
      'zsh',
    ].each do |package|
      describe package(package) do
        it { should be_installed }
      end
    end

    [
      '/etc/profile.d/modules.sh',
      '/etc/profile.d/modules.csh',
      '/etc/profile.d/z00_StdEnv.sh',
      '/etc/profile.d/z00_StdEnv.csh',
    ].each do |file|
      describe file(file) do
        it { should be_file }
        it { should be_mode 644 }
        it { should be_owned_by 'root' }
        it { should be_grouped_into 'root' }
      end
    end
  end

  context 'when manage_build_packages => true' do
    it 'should run successfully' do
      pp =<<-EOS
        class { 'lmod': manage_build_packages => true }
      EOS

      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    [
      'lua',
      'lua-devel',
      'lua-filesystem',
      'lua-posix',
      'zsh',
    ].each do |package|
      describe package(package) do
        it { should be_installed }
      end
    end

    [
      '/etc/profile.d/modules.sh',
      '/etc/profile.d/modules.csh',
      '/etc/profile.d/z00_StdEnv.sh',
      '/etc/profile.d/z00_StdEnv.csh',
    ].each do |file|
      describe file(file) do
        it { should be_file }
        it { should be_mode 644 }
        it { should be_owned_by 'root' }
        it { should be_grouped_into 'root' }
      end
    end
  end
end
