class local_logstash (
  $sincedb_path = hiera('logstash::sincedb_path'),
  $es_cluster_name = hiera('elasticsearch::cluster_name'),
  $es_host = 'localhost'
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

  logstash::configfile { 'local_es':
    content => template("${module_name}/local_es.conf.erb"),
    order   => 90,
  }

  logstash::configfile { 'syslog':
    source => "puppet:///modules/${module_name}/syslog.conf",
    order  => 50,
  }
}
