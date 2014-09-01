# == Class: lmod::params
#
# The lmod configuration settings.
#
# Private
#
class lmod::params {

  case $::osfamily {
    'RedHat': {
      $base_packages = [
        'lua-filesystem',
        'lua-json',
        'lua-posix',
        'lua-term',
        'zsh',
      ]
      $runtime_packages = [
        'lua',
      ]
      $build_packages = suffix($runtime_packages, '-devel')
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only support osfamily RedHat")
    }
  }

}
