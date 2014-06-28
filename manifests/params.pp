# == Class: lmod::params
#
# The lmod configuration settings.
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if it
#   has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should not be used in preference to class parameters  as of
#   Puppet 2.6.)
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2014 Your name here, unless otherwise noted.
#
class lmod::params {

  case $::osfamily {
    'RedHat': {
      $base_packages = [
        'lua-filesystem',
        'lua-posix',
        'zsh',
      ]
      $lmod_runtime_packages = [
        'lua',
      ]
      $lmod_build_packages = suffix($lmod_runtime_packages, '-devel')

      ## GCC ##
      $gcc_packages = [
        'texinfo',
        'dejagnu',
      ]
      $gcc_runtime_packages = [
        'gmp',
        'libmpc',
        'mpfr',
        'libgcj',
        'elfutils-libelf',
        'ppl',
        'cloog-ppl',
      ]
      $gcc_build_packages = suffix($gcc_runtime_packages, '-devel')

      ## OpenMPI ##
      $openmpi_packages = []
      $openmpi_runtime_packages = [
        'libibverbs',
        'valgrind',
        'numactl',
        'db4',
        'libX11',
        'papi',
        'pciutils',
        'hwloc',
        'libtool-ltdl',
      ]
      $openmpi_build_packages = suffix($openmpi_runtime_packages, '-devel')

      ## MVAPICH2 ##
      $mvapich2_packages = []
      $mvapich2_runtime_packages = [
        'libibmad',
        'libpciaccess',
      ]
      $mvapich2_build_packages = suffix($mvapich2_runtime_packages, '-devel')

      ## Ruby ##
      $ruby_packages = [
        'systemtap-sdt-devel',
      ]
      $ruby_runtime_packages = [
        'commoncpp2',
        'libaio',
      ]
      $ruby_build_packages = suffix($ruby_runtime_packages, '-devel')

      ## NumPy ##
      $numpy_packages = [
        'python-nose',
      ]
      $numpy_runtime_packages = []
      $numpy_build_packages = suffix($numpy_runtime_packages, '-devel')

      ## SciPy ##
      $scipy_packages = [
        'ipython',
        'python-nose',
        'python-matplotlib',
      ]
      $scipy_runtime_packages = []
      $scipy_build_packages = suffix($scipy_runtime_packages, '-devel')
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only support osfamily RedHat")
    }
  }

}
