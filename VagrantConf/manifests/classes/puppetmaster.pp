class puppetmaster {

  ## TODO: Make OS-independent/verify supported OS

  ## THIS IS LINUX SPECIFIC
  package {'puppet-server':
    ensure  =>  latest,
    require => Host['puppet.evry.dev'],
  }

  service {'puppetmaster':
    ensure  => running,
    enable  => true,
    require => Package['puppet-server'],
  }

  # PuppetDB
  class { 'puppetdb':
    require              => Service['puppetmaster'],
    puppetdb_version     => latest,
  }

  # Configure the puppet master to use puppetdb
  class { 'puppetdb::master::config':
    manage_config            => true, # default:?
    manage_storeconfigs      => true, # default:true
    manage_report_processor  => true, # default:false
    enable_reports           => true, # default:?
    strict_validation        => false,
    puppetdb_startup_timeout => 15,
    restart_puppet           => true, # default:?
  }

  # Fixes things in /etc/puppetdb/ssl/
  exec {'fix-keystore':
    command  => '/usr/sbin/puppetdb-ssl-setup -f',
    onlyif   => '/usr/bin/test -f /var/lib/puppet/ssl/certs/ca.pem',
    notify   => Service['puppetdb'],
    require  => Service['puppetmaster'],
  }

  # Dashboard
  class {'dashboard':
    dashboard_ensure => 'latest',
    dashboard_site   => $fqdn,
    dashboard_port   => '3000',
  }

  # puppetmaster config
  file {'/etc/puppet/autosign.conf':
    ensure  => link,
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => '/vagrant/puppet/autosign.conf',
    notify  => [Service['puppetmaster'],Service['puppet-dashboard'],Service['puppet-dashboard-workers']],
    require => Package['puppet-server'],
  }

  file {'/etc/puppet/auth.conf':
    ensure  => link,
    owner   => root,
    group   => root,
    source  => '/vagrant/puppet/auth.conf',
    notify  => [Service['puppetmaster'],Service['puppet-dashboard'],Service['puppet-dashboard-workers']],
    require => Package['puppet-server'],
  }

  file {'/etc/puppet/fileserver.conf':
    ensure  => link,
    owner   => root,
    group   => root,
    source  => '/vagrant/puppet/fileserver.conf',
    notify  => [Service['puppetmaster'],Service['puppet-dashboard'],Service['puppet-dashboard-workers']],
    require => Package['puppet-server'],
  }

  file { '/etc/puppet/hiera.yaml':
    ensure => link,
    owner  => root,
    group  => root,
    source => '/vagrant/puppet/hiera.yaml',
    notify  => [Service['puppetmaster'],Service['puppet-dashboard'],Service['puppet-dashboard-workers']],
  }

  file {'/etc/puppet/modules':
    mode    => '0644',
    recurse => true,
  }

  file { '/etc/puppet/hieradata':
    mode    => '0644',
    recurse => true,
  }

  # puppet-dashboard config
  file {'/usr/share/puppet-dashboard/config/settings.yml':
    ensure  => link,
    owner   => puppet-dashboard,
    group   => puppet-dashboard,
    source  => '/vagrant/puppet/dashboard-settings.yml',
    require => [File['/vagrant/puppet/dashboard-settings.yml'],File['/usr/share/puppet-dashboard/config']],
    notify  => [Service['puppetmaster'],Service['puppet-dashboard'],Service['puppet-dashboard-workers']],
  }

  file {'/vagrant/puppet/dashboard-settings.yml':
    owner => puppet-dashboard,
    group => puppet-dashboard,
    mode  => '0640',
  }

  file {'/usr/share/puppet-dashboard/config':
    ensure  => directory,
    owner   => puppet-dashboard,
    group   => puppet-dashboard,
    mode    => 755,
    require => File['/usr/share/puppet-dashboard'],
  }

  file {'/usr/share/puppet-dashboard':
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => 755,
  }

  # make it easier to read log files and stuff in vagrant sandbox
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
}
