# == Class: lmod::apps::ruby
#
class lmod::apps::ruby {
  include lmod

  $manage_build_packages = $::lmod::manage_build_packages

  ensure_packages($lmod::params::ruby_packages)
  ensure_packages($lmod::params::ruby_runtime_packages)
  if $manage_build_packages { ensure_packages($lmod::params::ruby_build_packages) }
}
