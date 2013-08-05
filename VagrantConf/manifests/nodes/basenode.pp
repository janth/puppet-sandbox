# vim:ft=puppet:foldmarker={,}:foldlevel=1:foldmethod=marker:tw=80

# http://projects.puppetlabs.com/projects/1/wiki/Puppet_Best_Practice2

notify {'JTM: node nodes/basenode!!!':}
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
  require => Package['puppet-server'],
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

#exec {'chmod /var/log/puppet': command   => '/bin/chmod 755 /var/log/puppet', }
user {'vagrant':
  ensure => present,
  groups => ['puppet'],
}

#notify {'Default setup on node default complete.':}
