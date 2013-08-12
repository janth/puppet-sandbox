node 'puppet.evry.dev' inherits basenode {
  notify {'JTM: file nodes/puppetmaster.pp':}
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
  # https://github.com/puppetlabs/puppetdb
  # PuppetDB
  class { 'puppetdb':
#   listen_address       => '0.0.0.0',
    require              => Service['puppetmaster'],
    puppetdb_version     => latest,
#   open_postgres_port   => false,
  }

  # Configure the puppet master to use puppetdb
  class { 'puppetdb::master::config':
    manage_config            => true, # default:?
#   manage_routes            => true, # default:true
    manage_storeconfigs      => true, # default:true
    manage_report_processor  => true, # default:false
    enable_reports           => true, # default:?
    strict_validation        => false,
    puppetdb_startup_timeout => 15,
    restart_puppet           => true, # default:?
  }

  # http://docs.puppetlabs.com/puppetdb/1.3/install_from_source.html#step-3-option-a-run-the-ssl-configuration-script
  # Fixes things in /etc/puppetdb/ssl/
  exec {'fix-keystore':
    command  => '/usr/sbin/puppetdb-ssl-setup -f',
    onlyif   => '/usr/bin/test -f /var/lib/puppet/ssl/certs/ca.pem',
    notify   => Service['puppetdb'],
    require  => Service['puppetmaster'],
    #notify  => Service[$puppetdb_service],
  }


#############
  # Dashboard
  class {'dashboard':
    dashboard_ensure => 'latest',
    dashboard_site   => $fqdn,
    dashboard_port   => '3000',
  }

/*
  # This really should'nt be necessary!!! And besides, it doesn't work! Really!
  service {'puppet-dashboard-workers':
    ensure => running,
    enable => true,
  }
*/


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


  file { '/etc/puppet/hiera.yaml':
    ensure => link,
    owner  => root,
    group  => root,
    source => '/vagrant/puppet/hiera.yaml',
    notify => [Service['puppetmaster'], Service['puppet'], ],
    before => [Service['puppetmaster'], Service['puppet'], ],
  }

  file {'/etc/puppet/modules':
    mode    => '0644',
    recurse => true,
  }

  file { '/etc/puppet/hieradata':
    mode    => '0644',
    recurse => true,
  }
}
