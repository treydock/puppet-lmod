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
      '  export LMOD_SYSTEM_DEFAULT_MODULES=StdEnv',
      '  module --initial_load restore',
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
      'setenv LMOD_SYSTEM_DEFAULT_MODULES StdEnv',
      'module --initial_load restore',
    ])
  end

  it do
    should contain_file('/etc/profile.d/z00_StdEnv.sh').with_ensure('absent')
  end

  it do
    should contain_file('/etc/profile.d/z00_StdEnv.csh').with_ensure('absent')
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
        '  export LMOD_SYSTEM_DEFAULT_MODULES=StdEnv',
        '  module --initial_load restore',
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
        'setenv LMOD_SYSTEM_DEFAULT_MODULES StdEnv',
        'module --initial_load restore',
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

    it { should_not contain_file('/etc/profile.d/modules.sh').with_content(/export LMOD_PACKAGE_PATH/) }
    it { should_not contain_file('/etc/profile.d/modules.csh').with_content(/setenv LMOD_PACKAGE_PATH/) }
  end

  context "when default_module => 'foo'" do
    let(:pre_condition) { "class { 'lmod': default_module => 'foo' }" }

    it do
      verify_contents(catalogue, '/etc/profile.d/modules.sh', [
        '  export LMOD_SYSTEM_DEFAULT_MODULES=foo',
      ])
    end

    it do
      verify_contents(catalogue, '/etc/profile.d/modules.csh', [
        'setenv LMOD_SYSTEM_DEFAULT_MODULES foo',
      ])
    end
  end

  context "when default_module => false" do
    let(:pre_condition) { "class { 'lmod': default_module => false }" }

    it { should_not contain_file('/etc/profile.d/modules.sh').with_content(/export LMOD_SYSTEM_DEFAULT_MODULES/) }
    it { should_not contain_file('/etc/profile.d/modules.csh').with_content(/setenv LMOD_SYSTEM_DEFAULT_MODULES/) }
    it { should_not contain_file('/etc/profile.d/modules.sh').with_content(/module --initial_load restore/) }
    it { should_not contain_file('/etc/profile.d/modules.csh').with_content(/module --initial_load restore/) }
  end
end
