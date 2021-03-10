require 'spec_helper_acceptance'

describe 'lmod class:' do
  context 'when install_method => "source"' do
    it 'runs successfully' do
      pp = <<-EOS
        class { 'lmod': install_method => 'source' }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it_behaves_like 'lmod::install dependencies'
    it_behaves_like 'lmod::load'
    describe command('/bin/bash -l -c "type module"') do
      its(:stdout) { is_expected.to match %r{LMOD_CMD} }
    end
    describe command('/bin/bash -l -c "module load lmod ; which lmod"') do
      its(:exit_status) { is_expected.to eq(0) }
    end
  end

  context 'default parameters' do
    it 'runs successfully' do
      clean_pp = "class { 'lmod': ensure => 'absent' }"
      pp = <<-EOS
        class { 'lmod': }
      EOS

      apply_manifest(clean_pp, catch_failures: true)
      on hosts, 'rm -rf /usr/share/lmod'
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it_behaves_like 'lmod::install package'
    it_behaves_like 'lmod::load'
    describe command('/bin/bash -l -c "type module"') do
      its(:stdout) { is_expected.to match %r{LMOD_CMD} }
    end
    describe command('/bin/bash -l -c "module load lmod ; which lmod"') do
      its(:exit_status) { is_expected.to eq(0) }
    end
  end
end
