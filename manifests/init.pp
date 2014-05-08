# == Class: lmod
#
# Full description of class lmod here.
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2014 Your name here, unless otherwise noted.
#
class lmod (
  $prefix = '/opt/apps',
  $modulepath_root = 'UNSET',
  $modulepaths = [ $::kernel, 'Core' ],
  $default_module = 'StdEnv',
  $manage_build_packages = false,
) inherits lmod::params {

  validate_bool($manage_build_packages)

  include lmod::load

  ensure_packages($lmod::params::base_packages)
  ensure_packages($lmod::params::lmod_runtime_packages)
  if $manage_build_packages { ensure_packages($lmod::params::lmod_build_packages) }

}
