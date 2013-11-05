class local_graphite::web::config (
  $sincedb_path = hiera('logstash::sincedb_path'),
  $patterns_dir = hiera('logstash::patterns_dir')
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

  logstash::input::file { 'graphite-web':
    path         => ['/var/log/graphite-web/*.log'],
    type         => 'graphite-web',
    sincedb_path => $sincedb_path,
  }

  # Mon Oct 14 21:12:55 2013 :: graphite.wsgi - pid 5791 - reloading search index
  # Mon Oct 14 21:12:56 2013 :: [IndexSearcher] performing initial index load
  logstash::filter::grok { 'graphite-web':
    type         => 'graphite-web',
    patterns_dir => [$patterns_dir],
    order        => 10,
    match        => {
      'message'  => '%{APACHE_ERROR_LOG_DATESTAMP:timestamp} :: %{GREEDYDATA:logmessage}',
    },
  }
  logstash::filter::multiline { 'graphite-web':
    type         => 'graphite-web',
    pattern      => '^\[%{APACHE_ERROR_LOG_DATESTAMP}\] :: ',
    negate       => true,
    patterns_dir => [$patterns_dir],
    what         => 'previous',
    order        => 20,
  }

  # Mon Oct 14 21:12:55 2013
  logstash::filter::date { 'graphite-web':
    type   => 'graphite-web',
    match  => ['timestamp', 'EEE MMM dd HH:mm:ss yyyy'],
    locale => 'en',
    order  => 30,
  }

  logstash::filter::mutate { 'graphite-web':
    type   => 'graphite-web',
    remove => ['timestamp'],
    order  => 40,
  }
}
