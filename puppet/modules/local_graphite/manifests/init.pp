# Helper class for our CentOS Graphite install.
# Makes a few assumptions, not very modular.
# Note that we also modify some settings through hiera.
class local_graphite {
  include graphite

  Class['graphite'] ~> Service['httpd']

  include local_graphite::carbon::config
  include local_graphite::web::config
}
