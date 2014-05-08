# == Class: lmod::install
#
class lmod::install {

  include lmod

  ensure_packages($lmod::params::base_packages)
  ensure_packages($lmod::params::lmod_runtime_packages)
  if $lmod::manage_build_packages { ensure_packages($lmod::params::lmod_build_packages) }

}
