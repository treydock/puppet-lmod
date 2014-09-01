# == Class: lmod
#
# Public
#
class lmod (
  $prefix = '/opt/apps',
  $modulepath_root = 'UNSET',
  $modulepaths = [ '$LMOD_sys', 'Core' ],
  $set_lmod_package_path = true,
  $lmod_package_path = '${MODULEPATH_ROOT}/Site',
  $set_default_module = true,
  $default_module = 'StdEnv',
  $avail_styles = ['system'],
  $manage_build_packages = false,
  $modules_bash_template = 'lmod/modules.sh.erb',
  $modules_csh_template = 'lmod/modules.csh.erb',
) inherits lmod::params {

  validate_string($prefix)
  validate_string($modulepath_root)
  validate_string($lmod_package_path)
  validate_string($default_module)
  validate_string($modules_bash_template)
  validate_string($modules_csh_template)

  validate_array($modulepaths)
  validate_array($avail_styles)

  validate_bool($set_lmod_package_path)
  validate_bool($set_default_module)
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
