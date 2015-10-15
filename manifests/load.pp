# == Class: lmod::load
#
# Private
#
class lmod::load {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  file { '/etc/profile.d/modules.sh':
    ensure  => $lmod::_file_ensure,
    path    => '/etc/profile.d/modules.sh',
    content => $lmod::_modules_bash_content,
    source  => $lmod::_modules_bash_source,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  file { '/etc/profile.d/modules.csh':
    ensure  => $lmod::_file_ensure,
    path    => '/etc/profile.d/modules.csh',
    content => $lmod::_modules_csh_content,
    source  => $lmod::_modules_csh_source,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  if $lmod::set_default_module {
    file { '/etc/profile.d/z00_StdEnv.sh':
      ensure  => $lmod::_file_ensure,
      path    => '/etc/profile.d/z00_StdEnv.sh',
      content => $lmod::_stdenv_bash_content,
      source  => $lmod::_stdenv_bash_source,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
    }

    file { '/etc/profile.d/z00_StdEnv.csh':
      ensure  => $lmod::_file_ensure,
      path    => '/etc/profile.d/z00_StdEnv.csh',
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

    file { '/etc/profile.d/z00_StdEnv.csh':
      ensure  => absent,
    }
  }

}
