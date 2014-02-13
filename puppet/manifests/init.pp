# site.pp

node monitoring {
  include timezone
  include epel
  include logstash_repo
  include iptables
  include apache
  include local_graphite
  include java
  include wget
  include local_elasticsearch
  include local_logstash
  include kibana
  include tomcat
  include statsd

  Yumrepo <| |> -> Package <| |>

  Class['iptables'] -> Class['apache', 'tomcat']
  Class['timezone'] -> Class['graphite']
}
