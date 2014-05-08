# puppet-lmod

[![Build Status](https://travis-ci.org/treydock/puppet-lmod.png)](https://travis-ci.org/treydock/puppet-lmod)

## Overview

The lmod module handles the configuration of a system to use Lmod.  Additional details regarding Lmod can be found at https://www.tacc.utexas.edu/tacc-projects/lmod.

## Usage

### lmod

The default parameter values are suitable for compute nodes using Lmod.

    class { 'lmod': }

This is an example of how to configure headnodes to use Lmod.

    class { 'lmod':
      manage_build_packages => true,
    }

### Apps

Include all the `lmod::apps` classes

    class { 'lmod::apps::all': }

## Reference

### Classes

#### Public classes

* `lmod`: Installs the packages and /etc/profile.d files necessary to use lmod
* `lmod::apps::all`: Includes all classes in the `lmod::apps` namespace
* `lmod::apps::gcc`: Installs the packages necessary to use and build a gcc module
* `lmod::apps::openmpi`: Installs the packages necessary to use and build an openmpi module
* `lmod::apps::ruby`: Installs the packages necessary to use and build a ruby module

#### Private classes

* `lmod::load`: Manages the files under /etc/profile.d
* `lmod::params`: Defines default values

### Parameters

#### lmod

#####`prefix`

The prefix used when lmod was compiled.  Default is '/opt/apps'.

#####`modulepath_root`

The modulepath for your lmod installation.  Default is 'UNSET'.

If the value is 'UNSET' then the path `$prefix/modulefiles` is used.

#####`modulepaths`

An Array of modulepaths to be defined in the module.sh and module.csh.  Default is ['$LMOD_sys','Core'].

#####`lmod_package_path`

Boolean that determines if the `LMOD_PACKAGE_PATH` environment variable should be set in modules.sh and modules.csh.  Default is true.

#####`default_module`

The name of the default module to be loaded when users login.  Default is 'StdEnv'.

A boolean value of false will disable the management of the files that define the default module.

#####`manage_build_packages`

Boolean that determines if the packages necessary to build lmod should be managed.  Default is false.

This parameter also determines if the classes in the `lmod::apps` namespace will manage 'devel' packages.

## Compatibility

Tested using

* CentOS 6.5

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

    bundle exec rake acceptance

## TODO

* Add additional classes to the `lmod::apps` namespace