# == Class: lmod::load
#
# Private
#
class lmod::load {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  # Template uses:
  # - $_modulepath_root
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
  # - $_modulepath_root
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
      path    => '/etc/profile.d/z00_StdEnv.sh',
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
      ensure  => absent,
    }

    file { 'z00_StdEnv.csh':
      ensure => absent,
      path   => $lmod::stdenv_csh_path,
    }
  }

}
