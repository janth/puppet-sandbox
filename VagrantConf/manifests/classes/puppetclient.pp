class puppetclient {

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
        '/vagrant/puppet/puppet-node.conf',
      ],
    notify  => Service['puppet'],
    require => Package['puppet'],
  }
}

