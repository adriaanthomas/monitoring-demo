class apache (
  $sincedb_path = hiera('logstash::sincedb_path'),
  $patterns_dir = hiera('logstash::patterns_dir')
) {
  File {
    owner => root,
    group => root,
    mode  => 0444,
  }

  service { 'httpd':
    ensure => running,
    enable => true,
  }

  file { "$patterns_dir/apache":
    source => "puppet:///modules/${module_name}/apache.pattern",
  }

  logstash::input::file { 'apache-access-log':
    path         => ['/var/log/httpd/access_log'],
    type         => 'apache-access-log',
    sincedb_path => $sincedb_path,
  }

  logstash::input::file { 'apache-error-log':
    path         => ['/var/log/httpd/error_log'],
    type         => 'apache-error-log',
    sincedb_path => $sincedb_path,
  }

  # note that we have to escape the quotes
  logstash::filter::grok { 'apache-access-log':
    type        => 'apache-access-log',
    match       => {
      'message' => '%{IPORHOST:clientip} %{USER:ident} %{USER:auth} \[%{HTTPDATE:timestamp}\] \"(?:%{WORD:verb} %{NOTSPACE:request}(?: HTTP/%{NUMBER:httpversion})?|%{DATA:rawrequest})\" %{NUMBER:response} (?:%{NUMBER:bytes}|-)',
    },
    order       => 10,
  }

  logstash::filter::grok { 'apache-error-log':
    type         => 'apache-error-log',
    patterns_dir => [$patterns_dir],
    order        => 10,
    match        => {
      'message'  => '\[%{APACHE_ERROR_LOG_DATESTAMP:timestamp}\] \[%{LOGLEVEL:level}\] %{GREEDYDATA:logmessage}',
    },
  }

  # if there is more than one space after the log level, the line belongs to the previous line's data
  logstash::filter::multiline { 'apache-error-log':
    type         => 'apache-error-log',
    pattern      => '\[%{APACHE_ERROR_LOG_DATESTAMP:timestamp}\] \[%{LOGLEVEL:level}\]  ',
    patterns_dir => [$patterns_dir],
    what         => 'previous',
    order        => 20,
  }

  logstash::filter::date { 'apache-access-log':
    type          => 'apache-access-log',
    match         => ['timestamp', 'dd/MMM/yyyy:HH:mm:ss Z'],
    locale        => 'en',
    order         => 30,
    #remove_field => 'timestamp',
  }

  # Sun Oct 13 22:41:41 2013
  logstash::filter::date { 'apache-error-log':
    type   => 'apache-error-log',
    match  => ['timestamp', 'EEE MMM dd HH:mm:ss yyyy'],
    locale => 'en',
    order  => 30,
  }

  logstash::filter::mutate { 'apache-access-log':
    type   => 'apache-access-log',
    remove => ['timestamp'],
    order  => 40,
  }

  logstash::filter::mutate { 'apache-error-log':
    type   => 'apache-error-log',
    remove => ['timestamp'],
    order  => 40,
  }

  logstash::output::statsd { 'apache':
    increment => ['apache.response.${response}'],
    count     => { 'apache.bytes' => '${bytes}' },
    type      => 'apache-access-log',
  }
}
