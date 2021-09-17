# @summary Manage Lmod load config files
# @api private
class lmod::load {
  assert_private()

  # Remove files installed by OS where path maybe different
  if $facts['os']['family'] == 'RedHat' {
    if $lmod::modules_bash_path != '/etc/profile.d/00-modulepath.sh' {
      file { '/etc/profile.d/00-modulepath.sh': ensure => 'absent' }
    }
    if $lmod::modules_csh_path != '/etc/profile.d/00-modulepath.csh' {
      file { '/etc/profile.d/00-modulepath.csh': ensure => 'absent' }
    }
    if $lmod::modules_bash_path != '/etc/profile.d/z00_lmod.sh' {
      file { '/etc/profile.d/z00_lmod.sh': ensure => 'absent' }
    }
    if $lmod::modules_csh_path != '/etc/profile.d/z00_lmod.csh' {
      file { '/etc/profile.d/z00_lmod.csh': ensure => 'absent' }
    }
  }

  # Template uses:
  # - $modulepath_root
  # - $modulepaths
  # - $prefix
  # - $set_lmod_package_path
  # - $avail_styles
  # - $lmod_admin_file
  # - $ps_cmd
  # - $expr_cmd
  # - $basename_cmd
  file { 'lmod-sh-load':
    ensure  => $lmod::_file_ensure,
    path    => $lmod::modules_bash_path,
    content => $lmod::_modules_bash_content,
    source  => $lmod::_modules_bash_source,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  # Template uses:
  # - $modulepath_root
  # - $modulepaths
  # - $prefix
  # - $set_lmod_package_path
  # - $avail_styles
  # - $lmod_admin_file
  file { 'lmod-csh-load':
    ensure  => $lmod::_file_ensure,
    path    => $lmod::modules_csh_path,
    content => $lmod::_modules_csh_content,
    source  => $lmod::_modules_csh_source,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  if $lmod::set_default_module {
    # Template uses:
    # - $default_module
    file { '/etc/profile.d/z00_StdEnv.sh':
      ensure  => $lmod::_file_ensure,
      path    => $lmod::stdenv_bash_path,
      content => $lmod::_stdenv_bash_content,
      source  => $lmod::_stdenv_bash_source,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
    }

    # Template uses:
    # - $default_module
    file { 'z00_StdEnv.csh':
      ensure  => $lmod::_file_ensure,
      path    => $lmod::stdenv_csh_path,
      content => $lmod::_stdenv_csh_content,
      source  => $lmod::_stdenv_csh_source,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
    }
  } else {
    file { '/etc/profile.d/z00_StdEnv.sh':
      ensure => absent,
      path   => $lmod::stdenv_bash_path,
    }

    file { 'z00_StdEnv.csh':
      ensure => absent,
      path   => $lmod::stdenv_csh_path,
    }
  }

  if $facts['os']['name'] == 'Ubuntu' {
    $bashrc_line = 'if ! shopt -q login_shell; then if [ -d /etc/profile.d ]; then for i in /etc/profile.d/*.sh; do if [ -r $i ]; then . $i; fi; done; fi; fi'
    file_line { 'lmod-ubuntu-bashrc':
      ensure => 'present',
      path   => '/etc/bash.bashrc',
      line   => $bashrc_line,
      match  => '^if.*(login_shell|profile\.d).*fi$',
    }
  }
}
