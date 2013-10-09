# site.pp

node monitoring {
  include timezone
  include epel
  include iptables
  include apache
  include local_graphite
  include java
  include wget
  include local_elasticsearch
  include local_logstash
  include kibana
  include tomcat

  Yumrepo <| |> -> Package <| |>

  Class['iptables'] -> Class['apache', 'tomcat']
  Class['timezone'] -> Class['graphite']
}
