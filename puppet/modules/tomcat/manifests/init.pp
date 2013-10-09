class tomcat {
  $sincedb_path = hiera('logstash::sincedb_path')

  File {
    owner => root,
    group => root,
    mode  => 0444,
  }

  package { ['tomcat6', 'tomcat6-admin-webapps']:
    ensure => latest, # this will do for this demo
  } ~>

  file { '/etc/tomcat6/tomcat-users.xml':
    source => "puppet:///modules/${module_name}/tomcat-users.xml",
    notify => Service['tomcat6'],
  }

  file { '/etc/tomcat6/server.xml':
    source => "puppet:///modules/${module_name}/server.xml",
    notify => Service['tomcat6'],
  }

  service { 'tomcat6':
    ensure => running,
    enable => true,
  }

  logstash::input::file { 'catalina.out':
    path         => ['/var/log/tomcat6/catalina.out'],
    type         => 'tomcat',
    sincedb_path => $sincedb_path,
  }

  logstash::input::file { 'localhost_access_log':
    path         => ['/var/log/tomcat6/localhost_access_log.*.txt'],
    type         => 'tomcat-access',
    sincedb_path => $sincedb_path,
  }
}
