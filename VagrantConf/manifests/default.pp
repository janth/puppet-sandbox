node default {

  host { 'puppet.evry.dev':
    ensure => 'present',
    host_aliases => ['puppet'],
    ip => '172.20.20.20',
    target => '/etc/hosts',
  }
  
  package {'puppet-server':
    ensure => latest,
    require => Host['puppet.evry.dev'],
  }

  # Configure puppetdb and its underlying database
  class { 'puppetdb':
    listen_address => '0.0.0.0',
    require => Package['puppet-server'],
    puppetdb_version => latest,
    }
  # Configure the puppet master to use puppetdb
  class { 'puppetdb::master::config': }
    
  class {'dashboard':
    dashboard_site => $fqdn,
    dashboard_port => '3000',
    require => Package["puppet-server"],
  }
  ##we copy rather than symlinking as puppet will manage this
  file {'/etc/puppet/puppet.conf':
    ensure => present,
    owner => root,
    group => root,
    source => "/vagrant/puppet/puppet.conf",
    notify => [Service['puppetmaster'],Service['puppet-dashboard'],Service['puppet-dashboard-workers']],
    require => Package['puppet-server'],
  }
    
  file {'/etc/puppet/autosign.conf':
    ensure => link,
    owner => root,
    group => root,
    source => "/vagrant/puppet/autosign.conf",
    notify => [Service['puppetmaster'],Service['puppet-dashboard'],Service['puppet-dashboard-workers']],
    require => Package['puppet-server'],
  }
  
  file {'/etc/puppet/auth.conf':
    ensure => link,
    owner => root,
    group => root,
    source => "/vagrant/puppet/auth.conf",
    notify => [Service['puppetmaster'],Service['puppet-dashboard'],Service['puppet-dashboard-workers']],
    require => Package['puppet-server'],
  }
  
  file {'/etc/puppet/fileserver.conf':
    ensure => link,
    owner => root,
    group => root,
    source => "/vagrant/puppet/fileserver.conf",
    notify => [Service['puppetmaster'],Service['puppet-dashboard'],Service['puppet-dashboard-workers']],
    require => Package['puppet-server'],
  }
  
  file {'/etc/puppet/modules':
    mode => '0644',
    recurse => true,
  }
  
  file { '/etc/puppet/hiera.yaml':
    ensure => link,
    owner => root,
    group => root,
    source => "/vagrant/puppet/hiera.yaml",
    notify => [Service['puppetmaster'],Service['puppet-dashboard'],Service['puppet-dashboard-workers']],
  }
  
  file { '/etc/puppet/hieradata':
    mode => '0644',
    recurse => true,
  }
    
}
