# == Class: lmod::install
#
# Private
#
class lmod::install {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  case $::osfamily {
    'RedHat': {
      include epel

      $_package_defaults = {
        'require' => 'Yumrepo[epel]',
      }
    }
    default: {
      $_package_defaults = {}
    }
  }

  ensure_packages($lmod::params::base_packages, $_package_defaults)
  ensure_packages($lmod::params::runtime_packages, $_package_defaults)
  if $lmod::manage_build_packages { ensure_packages($lmod::params::build_packages, $_package_defaults) }

}
