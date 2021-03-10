require 'spec_helper'

describe 'lmod' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      if facts[:osfamily] == 'Debian'
        modulepath_root = '/usr/modulefiles'
        moduels_bash_path = '/etc/profile.d/lmod.sh'
        modules_csh_path = '/etc/csh/login.d/lmod.csh'
        stdenv_csh_path = '/etc/csh/login.d/z00_StdEnv.csh'
      else
        modulepath_root = '/usr/share/modulefiles'
        moduels_bash_path = '/etc/profile.d/modules.sh'
        modules_csh_path = '/etc/profile.d/modules.csh'
        stdenv_csh_path = '/etc/profile.d/z00_StdEnv.csh'
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to create_class('lmod') }

      it { is_expected.to contain_class('lmod::install').that_comes_before('Class[lmod::load]') }
      it { is_expected.to contain_class('lmod::load') }

      describe 'lmod::install' do
        if facts[:osfamily] == 'RedHat'
          package_require = 'Yumrepo[epel]'
          runtime_packages = [
            'lua',
            'lua-filesystem',
            'lua-json',
            'lua-posix',
            'lua-term',
            'tcl',
            'zsh',
          ]
          package_name = 'Lmod'
          build_packages = ['lua-devel', 'tcl-devel', 'gcc', 'gcc-c++', 'make']
        elsif facts[:osfamily] == 'Debian'
          package_require = nil
          runtime_packages = [
            'lua5.2',
            'lua-filesystem',
            'lua-json',
            'lua-posix',
            'lua-term',
            'tcl',
            'tcsh',
            'zsh',
          ]
          package_name = 'lmod'
          build_packages = ['liblua5.2-dev',
                            'lua-filesystem-dev',
                            'lua-posix-dev',
                            'tcl-dev',
                            'gcc',
                            'g++',
                            'make']
        end

        if facts[:osfamily] == 'RedHat'
          it { is_expected.to contain_class('epel') }
        end
        it { is_expected.to have_package_resource_count(1) }
        it { is_expected.to contain_package(package_name).with_ensure('present').with_require(package_require) }

        context "package_ensure => 'latest'" do
          let(:params) { { package_ensure: 'latest' } }

          it { is_expected.to contain_package(package_name).with_ensure('latest') }
        end

        context 'install_method => source' do
          let(:params) { { install_method: 'source' } }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to have_package_resource_count(runtime_packages.size + build_packages.size) }
          (runtime_packages + build_packages).each do |package|
            it { is_expected.to contain_package(package).with_ensure('present').with_require(package_require) }
          end

          it do
            verify_contents(catalogue, 'lmod-configure', [
                              "./configure --prefix=/usr/share --with-module-root-path='#{modulepath_root}'",
                            ])
          end
        end

        context 'ensure => absent' do
          let(:params) { { ensure: 'absent' } }

          it { is_expected.to have_package_resource_count(1) }
          it { is_expected.to contain_package(package_name).with_ensure('absent') }

          context 'install_method => source' do
            let(:params) { { ensure: 'absent', install_method: 'source' } }

            it { is_expected.to have_package_resource_count(0) }
          end
        end
      end

      describe 'lmod::load' do
        it do
          is_expected.to contain_file('lmod-sh-load').with(
            ensure: 'file',
            path: moduels_bash_path,
            owner: 'root',
            group: 'root',
            mode: '0644',
          )
        end

        it do
          # Doesn't work exactly like I'd hope due to 'fi' at same indention level occurring more than once
          verify_contents(catalogue, 'lmod-sh-load', [
                            "    export MODULEPATH_ROOT=\"#{modulepath_root}\"",
                            '    export MODULEPATH=$(/usr/share/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/$LMOD_sys)',
                            '    export MODULEPATH=$(/usr/share/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/Core)',
                            '    export MODULEPATH=$(/usr/share/lmod/lmod/libexec/addto --append MODULEPATH /usr/share/lmod/lmod/modulefiles/Core)',
                            '    export MODULESHOME=/usr/share/lmod/lmod',
                            '    export BASH_ENV=$MODULESHOME/init/bash',
                            '    if [ -z "${MANPATH:-}" ]; then',
                            '      export MANPATH=:',
                            # '    fi',
                            '    export MANPATH=$(/usr/share/lmod/lmod/libexec/addto MANPATH /usr/share/lmod/lmod/share/man)',
                            '    export LMOD_AVAIL_STYLE=system',
                          ])
        end

        it do
          is_expected.to contain_file('lmod-csh-load').with(
            ensure: 'file',
            path: modules_csh_path,
            owner: 'root',
            group: 'root',
            mode: '0644',
          )
        end

        it do
          # Doesn't work exactly like I'd hope due to 'endif' at same indention level occurring more than once
          verify_contents(catalogue, 'lmod-csh-load', [
                            "    setenv MODULEPATH_ROOT      \"#{modulepath_root}\"",
                            '    setenv MODULEPATH           `/usr/share/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/$LMOD_sys`',
                            '    setenv MODULEPATH           `/usr/share/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/Core`',
                            '    setenv MODULEPATH           `/usr/share/lmod/lmod/libexec/addto --append MODULEPATH /usr/share/lmod/lmod/modulefiles/Core`',
                            '    setenv MODULESHOME          "/usr/share/lmod/lmod"',
                            '    setenv BASH_ENV             "$MODULESHOME/init/bash"',
                            '    if ( ! $?MANPATH ) then',
                            '      setenv MANPATH :',
                            # '    endif',
                            '    setenv MANPATH `/usr/share/lmod/lmod/libexec/addto MANPATH /usr/share/lmod/lmod/share/man`',
                            '    setenv LMOD_AVAIL_STYLE system',
                            'if ( -f  /usr/share/lmod/lmod/init/csh  ) then',
                            '  source /usr/share/lmod/lmod/init/csh',
                          ])
        end

        it { is_expected.to contain_file('/etc/profile.d/z00_StdEnv.sh').with_ensure('absent') }
        it { is_expected.to contain_file('z00_StdEnv.csh').with_ensure('absent') }

        context "when prefix => '/apps'" do
          let(:params) { { prefix: '/apps' } }

          it do
            verify_contents(catalogue, 'lmod-sh-load', [
                              "    export MODULEPATH_ROOT=\"#{modulepath_root}\"",
                              '    export MODULEPATH=$(/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/$LMOD_sys)',
                              '    export MODULEPATH=$(/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/Core)',
                              '    export MODULEPATH=$(/apps/lmod/lmod/libexec/addto --append MODULEPATH /apps/lmod/lmod/modulefiles/Core)',
                              '    export MODULESHOME=/apps/lmod/lmod',
                              '    export BASH_ENV=$MODULESHOME/init/bash',
                              '    if [ -z "${MANPATH:-}" ]; then',
                              '      export MANPATH=:',
                              # '    fi',
                              '    export MANPATH=$(/apps/lmod/lmod/libexec/addto MANPATH /apps/lmod/lmod/share/man)',
                              '    export LMOD_AVAIL_STYLE=system',
                            ])
          end

          it do
            verify_contents(catalogue, 'lmod-csh-load', [
                              "    setenv MODULEPATH_ROOT      \"#{modulepath_root}\"",
                              '    setenv MODULEPATH           `/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/$LMOD_sys`',
                              '    setenv MODULEPATH           `/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/Core`',
                              '    setenv MODULEPATH           `/apps/lmod/lmod/libexec/addto --append MODULEPATH /apps/lmod/lmod/modulefiles/Core`',
                              '    setenv MODULESHOME          "/apps/lmod/lmod"',
                              '    setenv BASH_ENV             "$MODULESHOME/init/bash"',
                              '    if ( ! $?MANPATH ) then',
                              '      setenv MANPATH :',
                              # '    endif',
                              '    setenv MANPATH `/apps/lmod/lmod/libexec/addto MANPATH /apps/lmod/lmod/share/man`',
                              '    setenv LMOD_AVAIL_STYLE system',
                              'if ( -f  /apps/lmod/lmod/init/csh  ) then',
                              '  source /apps/lmod/lmod/init/csh',
                            ])
          end
        end

        context "when modulepaths => ['Linux','Core','Compiler','MPI']" do
          let(:params) { { modulepaths: ['Linux', 'Core', 'Compiler', 'MPI'] } }

          it do
            verify_contents(catalogue, 'lmod-sh-load', [
                              '    export MODULEPATH=$(/usr/share/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/Linux)',
                              '    export MODULEPATH=$(/usr/share/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/Core)',
                              '    export MODULEPATH=$(/usr/share/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/Compiler)',
                              '    export MODULEPATH=$(/usr/share/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/MPI)',
                              '    export MODULEPATH=$(/usr/share/lmod/lmod/libexec/addto --append MODULEPATH /usr/share/lmod/lmod/modulefiles/Core)',
                            ])
          end

          it do
            verify_contents(catalogue, 'lmod-csh-load', [
                              '    setenv MODULEPATH           `/usr/share/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/Linux`',
                              '    setenv MODULEPATH           `/usr/share/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/Core`',
                              '    setenv MODULEPATH           `/usr/share/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/Compiler`',
                              '    setenv MODULEPATH           `/usr/share/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/MPI`',
                              '    setenv MODULEPATH           `/usr/share/lmod/lmod/libexec/addto --append MODULEPATH /usr/share/lmod/lmod/modulefiles/Core`',
                            ])
          end
        end

        context 'when set_lmod_package_path => true' do
          let(:params) { { set_lmod_package_path: true } }

          it do
            verify_contents(catalogue, 'lmod-sh-load', [
                              '    export LMOD_PACKAGE_PATH=$MODULEPATH_ROOT/Site',
                            ])
          end

          it do
            verify_contents(catalogue, 'lmod-csh-load', [
                              '    setenv LMOD_PACKAGE_PATH $MODULEPATH_ROOT/Site',
                            ])
          end
        end

        context 'when set_default_module => true' do
          let(:params) { { set_default_module: true } }

          it do
            is_expected.to contain_file('/etc/profile.d/z00_StdEnv.sh').with(
              ensure: 'file',
              path: '/etc/profile.d/z00_StdEnv.sh',
              owner: 'root',
              group: 'root',
              mode: '0644',
            )
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
            is_expected.to contain_file('z00_StdEnv.csh').with(
              ensure: 'file',
              path: stdenv_csh_path,
              owner: 'root',
              group: 'root',
              mode: '0644',
            )
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

          context "when default_module => 'foo'" do
            let(:params) { { set_default_module: true, default_module: 'foo' } }

            it 'exports LMOD_SYSTEM_DEFAULT_MODULES="foo"' do
              verify_contents(catalogue, '/etc/profile.d/z00_StdEnv.sh', [
                                '    export LMOD_SYSTEM_DEFAULT_MODULES="foo"',
                              ])
            end

            it 'setenvs LMOD_SYSTEM_DEFAULT_MODULES="foo"' do
              verify_contents(catalogue, 'z00_StdEnv.csh', [
                                '  setenv LMOD_SYSTEM_DEFAULT_MODULES "foo"',
                              ])
            end
          end
        end

        context "when avail_styles => ['grouped','system']" do
          let(:params) { { avail_styles: ['grouped', 'system'] } }

          it 'sets LMOD_AVAIL_STYLE=grouped:system' do
            verify_contents(catalogue, 'lmod-sh-load', [
                              '    export LMOD_AVAIL_STYLE=grouped:system',
                            ])
          end

          it 'sets LMOD_AVAIL_STYLE grouped:system' do
            verify_contents(catalogue, 'lmod-csh-load', [
                              '    setenv LMOD_AVAIL_STYLE grouped:system',
                            ])
          end
        end

        context 'when lmod_admin_file => /usr/share/lmod/etc/admin.list' do
          let(:params) { { lmod_admin_file: '/usr/share/lmod/etc/admin.list' } }

          it do
            verify_contents(catalogue, 'lmod-sh-load', [
                              '    export LMOD_AVAIL_STYLE=system',
                              '    export LMOD_ADMIN_FILE=/usr/share/lmod/etc/admin.list',
                              '  fi',
                            ])
          end

          it do
            verify_contents(catalogue, 'lmod-csh-load', [
                              '    setenv LMOD_AVAIL_STYLE system',
                              '    setenv LMOD_ADMIN_FILE /usr/share/lmod/etc/admin.list',
                              'endif',
                            ])
          end
        end

        context 'when system_name => foo' do
          let(:params) { { system_name: 'foo' } }

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

        context 'when site_name => foo' do
          let(:params) { { site_name: 'foo' } }

          it do
            verify_contents(catalogue, 'lmod-sh-load', [
                              '    export LMOD_SITE_NAME=foo',
                              '  fi',
                            ])
          end

          it do
            verify_contents(catalogue, 'lmod-csh-load', [
                              '    setenv LMOD_SITE_NAME foo',
                              'endif',
                            ])
          end
        end

        context 'when cached_loads => true' do
          let(:params) { { cached_loads: true } }

          it do
            verify_contents(catalogue, 'lmod-sh-load', [
                              '    export LMOD_CACHED_LOADS=yes',
                              '  fi',
                            ])
          end

          it do
            verify_contents(catalogue, 'lmod-csh-load', [
                              '    setenv LMOD_CACHED_LOADS yes',
                              'endif',
                            ])
          end
        end

        context 'ensure => absent' do
          let(:params) { { ensure: 'absent' } }

          it { is_expected.to contain_file('lmod-sh-load').with_ensure('absent') }
          it { is_expected.to contain_file('lmod-csh-load').with_ensure('absent') }
          it { is_expected.to contain_file('/etc/profile.d/z00_StdEnv.sh').with_ensure('absent') }
          it { is_expected.to contain_file('z00_StdEnv.csh').with_ensure('absent') }
        end
      end
    end
  end
end
