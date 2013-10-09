# site.pp

node monitoring {
  include epel
  include iptables
  include apache
  include local_graphite

  Yumrepo <| |> -> Package <| |>

  Class['iptables'] -> Class['apache']
}
