class tomcat {
  require local_logstash

  $sincedb_path = hiera('logstash::sincedb_path')

  File {
    owner => root,
    group => root,
    mode  => 0444,
  }

  package { ['tomcat6', 'tomcat6-admin-webapps']:
    ensure => latest, # this will do for this demo
  } ->

  file { '/etc/tomcat6/tomcat-users.xml':
    source => "puppet:///modules/${module_name}/tomcat-users.xml",
    notify => Service['tomcat6'],
  }

  file { '/etc/tomcat6/server.xml':
    source  => "puppet:///modules/${module_name}/server.xml",
    notify  => Service['tomcat6'],
    require => Package['tomcat6'],
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

  # note that we have to escape the quotes
  logstash::filter::grok { 'tomcat-access':
    type        => 'tomcat-access',
    match       => {
      'message' => '%{IPORHOST:clientip} %{USER:ident} %{USER:auth} \[%{HTTPDATE:timestamp}\] \"(?:%{WORD:verb} %{NOTSPACE:request}(?: HTTP/%{NUMBER:httpversion})?|%{DATA:rawrequest})\" %{NUMBER:response} (?:%{NUMBER:bytes}|-)',
    },
    order       => 10,
  }

  logstash::filter::multiline { 'tomcat':
    type         => 'tomcat',
    pattern      => '^\s',
    what         => 'previous',
    order        => 20,
  }

  logstash::filter::date { 'tomcat-access':
    type          => 'tomcat-access',
    match         => ['timestamp', 'dd/MMM/yyyy:HH:mm:ss Z'],
    locale        => 'en',
    order         => 30,
    #remove_field => 'timestamp',
  }

  logstash::filter::mutate { 'tomcat-access':
    type   => 'tomcat-access',
    remove => ['timestamp'],
    order  => 40,
  }

  logstash::output::statsd { 'tomcat-access':
    increment => ['tomcat.response.%{response}'],
    count     => { 'tomcat.bytes' => '%{bytes}' },
    type      => 'tomcat-access',
  }
}
