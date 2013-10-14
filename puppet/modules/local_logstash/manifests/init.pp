class local_logstash (
  $sincedb_path = hiera('logstash::sincedb_path'),
  $patterns_dir = hiera('logstash::patterns_dir')
) {
  require java
  require elasticsearch

  include logstash

  File {
    owner => root,
    group => root,
  }

  file { $sincedb_path:
    ensure => directory,
    mode   => 0750,
    before => Class['logstash'],
  }

  file { $patterns_dir:
    ensure => directory,
    mode   => 0755,
  }

  logstash::output::elasticsearch { 'local':
    cluster => 'monitoring', # TODO get this from hiera
    host    => 'localhost',
  }

  #logstash::output::file { 'debug':
  #  path => '/var/log/logstash/debug.log',
  #}

  logstash::input::file { 'syslog':
    path         => ['/var/log/messages'],
    type         => 'syslog',
    sincedb_path => $sincedb_path,
  }
}
