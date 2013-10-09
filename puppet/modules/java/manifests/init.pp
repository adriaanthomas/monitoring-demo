# Very basic module, just to make sure we have a JRE ready.
class java {
  package { 'java-1.7.0-openjdk':
    ensure => latest, # for this demo setup, this will do
  }
}
