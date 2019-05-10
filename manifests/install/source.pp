# @summary Install Lmod from source
# @api private
class lmod::install::source {
  assert_private()

  exec { "mkdir-${lmod::source_dir}":
    path    => '/usr/bin:/bin',
    command => "mkdir -p ${lmod::source_dir}",
    creates => $lmod::source_dir,
  }

  archive { "${lmod::source_dir}/${lmod::version}.tar.gz":
    source       => "https://github.com/TACC/Lmod/archive/${lmod::version}.tar.gz",
    extract      => true,
    extract_path => $lmod::source_dir,
    creates      => "${lmod::source_dir}/Lmod-${lmod::version}/configure",
    cleanup      => true,
    user         => 'root',
    group        => 'root',
    require      => Exec["mkdir-${lmod::source_dir}"],
    before       => File['lmod-configure'],
  }

  $default_with = delete_undef_values({
    'siteName' => $lmod::site_name,
    'module-root-path' => $lmod::modulepath_root,
  })
  $with_flags = ($default_with + $lmod::source_with_flags).map |$key, $value| { "--with-${key}='${value}'" }
  $with = join($with_flags, ' ')

  file { 'lmod-configure':
    ensure  => 'file',
    path    => "${lmod::source_dir}/Lmod-${lmod::version}/configure.sh",
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => join([
      '#!/bin/bash',
      '# File managed by Puppet, do not edit',
      "./configure --prefix=${lmod::prefix} ${with}",
      '',
    ], "\n"),
  }
  ~> exec { 'lmod-configure':
    path        => '/usr/bin:/bin:/usr/sbin:/sbin',
    command     => "${lmod::source_dir}/Lmod-${lmod::version}/configure.sh",
    cwd         => "${lmod::source_dir}/Lmod-${lmod::version}",
    refreshonly => true,
    logoutput   => true,
  }
  ~> exec { 'lmod-make-install':
    path        => '/usr/bin:/bin:/usr/sbin:/sbin',
    command     => 'make install',
    cwd         => "${lmod::source_dir}/Lmod-${lmod::version}",
    refreshonly => true,
  }
}
