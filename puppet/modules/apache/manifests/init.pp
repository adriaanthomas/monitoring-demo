class apache {
  include logstash # needed for the config dir in the template

  File {
    owner => root,
    group => root,
    mode  => 0444,
  }

  service { 'httpd':
    ensure => running,
    enable => true,
  }

  logstash::patternfile { 'apache':
    source => "puppet:///modules/${module_name}/apache.pattern",
  }

  $patterns_dir = "${logstash::configdir}/patterns"

  logstash::configfile { 'apache':
    content => template("${module_name}/apache_logstash.conf.erb"),
    order   => 50,
  }
}
