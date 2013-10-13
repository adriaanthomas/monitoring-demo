class local_graphite::petclinic {
  graphite::carbon::cache::storage { 'petclinic':
    pattern    => '^petclinic\.',
    retentions => '10s:1d',
    order      => 02,
  }
}
