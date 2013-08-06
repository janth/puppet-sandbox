# vim:ft=puppet:foldmarker={,}:foldlevel=1:foldmethod=marker:tw=80

# http://projects.puppetlabs.com/projects/1/wiki/Puppet_Best_Practice2

notify {'JTM: node nodes/puppet.evry.dev!!!':}
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
