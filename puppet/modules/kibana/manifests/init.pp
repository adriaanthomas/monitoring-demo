class kibana (
  $source_url = 'https://download.elasticsearch.org/kibana/kibana/kibana-latest.tar.gz'
) {
  require wget

  $local_file = '/tmp/kibana.tar.gz'

  File {
    owner => root,
    group => root,
    mode  => 0444,
  }

  file { '/usr/share/kibana':
    ensure => directory,
  } ->

  wget::fetch { 'kibana.tar.gz':
    source      => $source_url,
    destination => $local_file,
    verbose     => false,
  } ->

  exec { 'untar-kibana':
    cwd     => '/usr/share/kibana',
    command => "tar xzf $local_file --strip-components 1",
    creates => '/usr/share/kibana/index.html',
    path    => '/usr/bin:/bin',
  } ~>

  #file { '/usr/share/kibana/config.js':
  #  content => template("${module_name}/config.js.erb"),
  #} ~>

  file { '/etc/httpd/conf.d/kibana.conf':
    source => "puppet:///modules/${module_name}/kibana.conf",
    notify => Service['httpd'],
  }
}
