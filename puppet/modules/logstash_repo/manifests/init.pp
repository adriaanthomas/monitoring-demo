# Define this separate, as using the repo in the logstash module
# creates circular dependencies for us.  This way, we can cleanly
# define all yum repositories before any packages are installed.
class logstash_repo (
  $version = '1.3'
) {
  # taken from https://github.com/elasticsearch/puppet-logstash/blob/master/manifests/repo.pp
  yumrepo { 'logstash':
    baseurl  => "http://packages.elasticsearch.org/logstash/$version/centos",
    gpgcheck => 1,
    gpgkey   => 'http://packages.elasticsearch.org/GPG-KEY-elasticsearch',
    enabled  => 1,
  }
}
