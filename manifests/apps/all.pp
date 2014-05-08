# == Class: lmod::apps::all
#
class lmod::apps::all {
  include lmod::apps::gcc
  include lmod::apps::openmpi
  include lmod::apps::ruby
}
