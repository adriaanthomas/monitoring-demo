class local_graphite::carbon::config {
  File {
    owner => root,
    group => root,
    mode  => 0644,
  }

  # All aggregation rules in a single file; ordering became it bit too scattered otherwise.
  file { '/etc/carbon/storage-aggregation.conf':
    source => "puppet:///modules/${module_name}/storage-aggregation.conf",
    notify => Service['carbon-cache'],
  }

  # Storage-schemas rules
  graphite::carbon::cache::storage { 'petclinic':
    pattern    => '^petclinic\.',
    retentions => '10s:1d',
    order      => 02,
  }
}
