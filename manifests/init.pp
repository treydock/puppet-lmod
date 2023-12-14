# @summary Manage Lmod
#
# @example To install Lmod from existing package repositories
#   class { 'lmod':
#      install_method => 'package',
#    }
#
# @param ensure
#   The ensure parameter for this module.  If set to 'absent', managed files are removed.
#   If lmod_package_from_repo is true and ensure is 'absent', then the lmod package is also removed.
# @param version
#   Version of Lmod to install when installing from source
# @param package_ensure
#   The ensure value for Lmod package.  Only applies when lmod_package_from_repo is true.
# @param prefix
#   The prefix used when lmod was compiled.
# @param install_method
#   How Lmod should be installed
# @param manage_epel
#   Boolean that determines if EPEL should be mananged by this module for systems installing Lmod via yum.
# @param source_dir
#   Directory to store Lmod source
# @param source_with_flags
#   Key/value pair of flags to turn into --with-<key>=<value> passed to configure when installing from source
# @param package_name
#   Lmod package name if lmod_package_from_repo is true.
# @param runtime_packages
#   Lmod runtime package dependencies, only installed if lmod_package_from_repo is false
# @param build_packages
#   Lmod runtime devel package dependencies, only installed if manage_build_packages is true
# @param manage_alternatives
#   Sets whether alternatives are managed by this module
#   Only used for Debian and Ubuntu systems
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
# @param modules_bash_path
#   Path to script to load bash modules environment
# @param modules_bash_template
#   Module bash load template
# @param modules_bash_source
#   Module bash load source
# @param modules_csh_path
#   Path to script to load csh modules environment
# @param modules_csh_template
#   Module csh load template
# @param modules_csh_source
#   Module csh load source
# @param stdenv_bash_path
#   Path to bash script that loads default modules
# @param stdenv_bash_template
#   Default module bash load template
# @param stdenv_bash_source
#   Default module bash load source
# @param stdenv_csh_path
#   Path to csh script that loads default modules
# @param stdenv_csh_template
#   Default module csh load template
# @param stdenv_csh_source
#   Default module bash load source
#
class lmod (
  Enum['present','absent'] $ensure                  = 'present',
  String $version                                   = '8.4.26',
  String $package_ensure                            = 'present',
  Stdlib::Absolutepath $prefix                      = '/usr/share',
  Enum['package','source','none'] $install_method   = 'package',
  Boolean $manage_epel                              = true,
  Stdlib::Absolutepath $source_dir                  = '/usr/src',
  Hash $source_with_flags                           = {},
  String $package_name                              = 'Lmod',
  Array $runtime_packages                           = [],
  Array $build_packages                             = [],
  Boolean $manage_alternatives                      = true,
  Optional[Stdlib::Absolutepath] $modulepath_root   = undef,
  Array $modulepaths                                = ['$LMOD_sys', 'Core'],
  Boolean $set_lmod_package_path                    = false,
  String $lmod_package_path                         = '$MODULEPATH_ROOT/Site',
  Boolean $set_default_module                       = false,
  String $default_module                            = 'StdEnv',
  Array $avail_styles                               = ['system'],
  Optional[Stdlib::Absolutepath] $lmod_admin_file   = undef,
  Optional[String] $system_name                     = undef,
  Optional[String] $site_name                       = undef,
  Optional[Boolean] $cached_loads                   = undef,
  Stdlib::Absolutepath $modules_bash_path           = '/etc/profile.d/modules.sh',
  String $modules_bash_template                     = 'lmod/modules.sh.erb',
  Optional[String] $modules_bash_source             = undef,
  Stdlib::Absolutepath $modules_csh_path            = '/etc/profile.d/modules.csh',
  String $modules_csh_template                      = 'lmod/modules.csh.erb',
  Optional[String] $modules_csh_source              = undef,
  Stdlib::Absolutepath $stdenv_bash_path            = '/etc/profile.d/z00_StdEnv.sh',
  String $stdenv_bash_template                      = 'lmod/z00_StdEnv.sh.erb',
  Optional[String] $stdenv_bash_source              = undef,
  Stdlib::Absolutepath $stdenv_csh_path             = '/etc/profile.d/z00_StdEnv.csh',
  String $stdenv_csh_template                       = 'lmod/z00_StdEnv.csh.erb',
  Optional[String] $stdenv_csh_source               = undef,
) {
  case $ensure {
    'present': {
      $_file_ensure = 'file'
    }
    'absent': {
      $_file_ensure = 'absent'
    }
    default: {
      # Do nothing
    }
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

  contain 'lmod::install'
  contain 'lmod::load'

  Class['lmod::install']
  -> Class['lmod::load']
}
