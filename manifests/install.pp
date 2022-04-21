# @summary Install Lmod package and dependencies
# @api private
class lmod::install {
  assert_private()

  case $facts['os']['family'] {
    'RedHat': {
      if $lmod::manage_epel {
        include epel
        $package_require = Yumrepo['epel']
      } else {
        $package_require = undef
      }
    }
    default: {
      $package_require = undef
    }
  }

  case $lmod::install_method {
    'package': {
      $package_ensure = $lmod::ensure ? {
        'absent' => 'absent',
        default  => $lmod::package_ensure,
      }
      package { $lmod::package_name:
        ensure  => $package_ensure,
        require => $package_require,
      }
    }
    'source','none': {
      if $lmod::install_method == 'source' {
        include lmod::install::source
        Class['lmod::install'] -> Class['lmod::install::source']
      }
      if $lmod::ensure == 'present' {
        ensure_packages($lmod::runtime_packages, {'require' => $package_require})
        ensure_packages($lmod::build_packages, {'require' => $package_require})
      }
    }
    default: {
      # Do nothing
    }
  }

  # The 'lmod' package does not appear to pull in tcsh
  if $lmod::ensure =='present' and $lmod::install_method == 'package' and $facts['os']['family'] == 'Debian' {
    ensure_packages(['tcsh'])
  }

  if $lmod::manage_alternatives and
      $facts['os']['family'] == 'Debian' and $facts['os']['release']['major'] != '9' and
      $lmod::ensure == 'present' and $lmod::install_method != 'package' {
    if $facts['os']['release']['major'] == '18.04' {
      alternative_entry { '/usr/bin/luac5.3':
        ensure   => 'present',
        altlink  => '/usr/bin/luac',
        altname  => 'lua-compiler',
        priority => 10,
        before   => Alternatives['lua-compiler'],
      }
      alternative_entry { '/usr/bin/lua5.3':
        ensure   => 'present',
        altlink  => '/usr/bin/lua',
        altname  => 'lua-interpreter',
        priority => 10,
        before   => Alternatives['lua-interpreter'],
      }
    }
    alternatives { 'lua-compiler':
      path => '/usr/bin/luac5.3',
    }
    alternatives { 'lua-interpreter':
      path => '/usr/bin/lua5.3',
    }
    if 'lua5.3' in $lmod::runtime_packages {
      Package['lua5.3'] -> Alternatives['lua-compiler']
      Package['lua5.3'] -> Alternatives['lua-interpreter']
    }
    alternative_entry { '/usr/bin/tclsh8.6':
      ensure   => 'present',
      altlink  => '/usr/bin/tclsh',
      altname  => 'tclsh',
      priority => 10,
      before   => Alternatives['tclsh'],
    }
    alternatives { 'tclsh':
      path => '/usr/bin/tclsh8.6',
    }
    if 'tcl8.6' in $lmod::runtime_packages {
      Package['tcl8.6'] -> Alternative_entry['/usr/bin/tclsh8.6']
    }
  }

  # Fix for Ubuntu 18.04 - https://bugs.launchpad.net/ubuntu/+source/lua-posix/+bug/1752082
  if $facts['os']['name'] == 'Ubuntu' and $facts['os']['release']['major'] == '18.04' and $lmod::ensure == 'present' {
    if $lmod::install_method == 'package' {
      file { '/usr/lib/x86_64-linux-gnu/lua/5.2/posix.so':
        ensure => 'link',
        target => '/usr/lib/x86_64-linux-gnu/lua/5.2/posix_c.so',
      }
    } else {
      file { '/usr/lib/x86_64-linux-gnu/lua/5.3/posix.so':
        ensure => 'link',
        target => '/usr/lib/x86_64-linux-gnu/lua/5.3/posix_c.so',
      }
    }
    if 'lua-posix' in $lmod::runtime_packages and $lmod::install_method != 'package' {
      Package['lua-posix'] -> File['/usr/lib/x86_64-linux-gnu/lua/5.3/posix.so']
    }
  }
}
