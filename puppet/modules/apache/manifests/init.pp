class apache (
  $sincedb_path = hiera('logstash::sincedb_path')
) {

  service { 'httpd':
    ensure => running,
    enable => true,
  }

  logstash::input::file { 'httpd-access-log':
    path         => ['/var/log/httpd/access_log', '/var/log/httpd/error_log'],
    type         => 'access-log',
    sincedb_path => $sincedb_path,
  }
}
