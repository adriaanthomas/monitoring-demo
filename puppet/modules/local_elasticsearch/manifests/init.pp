class local_elasticsearch (
  $url = 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.90.5.noarch.rpm'
) {
  $local_rpm_file = '/tmp/elasticsearch.rpm'

  require wget
  require java

  class { 'elasticsearch':
    pkg_source => $local_rpm_file,
  }

  wget::fetch { 'elasticsearch.rpm':
    source      => $local_elasticsearch::url,
    destination => $local_rpm_file,
    verbose     => false,
    before      => Class['elasticsearch'],
  }
}
