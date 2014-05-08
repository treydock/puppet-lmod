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
  $modulepaths = [ '$LMOD_sys', 'Core' ],
  $lmod_package_path = true,
  $default_module = 'StdEnv',
  $manage_build_packages = false,
) inherits lmod::params {

  validate_bool($lmod_package_path)
  validate_bool($manage_build_packages)

  anchor { 'lmod::start': }
  anchor { 'lmod::end': }

  include epel
  include lmod::install
  include lmod::load

  case $::osfamily {
    'RedHat': {
      Anchor['lmod::start']->
      Class['epel']->
      Class['lmod::install']->
      Class['lmod::load']->
      Anchor['lmod::end']
    }

    default: {
      # Do nothing
    }
  }
}
