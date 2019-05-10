# @summary Install Lmod package and dependencies
# @api private
class lmod::install {
  assert_private()

  if $lmod::lmod_package_from_repo {
    $package_ensure = $lmod::package_ensure
  } else {
    $package_ensure = 'present'
  }

  case $facts['os']['family'] {
    'RedHat': {
      if $lmod::manage_epel {
        include epel
        $package_require = Yumrepo['epel']
      } else {
        $package_require = undef
      }

      $_package_defaults = {
        'ensure'  => $package_ensure,
        'require' => $package_require,
      }
    }
    default: {
      $_package_defaults = {
        'ensure'  => $package_ensure,
      }
    }
  }

  if $lmod::lmod_package_from_repo {
    $_base_packages    = []
    $_runtime_packages = [ $lmod::package_name ]
  } else {
    $_base_packages    = $lmod::base_packages
    $_runtime_packages = $lmod::runtime_packages
  }

  if $lmod::ensure == 'present' {
    ensure_packages($_base_packages, delete_undef_values($_package_defaults))
    ensure_packages($_runtime_packages, delete_undef_values($_package_defaults))
    if $lmod::manage_build_packages {
      ensure_packages($lmod::build_packages, delete_undef_values($_package_defaults))
    }
  } elsif $lmod::ensure == 'absent' and $lmod::lmod_package_from_repo {
    ensure_packages($_runtime_packages, {'ensure' => 'absent'})
  }

}
