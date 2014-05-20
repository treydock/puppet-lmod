# == Class: lmod::load
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
class lmod::load {

  include lmod

  $_modulepath_root = $lmod::modulepath_root ? {
    'UNSET' => "${lmod::prefix}/modulefiles",
    default => $lmod::modulepath_root,
  }

  file { '/etc/profile.d/modules.sh':
    ensure  => present,
    path    => '/etc/profile.d/modules.sh',
    content => template('lmod/modules.sh.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  file { '/etc/profile.d/modules.csh':
    ensure  => present,
    path    => '/etc/profile.d/modules.csh',
    content => template('lmod/modules.csh.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  file { '/etc/profile.d/z00_StdEnv.sh':
    ensure  => absent,
  }

  file { '/etc/profile.d/z00_StdEnv.csh':
    ensure  => absent,
  }

}
