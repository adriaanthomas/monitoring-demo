# TODO this module now makes statsd run under root, must use a different user
class statsd {
  require wget

  File {
    owner => root,
    group => root,
    mode  => 0444,
  }

  package { 'nodejs':
    ensure => latest, # ugh
    notify => Service['statsd'],
  } ->

  file { '/opt/statsd':
    ensure => directory,
  } ->

  wget::fetch { 'statsd.tar.gz':
    source      => 'https://github.com/etsy/statsd/archive/v0.7.1.tar.gz',
    destination => '/tmp/statsd.tar.gz',
    verbose     => false,
  } ~>

  exec { 'untar-statsd':
    cwd     => '/opt/statsd',
    command => 'tar xzf /tmp/statsd.tar.gz --strip-components 1',
    creates => '/opt/statsd/stats.js',
    path    => '/usr/bin:/bin',
    notify  => Service['statsd'],
  } ->

  file { '/opt/statsd/local.js':
    content => template("${module_name}/local.js.erb"),
    notify  => Service['statsd'],
  } ->

  # this file is an almost exact copy of https://gist.github.com/DrPheltRight/1071989/raw/c81cb3e25c3a8ed5426572474344e3f8eb0c6e53/statsd.init.sh
  file { '/etc/init.d/statsd':
    source => "puppet:///modules/${module_name}/init.sh",
    mode   => 0555,
  } ~>

  service { 'statsd':
    ensure => running,
    enable => true,
  }
}
