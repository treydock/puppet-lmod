require 'spec_helper'

describe 'lmod::load' do
  include_context :defaults

  let(:facts) { default_facts }

  let(:pre_condition) { "class { 'lmod': }" }

  it { should create_class('lmod::load') }
  it { should contain_class('lmod') }

  it do
    should contain_file('/etc/profile.d/modules.sh').with({
      :ensure  => 'present',
      :path    => '/etc/profile.d/modules.sh',
      :owner   => 'root',
      :group   => 'root',
      :mode    => '0644',
    })
  end

  it do
    verify_contents(catalogue, '/etc/profile.d/modules.sh', [
      '    MODULEPATH_ROOT="/opt/apps/modulefiles"',
      '    export MODULEPATH=$(/opt/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/$LMOD_sys)',
      '    export MODULEPATH=$(/opt/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/Core)',
      '    export MODULEPATH=$(/opt/apps/lmod/lmod/libexec/addto --append MODULEPATH /opt/apps/lmod/lmod/modulefiles/Core)',
      '    export BASH_ENV=/opt/apps/lmod/lmod/init/bash',
      '    export LMOD_PACKAGE_PATH=${MODULEPATH_ROOT}/Site',
      '  . /opt/apps/lmod/lmod/init/bash >/dev/null # Module Support',
    ])
  end

  it do
    should contain_file('/etc/profile.d/modules.csh').with({
      :ensure  => 'present',
      :path    => '/etc/profile.d/modules.csh',
      :owner   => 'root',
      :group   => 'root',
      :mode    => '0644',
    })
  end

  it do
    verify_contents(catalogue, '/etc/profile.d/modules.csh', [
      '    setenv MODULEPATH_ROOT      "/opt/apps/modulefiles"',
      '    setenv MODULEPATH           `/opt/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/$LMOD_sys`',
      '    setenv MODULEPATH           `/opt/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/Core`',
      '    setenv MODULEPATH           `/opt/apps/lmod/lmod/libexec/addto --append MODULEPATH /opt/apps/lmod/lmod/modulefiles/Core`',
      '    setenv BASH_ENV /opt/apps/lmod/lmod/init/bash',
      '    setenv LMOD_PACKAGE_PATH ${MODULEPATH_ROOT}/Site',
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
      'if [ -z "$__Init_Default_Modules" ]; then',
      '  __Init_Default_Modules=1; export __Init_Default_Modules;',
      '  module getdefault default || module load StdEnv',
      'fi',
    ])
  end

  it do
    should contain_file('/etc/profile.d/z00_StdEnv.csh').with({
      :ensure  => 'present',
      :path    => '/etc/profile.d/z00_StdEnv.csh',
      :owner   => 'root',
      :group   => 'root',
      :mode    => '0644',
    })
  end

  it do
    verify_contents(catalogue, '/etc/profile.d/z00_StdEnv.csh', [
      'if ( ! $?__Init_Default_Modules ) then',
      '  module getdefault default',
      '  if ( $status != 0 ) then',
      '    module load StdEnv',
      '  endif',
      '  setenv __Init_Default_Modules 1',
      'endif',
    ])
  end

  context "when prefix => '/apps'" do
    let(:pre_condition) { "class { 'lmod': prefix => '/apps' }" }

    it do
      verify_contents(catalogue, '/etc/profile.d/modules.sh', [
        '    MODULEPATH_ROOT="/apps/modulefiles"',
        '    export MODULEPATH=$(/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/$LMOD_sys)',
        '    export MODULEPATH=$(/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/Core)',
        '    export MODULEPATH=$(/apps/lmod/lmod/libexec/addto --append MODULEPATH /apps/lmod/lmod/modulefiles/Core)',
        '    export BASH_ENV=/apps/lmod/lmod/init/bash',
        '    export LMOD_PACKAGE_PATH=${MODULEPATH_ROOT}/Site',
        '  . /apps/lmod/lmod/init/bash >/dev/null # Module Support',
      ])
    end

    it do
      verify_contents(catalogue, '/etc/profile.d/modules.csh', [
        '    setenv MODULEPATH_ROOT      "/apps/modulefiles"',
        '    setenv MODULEPATH           `/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/$LMOD_sys`',
        '    setenv MODULEPATH           `/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/Core`',
        '    setenv MODULEPATH           `/apps/lmod/lmod/libexec/addto --append MODULEPATH /apps/lmod/lmod/modulefiles/Core`',
        '    setenv BASH_ENV /apps/lmod/lmod/init/bash',
        '    setenv LMOD_PACKAGE_PATH ${MODULEPATH_ROOT}/Site',
        'if ( -f  /apps/lmod/lmod/init/csh  ) then',
        '  source /apps/lmod/lmod/init/csh',
      ])
    end
  end

  context "when modulepaths => ['Linux','Core','Compiler','MPI']" do
    let(:pre_condition) { "class { 'lmod': modulepaths => ['Linux','Core','Compiler','MPI'] }" }

    it do
      verify_contents(catalogue, '/etc/profile.d/modules.sh', [
        '    export MODULEPATH=$(/opt/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/Linux)',
        '    export MODULEPATH=$(/opt/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/Core)',
        '    export MODULEPATH=$(/opt/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/Compiler)',
        '    export MODULEPATH=$(/opt/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/MPI)',
        '    export MODULEPATH=$(/opt/apps/lmod/lmod/libexec/addto --append MODULEPATH /opt/apps/lmod/lmod/modulefiles/Core)',
      ])
    end

    it do
      verify_contents(catalogue, '/etc/profile.d/modules.csh', [
        '    setenv MODULEPATH           `/opt/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/Linux`',
        '    setenv MODULEPATH           `/opt/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/Core`',
        '    setenv MODULEPATH           `/opt/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/Compiler`',
        '    setenv MODULEPATH           `/opt/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/MPI`',
        '    setenv MODULEPATH           `/opt/apps/lmod/lmod/libexec/addto --append MODULEPATH /opt/apps/lmod/lmod/modulefiles/Core`',
      ])
    end
  end

  context "when lmod_package_path => false" do
    let(:pre_condition) { "class { 'lmod': lmod_package_path => false }" }

    it do
      verify_contents(catalogue, '/etc/profile.d/modules.sh', [
        '    MODULEPATH_ROOT="/opt/apps/modulefiles"',
        '    export MODULEPATH=$(/opt/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/$LMOD_sys)',
        '    export MODULEPATH=$(/opt/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/Core)',
        '    export MODULEPATH=$(/opt/apps/lmod/lmod/libexec/addto --append MODULEPATH /opt/apps/lmod/lmod/modulefiles/Core)',
        '    export BASH_ENV=/opt/apps/lmod/lmod/init/bash',
        '  . /opt/apps/lmod/lmod/init/bash >/dev/null # Module Support',
      ])
    end

    it do
      verify_contents(catalogue, '/etc/profile.d/modules.csh', [
        '    setenv MODULEPATH_ROOT      "/opt/apps/modulefiles"',
        '    setenv MODULEPATH           `/opt/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/$LMOD_sys`',
        '    setenv MODULEPATH           `/opt/apps/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/Core`',
        '    setenv MODULEPATH           `/opt/apps/lmod/lmod/libexec/addto --append MODULEPATH /opt/apps/lmod/lmod/modulefiles/Core`',
        '    setenv BASH_ENV /opt/apps/lmod/lmod/init/bash',
        'if ( -f  /opt/apps/lmod/lmod/init/csh  ) then',
        '  source /opt/apps/lmod/lmod/init/csh',
      ])
    end
  end

  context "when default_module => 'foo'" do
    let(:pre_condition) { "class { 'lmod': default_module => 'foo' }" }

    it do
      verify_contents(catalogue, '/etc/profile.d/z00_StdEnv.sh', [
        'if [ -z "$__Init_Default_Modules" ]; then',
        '  __Init_Default_Modules=1; export __Init_Default_Modules;',
        '  module getdefault default || module load foo',
        'fi',
      ])
    end

    it do
      verify_contents(catalogue, '/etc/profile.d/z00_StdEnv.csh', [
        'if ( ! $?__Init_Default_Modules ) then',
        '  module getdefault default',
        '  if ( $status != 0 ) then',
        '    module load foo',
        '  endif',
        '  setenv __Init_Default_Modules 1',
        'endif',
      ])
    end
  end

  context "when default_module => false" do
    let(:pre_condition) { "class { 'lmod': default_module => false }" }

    it { should_not contain_file('/etc/profile.d/z00_StdEnv.sh') }
    it { should_not contain_file('/etc/profile.d/z00_StdEnv.csh') }
  end
end
