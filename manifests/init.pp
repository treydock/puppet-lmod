# == Class: lmod
#
# Public
#
class lmod (
  $prefix                 = $lmod::params::prefix,
  $modulepath_root        = $lmod::params::modulepath_root,
  $modulepaths            = $lmod::params::modulepaths,
  $set_lmod_package_path  = $lmod::params::set_lmod_package_path,
  $lmod_package_path      = $lmod::params::lmod_package_path,
  $set_default_module     = $lmod::params::set_default_module,
  $default_module         = $lmod::params::default_module,
  $avail_styles           = $lmod::params::avail_styles,
  $lmod_admin_file        = $lmod::params::lmod_admin_file,
  $manage_build_packages  = $lmod::params::manage_build_packages,
  $modules_bash_template  = $lmod::params::modules_bash_template,
  $modules_csh_template   = $lmod::params::modules_csh_template,
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
