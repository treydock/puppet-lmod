# == Class: lmod::params
#
# The lmod configuration settings.
#
# Private
#
class lmod::params {
  $ensure                 = 'present'
  $prefix                 = '/opt/apps'
  $lmod_package_from_repo = false
  $modulepath_root        = 'UNSET'
  $modulepaths            = ['$LMOD_sys', 'Core']
  $set_lmod_package_path  = true
  $lmod_package_path      = '$MODULEPATH_ROOT/Site'
  $set_default_module     = true
  $default_module         = 'StdEnv'
  $avail_styles           = ['system']
  $lmod_admin_file        = undef
  $system_name            = undef
  $manage_build_packages  = false
  $module_bash_path       = '/etc/profile.d/modules.sh'
  $modules_bash_template  = 'lmod/modules.sh.erb'
  $modules_bash_source    = undef
  $modules_csh_template   = 'lmod/modules.csh.erb'
  $modules_csh_source     = undef
  $stdenv_bash_template   = 'lmod/z00_StdEnv.sh.erb'
  $stdenv_bash_source     = undef
  $stdenv_csh_template    = 'lmod/z00_StdEnv.csh.erb'
  $stdenv_csh_source      = undef

  $ps_cmd       = '/bin/ps'
  $expr_cmd     = '/bin/expr'
  $basename_cmd = '/bin/basename'

  case $::osfamily {
    'RedHat': {
      $modules_csh_path = '/etc/profile.d/modules.csh'
      $stdenv_csh_path = '/etc/profile.d/z00_StdEnv.csh'
      $package_name = 'Lmod'
      if $::operatingsystemmajrelease == '5' {
        $base_packages = [
          'lua-filesystem',
          'lua-posix',
          'tcl',
          'zsh',
        ]
      } else {
        $base_packages = [
          'lua-filesystem',
          'lua-json',
          'lua-posix',
          'lua-term',
          'tcl',
          'zsh',
        ]
      }

      $runtime_packages = [
        'lua',
      ]
      $build_packages = suffix($runtime_packages, '-devel')
    }

    'Debian': {
      $modules_csh_path = '/etc/csh/login.d/modules.csh'
      $stdenv_csh_path = '/etc/csh/login.d/z00_StdEnv.csh'
      $package_name = 'lmod'
      if $::operatingsystemmajrelease == '14.04' {
        $base_packages = [
          'lua-filesystem',
          'lua-json',
          'lua-posix',
          'tcl',
          'zsh',
        ]
      } else {
        $base_packages = [
          'lua-filesystem',
          'lua-json',
          'lua-posix',
          'lua-term',
          'tcl',
          'zsh',
        ]
      }

      $runtime_packages = [ 'lua5.2' ]
      $build_packages = [
        'liblua5.2-dev',
        'lua-filesystem-dev',
        'lua-posix-dev'
      ]
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only support osfamily RedHat or Debian")
    }
  }

}
