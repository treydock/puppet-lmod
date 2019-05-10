# puppet-lmod

[![Puppet Forge](http://img.shields.io/puppetforge/v/treydock/lmod.svg)](https://forge.puppetlabs.com/treydock/lmod)
[![CI Status](https://github.com/treydock/puppet-lmod/workflows/CI/badge.svg?branch=master)](https://github.com/treydock/puppet-lmod/actions?query=workflow%3ACI)

## Overview

The lmod module handles the configuration of a system to use Lmod.  Additional details regarding Lmod can be found at http://lmod.readthedocs.io/en/latest/index.html.

## Usage

### lmod

Install Lmod through package repositories:

```puppet
class { 'lmod': }
```

This is an example install Lmod from source.

```puppet
class { 'lmod':
  prefix            => '/apps',
  moduleroot_path   => '/apps/modulefiles',
  version           => '8.4.26',
  install_method    => 'source',
  source_with_flags => {
    'spiderCacheDir' => '/apps/lmodcache/cacheDir',
    'updateSystemFn' => '/apps/lmodcache/system.txt',
  },
}
```

If you wish to manage the Lmod install outside Puppet:

```puppet
class { 'lmod':
  prefix            => '/apps',
  moduleroot_path   => '/apps/modulefiles',
  install_method    => 'none',
}
```

To customize the avail layout (since Lmod 5.7.5)

```puppet
class { 'lmod':
  avail_style => ['grouped', 'system'],
}
```

Below is an example that adds several paths to default MODULEPATH, sets a default module, sets LMOD\_PACKAGE\_PATH and sets LMOD\_SYSTEM\_NAME.

```puppet
class { 'lmod':
  modulepaths            => ['$LMOD_sys', 'Core'],
  set_lmod_package_path  => true,
  set_default_module     => true,
  default_module         => 'mycluster',
}
```

## Reference

[http://treydock.github.io/puppet-lmod/](http://treydock.github.io/puppet-lmod/)

## Compatibility

Tested using

* CentOS/RedHat 7, 8
* Ubuntu 16.04, 18.04, 20.04
* Debian 9, 10
