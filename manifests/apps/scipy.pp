# == Class: lmod::apps::scipy
#
class lmod::apps::scipy {
  include lmod

  $manage_build_packages = $::lmod::manage_build_packages

  ensure_packages($lmod::params::scipy_packages)
  ensure_packages($lmod::params::scipy_runtime_packages)
  if $manage_build_packages { ensure_packages($lmod::params::scipy_build_packages) }
}
