class local_graphite::web::config (
  $sincedb_path = hiera('logstash::sincedb_path')
) {
  File {
    owner => root,
    group => root,
    mode  => 0444,
  }

  file { '/usr/lib/python2.6/site-packages/graphite/initial_data.json':
    content => template("${module_name}/initial_data.json.erb"),
    owner   => 'apache',
    group   => 'apache',
    mode    => 0400,
    require => Package['graphite-web'],
  } ->

  exec { 'syncdb':
    cwd     => '/usr/lib/python2.6/site-packages/graphite',
    command => '/usr/bin/python manage.py syncdb --noinput',
    user    => 'apache',
    creates => '/var/lib/graphite-web/graphite.db',
    before  => Service['httpd'],
  }

  file { '/etc/graphite-web/graphTemplates.conf':
    source => "puppet:///modules/${module_name}/graphTemplates.conf",
    before => Service['httpd'], # no restart required?
  }

  file { '/etc/httpd/conf.d/graphite-web.conf':
    source  => "puppet:///modules/${module_name}/graphite-web.conf",
    notify  => Service['httpd'],
    require => Package['graphite-web'],
  }

  logstash::input::file { 'graphite-apache-access-log':
    path         => ['/var/log/httpd/graphite-web-access.log'],
    type         => 'apache-access-log',
    sincedb_path => $sincedb_path,
  }

  logstash::input::file { 'graphite-apache-error-log':
    path         => ['/var/log/httpd/graphite-web-error.log'],
    type         => 'apache-error-log',
    sincedb_path => $sincedb_path,
  }

  logstash::input::file { 'graphite-web-logs':
    path         => ['/var/log/graphite-web/*.log'],
    type         => 'graphite-web',
    sincedb_path => $sincedb_path,
  }
}
