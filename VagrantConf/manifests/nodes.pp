# vim:ft=puppet:foldmarker={,}:foldlevel=1:foldmethod=marker:tw=80

node default {
}

node basenode inherits default {
  # Set up the Puppet Labs Yum package repo on EL/Fedora repo, basically just
  # mimics the puppetlabs-release rpm
  include puppetlabs_yum

  include stdlib

  # Add puppet (=puppetmaster host) to /etc/hosts
  host { 'puppet.evry.dev':
    ensure       => 'present',
    host_aliases => ['puppet', 'pm'],
    ip           => '172.16.10.10',
    target       => '/etc/hosts',
  }

  package {'puppet':
    ensure  =>  latest,
    require => Host['puppet.evry.dev'],
  }

  service {'puppet':
    ensure  => running,
    enable  => true,
    require => Package['puppet'],
  }

  file {'/etc/puppet/puppet.conf':
    ensure  => present,
    owner   => root,
    group   => root,
    source  => [
      #"/vagrant/puppet/puppet-$hostname.conf",
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

  # Disable iptables firewall
  service{'iptables':
    ensure => stopped,
    enable => false,
  }
}

node 'client1.evry.dev' inherits basenode {
  notify {'JTM: node client1.evry.dev!!!':}
}

node 'puppet.evry.dev' inherits basenode {
  user { 'vagrant':
    ensure     => present,
    groups     => ['puppet', 'puppetdb', 'puppet-dashboard'],
    membership => minimum,
    require    => [
      Package['puppet-server'],
      Package['puppet-dashboard'],
      Package['puppetdb']
    ],
  }
  package {'puppet-server':
    ensure  =>  latest,
    require => Host['puppet.evry.dev'],
  }

  service {'puppetmaster':
    ensure  => running,
    enable  => true,
    require => Package['puppet-server'],
  }

#############
  # PuppetDB
  class { 'puppetdb':
    listen_address       => '0.0.0.0',
    require              => Service['puppetmaster'],
    puppetdb_version     => latest,
  }

  # Configure the puppet master to use puppetdb
  class { 'puppetdb::master::config': }

  # http://docs.puppetlabs.com/puppetdb/1.3/install_from_source.html#step-3-option-a-run-the-ssl-configuration-script
  # Fixes things in /etc/puppetdb/ssl/
  exec {'fix-keystore':
    command  => '/usr/sbin/puppetdb-ssl-setup -f',
    onlyif   => '/usr/bin/test -f /var/lib/puppet/ssl/certs/ca.pem',
    notify   => Service['puppetdb'],
    #notify  => Service[$puppetdb_service],
  }

#############
  # Dashboard
  class {'dashboard':
    dashboard_site        => $fqdn,
    dashboard_port        => '3000',
#   require               => Package['puppet-dashboard'],
  }

  service {'puppet-dashboard-workers':
    ensure => running,
    enable => true,
  }

#############
  file {'/etc/puppet/autosign.conf':
    ensure  => link,
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => '/vagrant/puppet/autosign.conf',
    notify  => [Service['puppetmaster'], Service['puppet'], ],
    require => Package['puppet-server'],
  }

  file {'/etc/puppet/auth.conf':
    ensure  => link,
    owner   => root,
    group   => root,
    source  => '/vagrant/puppet/auth.conf',
    notify  => [Service['puppetmaster'], ],
    require => Package['puppet-server'],
  }

  file {'/etc/puppet/fileserver.conf':
    ensure  => link,
    owner   => root,
    group   => root,
    source  => '/vagrant/puppet/fileserver.conf',
    notify  => [Service['puppetmaster'], Service['puppet'], ],
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
    notify => [Service['puppetmaster'], Service['puppet'], ],
    before => [Service['puppetmaster'], Service['puppet'], ],
  }


  file { '/etc/puppet/hieradata':
    mode    => '0644',
    recurse => true,
  }
}
