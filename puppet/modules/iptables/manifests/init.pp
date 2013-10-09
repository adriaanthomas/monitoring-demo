# Just make sure iptables is always off - easiest for now, and fine for local testing.
class iptables {
  service { 'iptables':
    ensure => stopped,
    enable => false,
  }
}
