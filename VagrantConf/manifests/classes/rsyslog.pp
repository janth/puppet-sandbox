class rsyslog {
  service {'rsyslog':
    ensure => running,
  }

  file {'/etc/rsyslog.conf':
    ensure => present,
    owner  => root,
    group  => root,
    mode   => '0644',
    source => '/vagrant/evry/rsyslog.conf',
    notify => Service['rsyslog'],
  }
}
