# vim:ft=puppet:foldmarker={,}:foldlevel=1:foldmethod=marker:tw=80

# http://projects.puppetlabs.com/projects/1/wiki/Puppet_Best_Practice2

node default {
  notify {'JTM: node default!!!':}
}

node basenode inherits default {
  notify {'JTM: node basenode!!!':}
  # Only for RHEL:
  # include epel

  # Set up the Puppet Labs Yum package repo on EL/Fedora repo, basically just
  # mimics the puppetlabs-release rpm
  include puppetlabs_yum

  include stdlib

  #include concat
  include motd
  # include apache

  # Add puppet (=puppetmaster host) to /etc/hosts
  host { 'puppet.evry.dev':
    ensure       => 'present',
    host_aliases => ['puppet', 'pm'],
    ip           => '172.16.10.10',
    target       => '/etc/hosts',
#   comment      => 'Entry for PuppetMaster in EVRY lab',
  }

  package {'nc':
    ensure  =>  latest,
  }

  package {'traceroute':
    ensure  =>  latest,
  }

  package {'puppet':
    ensure  =>  latest,
    require => Host['puppet.evry.dev'],
  }

  service {'puppet':
    ensure  => running,
    require => Package['puppet'],
  }

  file {'/etc/puppet/puppet.conf':
    ensure  => present,
    owner   => root,
    group   => root,
    source  => [
        "/vagrant/puppet/puppet-$hostname.conf",
        '/vagrant/puppet/puppet-node.conf',
      ],
    notify  => Service['puppet'],
    require => Package['puppet'],
  }

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

  service {'sshd':
    ensure => running,
  }

  file {'/etc/ssh/sshd_config':
    ensure => present,
    owner  => root,
    group  => root,
    mode   => '0644',
    source => '/vagrant/evry/sshd_config',
    notify => Service['sshd'],
  }

  file {'/etc/sudoers':
    ensure => present,
    owner  => root,
    group  => root,
    mode   => '0440',
    source => '/vagrant/evry/sudoers',
  }

  file {'/var/log':
    ensure  => directory,
    owner   => root,
    group   => admin,
    mode    => '0644',
    recurse => true,
  }

  /* Fixed with 'manage_internal_file_permissions = false' in puppet.conf
  exec {'chmod /var/log/puppet':
    command   => '/bin/chmod 755 /var/log/puppet',
  }
  */

  user {'vagrant':
    ensure => present,
    groups => ['puppet'],
  }

  #notify {'Default setup on node default complete.':}
}

node 'client1.evry.dev' inherits basenode {
  notify {'JTM: node client1.evry.dev!!!':}
}

node 'puppet.evry.dev' inherits basenode {
  notify {'JTM: node puppet.evry.dev!!!':}
  include motd

  /*
  user { 'vagrant':
    ensure     => present,
    groups     => ['puppet', 'puppetdb', 'puppet-dashboard'],
    membership => minimum,
    require    => [ Package['puppet-server'], Package['puppet-dashboard'],
      Package['puppetdb'] ],
  }
  */

  service{'iptables':
    ensure => stopped,
  }
  # TODO Consider using puppetlabs-firewall module, to open for puppet
  # traffic...

  package {'puppet-server':
    ensure  =>  latest,
    require => Host['puppet.evry.dev'],
  }

  service {'puppetmaster':
    ensure  => running,
    require => Package['puppet-server'],
  }

/*
  # Configure puppetdb and its underlying database
  class { 'puppetdb':
    listen_address   => '0.0.0.0',
    require          => Package['puppet-server'],
    puppetdb_version => latest,
    }
  # Configure the puppet master to use puppetdb
  class { 'puppetdb::master::config': }

  class {'dashboard':
    dashboard_site => $fqdn,
    dashboard_port => '3000',
    require        => Package['puppet-server'],
  }
*/

  ##we copy rather than symlinking as puppet will manage this
/*
  file {'/etc/puppet/puppet.conf':
    ensure  => present,
    owner   => root,
    group   => root,
    source  => '/vagrant/puppet/puppet-master.conf',
    notify  => [Service['puppetmaster'],
#       Service['puppet-dashboard'],
#       Service['puppet-dashboard-workers']
      ],
    require => Package['puppet-server'],
  }
*/

  file {'/etc/sysconfig/puppetmaster':
    ensure   => present,
    owner    => root,
    group    => root,
    source   => '/vagrant/evry/puppetmaster',
    #notify  => Service['puppetmaster'],
    require  => Package['puppet-server'],
  }

  file {'/etc/puppet/autosign.conf':
    ensure  => link,
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => '/vagrant/puppet/autosign.conf',
    notify  => [Service['puppetmaster'],
        Service['puppet'],
#       Service['puppet-dashboard'],
#       Service['puppet-dashboard-workers']
  ],
    require => Package['puppet-server'],
  }

  file {'/etc/puppet/auth.conf':
    ensure  => link,
    owner   => root,
    group   => root,
    source  => '/vagrant/puppet/auth.conf',
    notify  => [Service['puppetmaster'],
#       Service['puppet-dashboard'],
#       Service['puppet-dashboard-workers']
  ],
    require => Package['puppet-server'],
  }

  file {'/etc/puppet/fileserver.conf':
    ensure  => link,
    owner   => root,
    group   => root,
    source  => '/vagrant/puppet/fileserver.conf',
    notify  => [Service['puppetmaster'],
        Service['puppet'],
#       Service['puppet-dashboard'],
#       Service['puppet-dashboard-workers']
  ],
    require => Package['puppet-server'],
  }

  file {'/etc/puppet/modules':
    mode    => '0644',
    recurse => true,
  }

  file { '/etc/puppet/hiera.yaml':
    ensure => link,
    owner  => root,
    group  => root,
    source => '/vagrant/puppet/hiera.yaml',
    notify => [Service['puppetmaster'],
        Service['puppet'],
#       Service['puppet-dashboard'],
#       Service['puppet-dashboard-workers']
  ],
  }

  file { '/etc/puppet/hieradata':
    mode    => '0644',
    recurse => true,
  }

  #notify {'PuppetMaster setup on node puppet complete.':}
}
