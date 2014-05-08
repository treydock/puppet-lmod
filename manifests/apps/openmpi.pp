# == Class: lmod::apps::openmpi
#
class lmod::apps::openmpi {
  include lmod
  include java

  $manage_build_packages = $::lmod::manage_build_packages

  ensure_packages($lmod::params::openmpi_packages)
  ensure_packages($lmod::params::openmpi_runtime_packages)
  if $manage_build_packages { ensure_packages($lmod::params::openmpi_build_packages) }
}
