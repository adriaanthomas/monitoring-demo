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

  define mkdir ($dir = $name, $owner = 'root', $group = 'root', $mode = 0555) {
    exec { "mkdir-$dir":
      command => "mkdir -p $dir",
      creates => "$dir",
      path    => '/usr/bin:/bin',
    } ->

    file { "$dir":
      ensure => directory,
      owner  => $owner,
      group  => $group,
      mode   => $mode,
    }
  }

  mkdir { "$sincedb_path":
    mode   => 0750,
    before => Class['logstash'],
  }

  mkdir { "$patterns_dir":
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
