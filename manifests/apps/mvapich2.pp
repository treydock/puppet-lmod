# == Class: lmod::apps::mvapich2
#
class lmod::apps::mvapich2 {
  include lmod

  $manage_build_packages = $::lmod::manage_build_packages

  ensure_packages($lmod::params::mvapich2_packages)
  ensure_packages($lmod::params::mvapich2_runtime_packages)
  if $manage_build_packages { ensure_packages($lmod::params::mvapich2_build_packages) }
}
