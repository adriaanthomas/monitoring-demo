class local_graphite::web::config {
  include logstash

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

  $patterns_dir = "${logstash::configdir}/patterns"

  logstash::configfile { 'graphite':
    content => template("${module_name}/graphite_logstash.conf.erb"),
    order   => 40, # must be before the apache logstash config (50)
  }
}
