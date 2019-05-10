# @summary Manage Lmod
#
# @example To install Lmod from existing package repositories
#   class { 'lmod':
#      lmod_package_from_repo => true,
#    }
#
# @param ensure
#   The ensure parameter for this module.  If set to 'absent', managed files are removed.
#   If lmod_package_from_repo is true and ensure is 'absent', then the lmod package is also removed.
# @param package_ensure
#   The ensure value for Lmod package.  Only applies when lmod_package_from_repo is true.
# @param prefix
#   The prefix used when lmod was compiled.
# @param lmod_package_from_repo
#   Should the lmod package be installed from a apt/yum repository, or is
#   it installed separately with only dependencies installed from package repos?
# @param manage_epel
#   Boolean that determines if EPEL should be mananged by this module for systems installing Lmod via yum.
# @param package_name
#   Lmod package name if lmod_package_from_repo is true.
# @param base_packages
#   Packages necessary to build and use Lmod, only installed if lmod_package_from_repo is false
# @param runtime_packages
#   Lmod runtime package dependencies, only installed if lmod_package_from_repo is false
# @param build_packages
#   Lmod runtime devel package dependencies, only installed if manage_build_packages is true
# @param modulepath_root
#   The modulepath for your lmod installation.  Default is 'UNSET'.
#   If the value is 'UNSET' then the path $prefix/modulefiles is used.
# @param modulepaths
#   An Array of modulepaths to be defined in the module.sh and module.csh.
# @param set_lmod_package_path
#   Boolean that determines if the LMOD_PACKAGE_PATH environment variable should be set in modules.sh and modules.csh.
# @param lmod_package_path
#   Value given to the LMOD_PACKAGE_PATH environment variable in modules.sh and modules.csh.
# @param set_default_module
#   Boolean will disable the management of the files that define the default module.
# @param default_module
#   The name of the default module to be loaded when users login.
#   This will not be set if set_default_module is false.
# @param avail_styles
#   An Array used to set the LMOD_AVAIL_STYLES environment variable.
#   An empty Array prevents this environment variable from being set.
# @param lmod_admin_file
#   Defines path used for LMOD_ADMIN_FILE.
# @param system_name
#   Value used for LMOD_SYSTEM_NAME.
# @param site_name
#   Value used for LMOD_SITE_NAME.
# @param cached_loads
#   Value used for LMOD_CACHED_LOADS.
# @param manage_build_packages
#   Boolean that determines if the packages necessary to build lmod should be managed.
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
