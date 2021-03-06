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

  # Fix for Ubuntu 18.04 - https://bugs.launchpad.net/ubuntu/+source/lua-posix/+bug/1752082
  if $facts['os']['name'] == 'Ubuntu' and $facts['os']['release']['major'] == '18.04' and $lmod::ensure == 'present' {
    file { '/usr/lib/x86_64-linux-gnu/lua/5.2/posix.so':
      ensure => 'link',
      target => '/usr/lib/x86_64-linux-gnu/lua/5.2/posix_c.so',
    }
    if 'lua-posix' in $lmod::runtime_packages and $lmod::install_method != 'package' {
      Package['lua-posix'] -> File['/usr/lib/x86_64-linux-gnu/lua/5.2/posix.so']
    }
  }
}
