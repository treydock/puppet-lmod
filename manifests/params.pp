# == Class: lmod::params
#
# The lmod configuration settings.
#
# Private
#
class lmod::params {
  $prefix                 = '/opt/apps'
  $modulepath_root        = 'UNSET'
  $modulepaths            = ['$LMOD_sys', 'Core']
  $set_lmod_package_path  = true
  $lmod_package_path      = '${MODULEPATH_ROOT}/Site'
  $set_default_module     = true
  $default_module         = 'StdEnv'
  $avail_styles           = ['system']
  $manage_build_packages  = false
  $modules_bash_template  = 'lmod/modules.sh.erb'
  $modules_csh_template   = 'lmod/modules.csh.erb'

  case $::osfamily {
    'RedHat': {
      $base_packages = [
        'lua-filesystem',
        'lua-json',
        'lua-posix',
        'lua-term',
        'zsh',
      ]
      $runtime_packages = [
        'lua',
      ]
      $build_packages = suffix($runtime_packages, '-devel')
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only support osfamily RedHat")
    }
  }

}
