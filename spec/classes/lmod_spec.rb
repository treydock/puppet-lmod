require 'spec_helper'

describe 'lmod' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { should compile.with_all_deps }
      it { should create_class('lmod') }
      it { should contain_class('lmod::params') }

      it { should contain_anchor('lmod::start').that_comes_before('Class[lmod::install]') }
      it { should contain_class('lmod::install').that_comes_before('Class[lmod::load]') }
      it { should contain_class('lmod::load').that_comes_before('Anchor[lmod::end]') }
      it { should contain_anchor('lmod::end') }

      describe 'lmod::install' do
        if facts[:operatingsystemmajrelease] == '5'
          base_packages = [
                           'lua-filesystem',
                           'lua-posix',
                           'tcl',
                           'zsh',
                          ]
        elsif facts[:operatingsystemmajrelease] == '14.04'
          base_packages = [
                           'lua-filesystem',
                           'lua-json',
                           'lua-posix',
                           'tcl',
                           'zsh',
                          ]
        else
          base_packages = [
                           'lua-filesystem',
                           'lua-json',
                           'lua-posix',
                           'lua-term',
                           'tcl',
                           'zsh',
                          ]
        end
        if facts[:osfamily] == 'RedHat'
          modules_csh_path = '/etc/profile.d/modules.csh'
          stdenv_csh_path = '/etc/profile.d/z00_StdEnv.csh'
          package_name = 'Lmod'
          runtime_packages = [ 'lua' ]
          build_packages = [ 'lua-devel' ]
        elsif facts[:osfamily] == 'Debian'
          modules_csh_path = '/etc/csh/login.d/modules.csh'
          stdenv_csh_path = '/etc/csh/login.d/z00_StdEnv.csh'
          package_name = 'lmod'
          runtime_packages = [ 'lua5.2' ]
          build_packages = [ 'liblua5.2-dev',
                             'lua-filesystem-dev',
                             'lua-posix-dev' ]
        else
          modules_csh_path = '/etc/profile.d/modules.csh'
          stdenv_csh_path = '/etc/profile.d/z00_StdEnv.csh'
        end

        if facts[:osfamily] == 'RedHat'
          it { should contain_class('epel') }
        end
        it { should have_package_resource_count(base_packages.size + runtime_packages.size) }

        base_packages.each do |package|
          it { should contain_package(package).with_ensure('present') }
          if facts[:osfamily] == 'RedHat'
            it { should contain_package(package).with_require('Yumrepo[epel]') }
          end
        end

        runtime_packages.each do |package|
          it { should contain_package(package).with_ensure('present') }
          if facts[:osfamily] == 'RedHat'
            it { should contain_package(package).with_require('Yumrepo[epel]') }
          end
        end

        build_packages.each do |package|
          it { should_not contain_package(package) }
        end

        context "manage_build_packages => true" do
          let(:params) {{ :manage_build_packages => true }}

          it { should have_package_resource_count(base_packages.size + runtime_packages.size + build_packages.size) }

          build_packages.each do |package|
            it { should contain_package(package).with_ensure('present') }
            if facts[:osfamily] == 'RedHat'
              it { should contain_package(package).with_require('Yumrepo[epel]') }
            end
          end
        end

        context "lmod_package_from_repo => true" do
          let(:params) {{ :lmod_package_from_repo => true }}

          it { should have_package_resource_count(1) }

          it { should contain_package(package_name).with_ensure('present') }
          if facts[:osfamily] == 'RedHat'
            it { should contain_package(package_name).with_require('Yumrepo[epel]') }
          end
        end

        context 'ensure => absent' do
          let(:params) {{ :ensure => 'absent' }}
          it { should have_package_resource_count(0) }
        end

        context 'ensure => absent and lmod_package_from_repo => true' do
          let(:params) {{ :ensure => 'absent', :lmod_package_from_repo => true }}
          it { should have_package_resource_count(1) }
          it { should contain_package(package_name).with_ensure('absent') }
        end
      end

      describe 'lmod::load' do
        it do
          should contain_file('lmod-sh-load').with({
            :ensure  => 'present',
            :path    => '/etc/profile.d/modules.sh',
            :owner   => 'root',
            :group   => 'root',
            :mode    => '0644',
          })
        end

        it do
          # Doesn't work exactly like I'd hope due to 'fi' at same indention level occurring more than once
          verify_contents(catalogue, 'lmod-sh-load', [
            '    export MODULEPATH_ROOT="/opt/apps/modulefiles"',
            '    export MODULEPATH=$(/opt/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/$LMOD_sys)',
            '    export MODULEPATH=$(/opt/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/Core)',
            '    export MODULEPATH=$(/opt/apps/lmod/lmod/libexec/addto --append MODULEPATH /opt/apps/lmod/lmod/modulefiles/Core)',
            '    export MODULESHOME=/opt/apps/lmod/lmod',
            '    export BASH_ENV=$MODULESHOME/init/bash',
            '    if [ -z "${MANPATH:-}" ]; then',
            '      export MANPATH=:',
            #'    fi',
            '    export MANPATH=$(/opt/apps/lmod/lmod/libexec/addto MANPATH /opt/apps/lmod/lmod/share/man)',
            '    export LMOD_PACKAGE_PATH=$MODULEPATH_ROOT/Site',
            '    export LMOD_AVAIL_STYLE=system',
          ])
        end

        it do
          should contain_file('lmod-csh-load').with({
            :ensure  => 'present',
            :path    => modules_csh_path,
            :owner   => 'root',
            :group   => 'root',
            :mode    => '0644',
          })
        end

        it do
          # Doesn't work exactly like I'd hope due to 'endif' at same indention level occurring more than once
          verify_contents(catalogue, 'lmod-csh-load', [
            '    setenv MODULEPATH_ROOT      "/opt/apps/modulefiles"',
            '    setenv MODULEPATH           `/opt/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/$LMOD_sys`',
            '    setenv MODULEPATH           `/opt/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/Core`',
            '    setenv MODULEPATH           `/opt/apps/lmod/lmod/libexec/addto --append MODULEPATH /opt/apps/lmod/lmod/modulefiles/Core`',
            '    setenv MODULESHOME          "/opt/apps/lmod/lmod"',
            '    setenv BASH_ENV             "$MODULESHOME/init/bash"',
            '    if ( ! $?MANPATH ) then',
            '      setenv MANPATH :',
            #'    endif',
            '    setenv MANPATH `/opt/apps/lmod/lmod/libexec/addto MANPATH /opt/apps/lmod/lmod/share/man`',
            '    setenv LMOD_PACKAGE_PATH $MODULEPATH_ROOT/Site',
            '    setenv LMOD_AVAIL_STYLE system',
            'if ( -f  /opt/apps/lmod/lmod/init/csh  ) then',
            '  source /opt/apps/lmod/lmod/init/csh',
          ])
        end

        it do
          should contain_file('/etc/profile.d/z00_StdEnv.sh').with({
            :ensure  => 'present',
            :path    => '/etc/profile.d/z00_StdEnv.sh',
            :owner   => 'root',
            :group   => 'root',
            :mode    => '0644',
          })
        end

        it do
          verify_contents(catalogue, '/etc/profile.d/z00_StdEnv.sh', [
            'if [ -z "${USER_IS_ROOT:-}" ]; then',
            '  if [ -z "$__Init_Default_Modules" ]; then',
            '    export __Init_Default_Modules=1',
            '    export LMOD_SYSTEM_DEFAULT_MODULES="StdEnv"',
            '    module --initial_load restore',
            '  else',
            '    module refresh',
            '  fi',
            'fi',
          ])
        end

        it do
          should contain_file('z00_StdEnv.csh').with({
            :ensure  => 'present',
            :path    => stdenv_csh_path,
            :owner   => 'root',
            :group   => 'root',
            :mode    => '0644',
          })
        end

        it do
          verify_contents(catalogue, 'z00_StdEnv.csh', [
            'if ( ! $?__Init_Default_Modules ) then',
            '  setenv __Init_Default_Modules 1',
            '  setenv LMOD_SYSTEM_DEFAULT_MODULES "StdEnv"',
            '  module --initial_load restore',
            'else',
            '  module refresh',
            'endif',
          ])
        end

        context "when prefix => '/apps'" do
          let(:params) {{ :prefix => '/apps' }}

          it do
            verify_contents(catalogue, 'lmod-sh-load', [
              '    export MODULEPATH_ROOT="/apps/modulefiles"',
              '    export MODULEPATH=$(/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/$LMOD_sys)',
              '    export MODULEPATH=$(/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/Core)',
              '    export MODULEPATH=$(/apps/lmod/lmod/libexec/addto --append MODULEPATH /apps/lmod/lmod/modulefiles/Core)',
              '    export MODULESHOME=/apps/lmod/lmod',
              '    export BASH_ENV=$MODULESHOME/init/bash',
              '    if [ -z "${MANPATH:-}" ]; then',
              '      export MANPATH=:',
              #'    fi',
              '    export MANPATH=$(/apps/lmod/lmod/libexec/addto MANPATH /apps/lmod/lmod/share/man)',
              '    export LMOD_PACKAGE_PATH=$MODULEPATH_ROOT/Site',
              '    export LMOD_AVAIL_STYLE=system',
            ])
          end

          it do
            verify_contents(catalogue, 'lmod-csh-load', [
              '    setenv MODULEPATH_ROOT      "/apps/modulefiles"',
              '    setenv MODULEPATH           `/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/$LMOD_sys`',
              '    setenv MODULEPATH           `/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/Core`',
              '    setenv MODULEPATH           `/apps/lmod/lmod/libexec/addto --append MODULEPATH /apps/lmod/lmod/modulefiles/Core`',
              '    setenv MODULESHOME          "/apps/lmod/lmod"',
              '    setenv BASH_ENV             "$MODULESHOME/init/bash"',
              '    if ( ! $?MANPATH ) then',
              '      setenv MANPATH :',
              #'    endif',
              '    setenv MANPATH `/apps/lmod/lmod/libexec/addto MANPATH /apps/lmod/lmod/share/man`',
              '    setenv LMOD_PACKAGE_PATH $MODULEPATH_ROOT/Site',
              '    setenv LMOD_AVAIL_STYLE system',
              'if ( -f  /apps/lmod/lmod/init/csh  ) then',
              '  source /apps/lmod/lmod/init/csh',
            ])
          end
        end

        context "when modulepaths => ['Linux','Core','Compiler','MPI']" do
          let(:params) {{ :modulepaths => ['Linux','Core','Compiler','MPI'] }}

          it do
            verify_contents(catalogue, 'lmod-sh-load', [
              '    export MODULEPATH=$(/opt/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/Linux)',
              '    export MODULEPATH=$(/opt/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/Core)',
              '    export MODULEPATH=$(/opt/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/Compiler)',
              '    export MODULEPATH=$(/opt/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/MPI)',
              '    export MODULEPATH=$(/opt/apps/lmod/lmod/libexec/addto --append MODULEPATH /opt/apps/lmod/lmod/modulefiles/Core)',
            ])
          end

          it do
            verify_contents(catalogue, 'lmod-csh-load', [
              '    setenv MODULEPATH           `/opt/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/Linux`',
              '    setenv MODULEPATH           `/opt/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/Core`',
              '    setenv MODULEPATH           `/opt/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/Compiler`',
              '    setenv MODULEPATH           `/opt/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/MPI`',
              '    setenv MODULEPATH           `/opt/apps/lmod/lmod/libexec/addto --append MODULEPATH /opt/apps/lmod/lmod/modulefiles/Core`',
            ])
          end
        end

        context "when set_lmod_package_path => false" do
          let(:params) {{ :set_lmod_package_path => false }}

          it { should_not contain_file('lmod-sh-load').with_content(/export LMOD_PACKAGE_PATH/) }
          it { should_not contain_file('lmod-csh-load').with_content(/setenv LMOD_PACKAGE_PATH/) }
        end

        context "when default_module => 'foo'" do
          let(:params) {{ :default_module => 'foo' }}

          it 'should export LMOD_SYSTEM_DEFAULT_MODULES="foo"' do
            verify_contents(catalogue, '/etc/profile.d/z00_StdEnv.sh', [
              '    export LMOD_SYSTEM_DEFAULT_MODULES="foo"',
            ])
          end

          it 'should setenv LMOD_SYSTEM_DEFAULT_MODULES="foo"' do
            verify_contents(catalogue, 'z00_StdEnv.csh', [
              '  setenv LMOD_SYSTEM_DEFAULT_MODULES "foo"',
            ])
          end
        end

        context "when set_default_module => false" do
          let(:params) {{ :set_default_module => false }}

          it { should contain_file('/etc/profile.d/z00_StdEnv.sh').with_ensure('absent') }
          it { should contain_file('z00_StdEnv.csh').with_ensure('absent') }
        end

        context "when avail_styles => ['grouped','system']" do
          let(:params) {{ :avail_styles => ['grouped','system'] }}

          it "should set LMOD_AVAIL_STYLE=grouped:system" do
            verify_contents(catalogue, 'lmod-sh-load', [
              '    export LMOD_AVAIL_STYLE=grouped:system',
            ])
          end

          it "should set LMOD_AVAIL_STYLE grouped:system" do
            verify_contents(catalogue, 'lmod-csh-load', [
              '    setenv LMOD_AVAIL_STYLE grouped:system',
            ])
          end
        end

        context "when lmod_admin_file => /opt/apps/lmod/etc/admin.list" do
          let(:params) {{ :lmod_admin_file => '/opt/apps/lmod/etc/admin.list' }}

          it do
            verify_contents(catalogue, 'lmod-sh-load', [
              '    export LMOD_AVAIL_STYLE=system',
              '    export LMOD_ADMIN_FILE=/opt/apps/lmod/etc/admin.list',
              '  fi',
            ])
          end

          it do
            verify_contents(catalogue, 'lmod-csh-load', [
              '    setenv LMOD_AVAIL_STYLE system',
              '    setenv LMOD_ADMIN_FILE /opt/apps/lmod/etc/admin.list',
              'endif',
            ])
          end
        end

        context "when system_name => foo" do
          let(:params) {{ :system_name => 'foo' }}

          it do
            verify_contents(catalogue, 'lmod-sh-load', [
              '    export LMOD_SYSTEM_NAME=foo',
              '  fi',
            ])
          end

          it do
            verify_contents(catalogue, 'lmod-csh-load', [
              '    setenv LMOD_SYSTEM_NAME foo',
              'endif',
            ])
          end
        end

        context 'ensure => absent' do
          let(:params) {{ :ensure => 'absent' }}
          it { should contain_file('lmod-sh-load').with_ensure('absent') }
          it { should contain_file('lmod-csh-load').with_ensure('absent') }
          it { should contain_file('/etc/profile.d/z00_StdEnv.sh').with_ensure('absent') }
          it { should contain_file('z00_StdEnv.csh').with_ensure('absent') }
        end
      end

      context 'when ensure => foo' do
        let(:params) {{ :ensure => 'foo' }}
        it "should raise error" do
          expect { should compile }.to raise_error(/ensure must be 'present' or 'absent'/)
        end
      end

      # Test validate_string parameters
      [
        :prefix,
        :modulepath_root,
        :lmod_package_path,
        :default_module,
        :modules_bash_template,
        :modules_csh_template,
        :stdenv_bash_template,
        :stdenv_csh_template,
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
        :lmod_package_from_repo,
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
