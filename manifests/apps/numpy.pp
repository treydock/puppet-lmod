# == Class: lmod::apps::numpy
#
class lmod::apps::numpy {
  include lmod

  $manage_build_packages = $::lmod::manage_build_packages

  ensure_packages($lmod::params::numpy_packages)
  ensure_packages($lmod::params::numpy_runtime_packages)
  if $manage_build_packages { ensure_packages($lmod::params::numpy_build_packages) }
}
