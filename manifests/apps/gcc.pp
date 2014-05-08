# == Class: lmod::apps::gcc
#
class lmod::apps::gcc {
  include lmod

  $manage_build_packages = $::lmod::manage_build_packages

  ensure_packages($lmod::params::gcc_packages)
  ensure_packages($lmod::params::gcc_runtime_packages)
  if $manage_build_packages { ensure_packages($lmod::params::gcc_build_packages) }
}
