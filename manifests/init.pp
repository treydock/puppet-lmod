# == Class: lmod
#
# Public
#
class lmod (
  Enum['present','absent'] $ensure                  = 'present',
  String $package_ensure                            = 'present',
  Stdlib::Absolutepath $prefix                      = '/opt/apps',
  Boolean $lmod_package_from_repo                   = false,
  Boolean $manage_epel                              = true,
  String $package_name                              = 'Lmod',
  Array $base_packages                              = [],
  Array $runtime_packages                           = [],
  Array $build_packages                             = [],
  Optional[Stdlib::Absolutepath] $modulepath_root   = undef,
  Array $modulepaths                                = ['$LMOD_sys', 'Core'],
  Boolean $set_lmod_package_path                    = true,
  String $lmod_package_path                         = '$MODULEPATH_ROOT/Site',
  Boolean $set_default_module                       = true,
  String $default_module                            = 'StdEnv',
  Array $avail_styles                               = ['system'],
  Optional[Stdlib::Absolutepath] $lmod_admin_file   = undef,
  Optional[String] $system_name                     = undef,
  Optional[String] $site_name                       = undef,
  Optional[Boolean] $cached_loads                   = undef,
  Boolean $manage_build_packages                    = false,
  Stdlib::Absolutepath $modules_bash_path           = '/etc/profile.d/modules.sh',
  String $modules_bash_template                     = 'lmod/modules.sh.erb',
  Optional[String] $modules_bash_source             = undef,
  Stdlib::Absolutepath $modules_csh_path            = '/etc/profile.d/modules.csh',
  String $modules_csh_template                      = 'lmod/modules.csh.erb',
  Optional[String] $modules_csh_source              = undef,
  String $stdenv_bash_template                      = 'lmod/z00_StdEnv.sh.erb',
  Optional[String] $stdenv_bash_source              = undef,
  Stdlib::Absolutepath $stdenv_csh_path             = '/etc/profile.d/z00_StdEnv.csh',
  String $stdenv_csh_template                       = 'lmod/z00_StdEnv.csh.erb',
  Optional[String] $stdenv_csh_source               = undef,
) {

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
