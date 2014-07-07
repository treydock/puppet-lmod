# == Class: lmod
#
class lmod (
  $prefix = '/opt/apps',
  $modulepath_root = 'UNSET',
  $modulepaths = [ '$LMOD_sys', 'Core' ],
  $set_lmod_package_path = true,
  $default_module = 'StdEnv',
  $manage_build_packages = false,
  $modules_bash_template = 'lmod/modules.sh.erb',
  $modules_csh_template = 'lmod/modules.csh.erb',
) inherits lmod::params {

  validate_bool($set_lmod_package_path)
  validate_bool($manage_build_packages)

  case $::osfamily {
    'RedHat': {
      include epel

      anchor { 'lmod::start': }->
      Yumrepo['epel']->
      class { 'lmod::install': }->
      class { 'lmod::load': }->
      anchor { 'lmod::end': }
    }

    default: {
      # Do nothing
    }
  }
}
