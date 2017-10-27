# == Class: lmod
#
# Public
#
class lmod (
  Enum['present','absent'] $ensure                  = $lmod::params::ensure,
  String $package_ensure                            = 'present',
  Stdlib::Absolutepath $prefix                      = $lmod::params::prefix,
  Boolean $lmod_package_from_repo                   = $lmod::params::lmod_package_from_repo,
  Optional[Stdlib::Absolutepath] $modulepath_root   = $lmod::params::modulepath_root,
  Array $modulepaths                                = $lmod::params::modulepaths,
  Boolean $set_lmod_package_path                    = $lmod::params::set_lmod_package_path,
  String $lmod_package_path                         = $lmod::params::lmod_package_path,
  Boolean $set_default_module                       = $lmod::params::set_default_module,
  String $default_module                            = $lmod::params::default_module,
  Array $avail_styles                               = $lmod::params::avail_styles,
  Optional[Stdlib::Absolutepath] $lmod_admin_file   = $lmod::params::lmod_admin_file,
  Optional[String] $system_name                     = $lmod::params::system_name,
  Boolean $manage_build_packages                    = $lmod::params::manage_build_packages,
  Stdlib::Absolutepath $modules_bash_path           = $lmod::params::module_bash_path,
  String $modules_bash_template                     = $lmod::params::modules_bash_template,
  Optional[String] $modules_bash_source             = $lmod::params::modules_bash_source,
  Stdlib::Absolutepath $modules_csh_path            = $lmod::params::modules_csh_path,
  String $modules_csh_template                      = $lmod::params::modules_csh_template,
  Optional[String] $modules_csh_source              = $lmod::params::modules_csh_source,
  String $stdenv_bash_template                      = $lmod::params::stdenv_bash_template,
  Optional[String] $stdenv_bash_source              = $lmod::params::stdenv_bash_source,
  Stdlib::Absolutepath $stdenv_csh_path             = $lmod::params::stdenv_csh_path,
  String $stdenv_csh_template                       = $lmod::params::stdenv_csh_template,
  Optional[String] $stdenv_csh_source               = $lmod::params::stdenv_csh_source,
) inherits lmod::params {

  case $ensure {
    'present': {
      $_file_ensure = 'present'
    }
    'absent': {
      $_file_ensure = 'absent'
    }
    default: {
      # Do nothing
    }
  }

  $_modulepath_root = $modulepath_root ? {
    Undef   => "${prefix}/modulefiles",
    default => $modulepath_root,
  }

  if $modules_bash_source {
    $_modules_bash_source   = $modules_bash_source
    $_modules_bash_content  = undef
  } else {
    $_modules_bash_source   = undef
    $_modules_bash_content  = template($modules_bash_template)
  }

  if $modules_csh_source {
    $_modules_csh_source   = $modules_csh_source
    $_modules_csh_content  = undef
  } else {
    $_modules_csh_source   = undef
    $_modules_csh_content  = template($modules_csh_template)
  }

  if $stdenv_bash_source {
    $_stdenv_bash_source   = $stdenv_bash_source
    $_stdenv_bash_content  = undef
  } else {
    $_stdenv_bash_source   = undef
    $_stdenv_bash_content  = template($stdenv_bash_template)
  }

  if $stdenv_csh_source {
    $_stdenv_csh_source   = $stdenv_csh_source
    $_stdenv_csh_content  = undef
  } else {
    $_stdenv_csh_source   = undef
    $_stdenv_csh_content  = template($stdenv_csh_template)
  }

  anchor { 'lmod::start': }
  -> class { 'lmod::install': }
  -> class { 'lmod::load': }
  -> anchor { 'lmod::end': }

}
