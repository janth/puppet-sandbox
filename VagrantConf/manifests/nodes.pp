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
    enable  => true,
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
    recurse => false,
  }

  file {'/var/log/puppet':
    ensure  => directory,
    owner   => puppet,
    group   => puppet,
    mode    => '0664',
    recurse => true,
  }

  # Fixed with 'manage_internal_file_permissions = false' in puppet.conf
  exec {'chmod /var/log/puppet':
    command   => '/bin/bash -c "/bin/chmod 775 /var/log/puppet ; /bin/chmod g+ws /var/log/puppet" ',
  }

  user {'vagrant':
    ensure => present,
    groups => ['puppet'],
  }

  service{'iptables':
    ensure => stopped,
    enable => false,
  }
  # TODO Consider using puppetlabs-firewall module, to open for puppet
  # traffic...

  #notify {'Default setup on node default complete.':}
}

node 'client1.evry.dev' inherits basenode {
  notify {'JTM: node client1.evry.dev!!!':}
}

node 'puppet.evry.dev' inherits basenode {
  notify {'JTM: node puppet.evry.dev!!!':}
  include motd

  /*
  #Error: Duplicate declaration: User[vagrant] is already declared in file ...
  user { 'vagrant':
    ensure     => present,
    groups     => ['puppet', 'puppet-dashboard'],
#   groups     => ['puppet', 'puppetdb', 'puppet-dashboard'],
    membership => minimum,
    require    => [
      Package['puppet-server'],
      Package['puppet-dashboard'],
      #Package['puppetdb']
    ],
  }
  */

  package {'puppet-server':
    ensure  =>  latest,
    require => Host['puppet.evry.dev'],
  }

  service {'puppetmaster':
    ensure  => running,
    enable  => true,
    require => Package['puppet-server'],
  }

  # Configure puppetdb and its underlying database
  class { 'puppetdb':
    database             => 'postgres',
#   database_name        => 'puppetdb',
#   database_password    => 'puppetdb',
    listen_address       => '127.0.0.1',
    listen_port          => '8080',
#   ssl_listen_address   => '0.0.0.0',
#   ssl_listen_port      => '8080',
    # Do not manage firewall, as we keep it disabled
    open_ssl_listen_port => false,
    open_listen_port     => false, 
    disable_ssl          => false,
    require              => Package['puppet-server'],
    puppetdb_version     => latest,
#   java_args            => '{ '-Xmx'                 => '512m', '-Xms' => '256m' }
  }
  # Configure the puppet master to use puppetdb
  class { 'puppetdb::master::config':
    manage_storeconfigs      => true,
    manage_report_processor  => true,
    manage_config            => true,
    strict_validation        => false,
    puppetdb_startup_timeout => 15,
  }

# Dashboard: http://docs.puppetlabs.com/dashboard/manual/1.2/bootstrapping.html
# prereq: rubygem-rake mysql-server ruby-mysql
# puppet-dashboard

  package {'rubygem-rake':
    ensure  =>  latest,
  }

/* Handleles by class dashboard
  package {'mysql-server':
    ensure  =>  latest,
  }

  package {'ruby-mysql':
    ensure  =>  latest,
  }

  package {'puppet-dashboard':
    ensure  => latest,
    require => [
          Host['puppet.evry.dev'],
          Package['puppet-server'],
          Package['rubygem-rake'],
          #Package['mysql-server'],
          #Package['ruby-mysql'],
        ]
  }
*/


  class {'dashboard':
    dashboard_user        => 'puppet-dashboard',
    dashboard_group       => 'puppet-dashboard',
    dashboard_password    => 'changeme',
    dashboard_db          => 'dashboard_production',
    dashboard_charset     => 'utf8',
#   dashboard_environment => 'production',
    dashboard_site        => $fqdn,
    dashboard_port        => '3000',
    passenger             => false,
    mysql_root_pw         => 'changemetoo',
#   rails_base_uri        => '/',
#   require               => Package['puppet-dashboard'],
  }

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
