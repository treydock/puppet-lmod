# == Class: lmod::install
#
# Private
#
class lmod::install {

  include lmod

  ensure_packages($lmod::params::base_packages)
  ensure_packages($lmod::params::runtime_packages)
  if $lmod::manage_build_packages { ensure_packages($lmod::params::build_packages) }

}
