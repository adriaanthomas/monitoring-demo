class apache {
  service { 'httpd':
    ensure => running,
    enable => true,
  }
}
