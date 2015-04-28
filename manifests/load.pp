# == Class: lmod::load
#
# Private
#
class lmod::load {

  include lmod

  $_modulepath_root = $lmod::modulepath_root ? {
    'UNSET' => "${lmod::prefix}/modulefiles",
    default => $lmod::modulepath_root,
  }

  $prefix                 = $lmod::prefix
  $modulepaths            = $lmod::modulepaths
  $set_lmod_package_path  = $lmod::set_lmod_package_path
  $lmod_package_path      = $lmod::lmod_package_path
  $default_module         = $lmod::default_module
  $avail_styles           = $lmod::avail_styles
  $lmod_admin_file        = $lmod::lmod_admin_file

  file { '/etc/profile.d/modules.sh':
    ensure  => present,
    path    => '/etc/profile.d/modules.sh',
    content => template($lmod::modules_bash_template),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  file { '/etc/profile.d/modules.csh':
    ensure  => present,
    path    => '/etc/profile.d/modules.csh',
    content => template($lmod::modules_csh_template),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  if $lmod::set_default_module {
    file { '/etc/profile.d/z00_StdEnv.sh':
      ensure  => present,
      path    => '/etc/profile.d/z00_StdEnv.sh',
      content => template($lmod::stdenv_bash_template),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
    }

    file { '/etc/profile.d/z00_StdEnv.csh':
      ensure  => present,
      path    => '/etc/profile.d/z00_StdEnv.csh',
      content => template($lmod::stdenv_csh_template),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
    }
  } else {
    file { '/etc/profile.d/z00_StdEnv.sh':
      ensure  => absent,
    }

    file { '/etc/profile.d/z00_StdEnv.csh':
      ensure  => absent,
    }
  }

}
