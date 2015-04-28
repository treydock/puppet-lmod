require 'spec_helper'

describe 'lmod' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { should create_class('lmod') }
      it { should contain_class('lmod::params') }
      it { should contain_class('epel') }

      it { should contain_anchor('lmod::start').that_comes_before('Yumrepo[epel]') }
      it { should contain_anchor('lmod::end') }

      it { should contain_yumrepo('epel').that_comes_before('Class[lmod::install]') }
      it { should contain_class('lmod::install').that_comes_before('Class[lmod::load]') }
      it { should contain_class('lmod::load').that_comes_before('Anchor[lmod::end]') }

      # Test validate_string parameters
      [
        :prefix,
        :modulepath_root,
        :lmod_package_path,
        :default_module,
        :modules_bash_template,
        :modules_csh_template,
      ].each do |param|
        context "with #{param} => ['foo']" do
          let(:params) {{ param.to_sym => ['foo'] }}
          it "should raise error" do
            expect { should compile }.to raise_error(/is not a string/)
          end
        end
      end

      # Test validate_array parameters
      [
        :modulepaths,
        :avail_styles,
      ].each do |param|
        context "with #{param} => 'foo'" do
          let(:params) {{ param.to_sym => 'foo' }}
          it "should raise error" do
            expect { should compile }.to raise_error(/is not an Array/)
          end
        end
      end

      # Test validate_bool parameters
      [
        :set_lmod_package_path,
        :set_default_module,
        :manage_build_packages,
      ].each do |param|
        context "with #{param} => 'foo'" do
          let(:params) {{ param.to_sym => 'foo' }}
          it "should raise error" do
            expect { should compile }.to raise_error(/is not a boolean/)
          end
        end
      end
    end
  end
end
