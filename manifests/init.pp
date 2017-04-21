# == Class: lmod
#
# Public
#
class lmod (
  $ensure                 = $lmod::params::ensure,
  $prefix                 = $lmod::params::prefix,
  $lmod_package_from_repo = $lmod::params::lmod_package_from_repo,
  $modulepath_root        = $lmod::params::modulepath_root,
  $modulepaths            = $lmod::params::modulepaths,
  $set_lmod_package_path  = $lmod::params::set_lmod_package_path,
  $lmod_package_path      = $lmod::params::lmod_package_path,
  $set_default_module     = $lmod::params::set_default_module,
  $default_module         = $lmod::params::default_module,
  $avail_styles           = $lmod::params::avail_styles,
  $lmod_admin_file        = $lmod::params::lmod_admin_file,
  $system_name            = $lmod::params::system_name,
  $manage_build_packages  = $lmod::params::manage_build_packages,
  $modules_bash_path      = $lmod::params::module_bash_path,
  $modules_bash_template  = $lmod::params::modules_bash_template,
  $modules_bash_source    = $lmod::params::modules_bash_source,
  $modules_csh_path       = $lmod::params::modules_csh_path,
  $modules_csh_template   = $lmod::params::modules_csh_template,
  $modules_csh_source     = $lmod::params::modules_csh_source,
  $stdenv_bash_template   = $lmod::params::stdenv_bash_template,
  $stdenv_bash_source     = $lmod::params::stdenv_bash_source,
  $stdenv_csh_path        = $lmod::params::stdenv_csh_path,
  $stdenv_csh_template    = $lmod::params::stdenv_csh_template,
  $stdenv_csh_source      = $lmod::params::stdenv_csh_source,
) inherits lmod::params {

  validate_string($prefix)
  validate_string($modulepath_root)
  validate_string($lmod_package_path)
  validate_string($default_module)
  validate_string($modules_bash_path)
  validate_string($modules_bash_template)
  validate_string($modules_csh_path)
  validate_string($modules_csh_template)
  validate_string($stdenv_bash_template, $stdenv_csh_template)
  validate_string($stdenv_csh_path)

  validate_array($modulepaths)
  validate_array($avail_styles)

  validate_bool($set_lmod_package_path)
  validate_bool($set_default_module)
  validate_bool($manage_build_packages)
  validate_bool($lmod_package_from_repo)

  case $ensure {
    'present': {
      $_file_ensure = 'present'
    }
    'absent': {
      $_file_ensure = 'absent'
    }
    default: {
      fail("Module ${module_name}, ensure must be 'present' or 'absent', ${ensure} given.")
    }
  }

  $_modulepath_root = $modulepath_root ? {
    'UNSET' => "${prefix}/modulefiles",
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
