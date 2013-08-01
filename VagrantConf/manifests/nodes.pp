# vim:ft=puppet:foldmethod=syntax:tw=80

# http://projects.puppetlabs.com/projects/1/wiki/Puppet_Best_Practice2

node default {
}

node basenode {
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
    comment      => 'Entry for PuppetMaster in EVRY lab',
  }

  # TODO
  # copy saved /etc/ssh/ssh_host keys
  # fix /etc/sudoers
  # fix /etc/rsyslog.conf
  # add user vagrant to groups vagrant*

  notify {'Default setup on node default complete.':}
}

node 'puppet.evry.dev' inherits basenode {
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

  package {'puppet-server':
    ensure  =>  latest,
    require => Host['puppet.evry.dev'],
  }

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
  ##we copy rather than symlinking as puppet will manage this
  file {'/etc/puppet/puppet.conf':
    ensure  => present,
    owner   => root,
    group   => root,
    source  => '/vagrant/puppet/puppet.conf',
    notify  => [Service['puppetmaster'],
        Service['puppet-dashboard'],
        Service['puppet-dashboard-workers']
      ],
    require => Package['puppet-server'],
  }

  file {'/etc/puppet/autosign.conf':
    ensure  => link,
    owner   => root,
    group   => root,
    source  => '/vagrant/puppet/autosign.conf',
    notify  => [Service['puppetmaster'],
        Service['puppet-dashboard'],
        Service['puppet-dashboard-workers']
      ],
    require => Package['puppet-server'],
  }

  file {'/etc/puppet/auth.conf':
    ensure  => link,
    owner   => root,
    group   => root,
    source  => '/vagrant/puppet/auth.conf',
    notify  => [Service['puppetmaster'],
        Service['puppet-dashboard'],
        Service['puppet-dashboard-workers']
      ],
    require => Package['puppet-server'],
  }

  file {'/etc/puppet/fileserver.conf':
    ensure  => link,
    owner   => root,
    group   => root,
    source  => '/vagrant/puppet/fileserver.conf',
    notify  => [Service['puppetmaster'],
        Service['puppet-dashboard'],
        Service['puppet-dashboard-workers']
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
        Service['puppet-dashboard'],
        Service['puppet-dashboard-workers']
      ],
  }
 
  file { '/etc/puppet/hieradata':
    mode    => '0644',
    recurse => true,
  }

  notify {'PuppetMaster setup on node puppet complete.':}
}
