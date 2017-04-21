# puppet-lmod

[![Build Status](https://travis-ci.org/treydock/puppet-lmod.png)](https://travis-ci.org/treydock/puppet-lmod)

## Overview

The lmod module handles the configuration of a system to use Lmod.  Additional details regarding Lmod can be found at https://www.tacc.utexas.edu/tacc-projects/lmod.

## Usage

### lmod

The default parameter values are suitable for compute nodes using Lmod.

    class { 'lmod': }

This is an example of how to configure package building nodes to use Lmod.

    class { 'lmod':
      manage_build_packages => true,
    }

To customize the avail layout (since Lmod 5.7.5)

    class { 'lmod':
      avail_style => ['grouped', 'system'],
    }

To install Lmod from existing package repositories

    class { 'lmod':
      lmod_package_from_repo => true,
    }

## Reference

### Classes

#### Public classes

* `lmod`: Installs the packages and /etc/profile.d files necessary to use lmod

#### Private classes

* `lmod::install`: Installs the packages necessary to build and use lmod.
* `lmod::load`: Manages the files under /etc/profile.d
* `lmod::params`: Defines default values

### Parameters

#### lmod

#####`ensure`

The ensure parameter for this module.  If set to 'absent', managed files are removed.
If `lmod_package_from_repo` is true and `ensure` is 'absent', then the lmod package is also removed.
Default is `present`.

#####`prefix`

The prefix used when lmod was compiled.  Default is '/opt/apps'.

#####`lmod_package_from_repo`

Should the lmod package be installed from a apt/yum repository, or is
it installed separately with only dependencies installed from package
repos?

#####`modulepath_root`

The modulepath for your lmod installation.  Default is 'UNSET'.

If the value is 'UNSET' then the path `$prefix/modulefiles` is used.

#####`modulepaths`

An Array of modulepaths to be defined in the module.sh and module.csh.  Default is ['$LMOD_sys','Core'].

#####`set_lmod_package_path`

Boolean that determines if the `LMOD_PACKAGE_PATH` environment variable should be set in modules.sh and modules.csh.  Default is true.

#####`lmod_package_path`

Value given to the `LMOD_PACKAGE_PATH` environment variable in modules.sh and modules.csh.  Default is '${MODULEPATH_ROOT}/Site'.

#####`set_default_module`

Boolean will disable the management of the files that define the default module.  Defaults to true.

#####`default_module`

The name of the default module to be loaded when users login.  Default is 'StdEnv'.

This will not be set if `set_default_module` is false.

#####`avail_styles`

An Array used to set the LMOD_AVAIL_STYLES environment variable.  An empty Array prevents this environment variable from being set.

Default is ['system'].

#####`manage_build_packages`

Boolean that determines if the packages necessary to build lmod should be managed.  Default is false.

## Compatibility

Tested using

* CentOS 6.5
* Ubuntu 14.04, 16.04

## Development

### Testing

Testing requires the following dependencies:

* rake
* bundler

Install gem dependencies

    bundle install

Run unit tests

    bundle exec rake test

If you have Vagrant >= 1.2.0 installed you can run system tests

    bundle exec rake beaker

## TODO
