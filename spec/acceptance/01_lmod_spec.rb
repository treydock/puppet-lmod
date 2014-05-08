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

    describe package('lmod') do
      it { should be_installed }
    end

    describe service('lmod') do
      it { should be_enabled }
      it { should be_running }
    end

    describe file('/etc/lmod.conf') do
      it { should be_file }
      it { should be_mode 644 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    end
  end
end
