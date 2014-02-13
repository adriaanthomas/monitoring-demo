# Define this separate, as using the repo in the logstash module
# creates circular dependencies for us.  This way, we can cleanly
# define all yum repositories before any packages are installed.
# See http://www.elasticsearch.org/blog/apt-and-yum-repositories/ for info
# about the repositories.
class elasticsearch_repos (
  $logstash_version = '1.3',
  $elasticsearch_version = '0.90'
) {
  # taken from https://github.com/elasticsearch/puppet-logstash/blob/master/manifests/repo.pp
  yumrepo { 'logstash':
    baseurl  => "http://packages.elasticsearch.org/logstash/$logstash_version/centos",
    gpgcheck => 1,
    gpgkey   => 'http://packages.elasticsearch.org/GPG-KEY-elasticsearch',
    enabled  => 1,
  }

  # taken from https://github.com/elasticsearch/puppet-elasticsearch/blob/master/manifests/repo.pp
  yumrepo { 'elasticsearch':
    baseurl  => "http://packages.elasticsearch.org/elasticsearch/$elasticsearch_version/centos",
    gpgcheck => 1,
    gpgkey   => 'http://packages.elasticsearch.org/GPG-KEY-elasticsearch',
    enabled  => 1,
  }
}
