require 'spec_helper_acceptance'

describe 'lmod class:' do
  context 'default parameters' do
    it 'runs successfully' do
      pp = <<-EOS
        class { 'lmod': }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it_behaves_like 'lmod::install without build packages'
    it_behaves_like 'lmod::load'
  end

  context 'when manage_build_packages => true' do
    it 'runs successfully' do
      pp = <<-EOS
        class { 'lmod': manage_build_packages => true }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it_behaves_like 'lmod::install with build packages'
    it_behaves_like 'lmod::load'
  end
end
