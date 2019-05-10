# puppet-lmod

[![Puppet Forge](http://img.shields.io/puppetforge/v/treydock/lmod.svg)](https://forge.puppetlabs.com/treydock/lmod)
[![Build Status](https://travis-ci.org/treydock/puppet-lmod.png)](https://travis-ci.org/treydock/puppet-lmod)

## Overview

The lmod module handles the configuration of a system to use Lmod.  Additional details regarding Lmod can be found at http://lmod.readthedocs.io/en/latest/index.html.

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

Below is an example that adds several paths to default MODULEPATH, sets a default module, sets LMOD\_PACKAGE\_PATH and sets LMOD\_SYSTEM\_NAME.

    class { 'lmod':
      lmod_package_from_repo => true,
      modulepaths            => ['$LMOD_sys', 'Core'],
      set_lmod_package_path  => true,
      set_default_module     => true,
      default_module         => 'mycluster',
    }

## Reference

[http://treydock.github.io/puppet-lmod/](http://treydock.github.io/puppet-lmod/)

## Compatibility

Tested using

* CentOS/RedHat 6, 7
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
