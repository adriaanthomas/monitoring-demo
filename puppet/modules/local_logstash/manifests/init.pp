class local_logstash (
  $sincedb_path = hiera('logstash::sincedb_path')
) {
  require java
  require elasticsearch

  include logstash

  file { $sincedb_path:
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => 0755,
    before => Class['logstash'],
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
