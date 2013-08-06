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

  file {'/var/log/puppet':
    ensure  => directory,
    owner   => puppet,
    group   => puppet,
    mode    => '0664',
    recurse => true,
    require => File['/var/log'],
  }


  file {'/var/log/puppetdb':
    ensure  => directory,
    owner   => puppetdb,
    group   => puppetdb,
    mode    => '0664',
    recurse => true,
    require => File['/var/log'],
  }

  # Fixed with 'manage_internal_file_permissions = false' in puppet.conf
  exec {'chmod /var/log/puppet':
    command   => '/bin/bash -c "/bin/chmod 775 /var/log/puppet ; /bin/chmod g+ws /var/log/puppet" ',
  }
  exec {'chmod /var/log/puppetdb':
    command   => '/bin/bash -c "/bin/chmod 775 /var/log/puppetdb ; /bin/chmod g+ws /var/log/puppetdb" ',
  }

  user {'vagrant':
    ensure => present,
    groups => ['puppet'],
  }

  # Disable iptables firewall
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

#############
  # PuppetDB: http://docs.puppetlabs.com/puppetdb/latest/http://docs.puppetlabs.com/puppetdb/latest/
  # http://forge.puppetlabs.com/puppetlabs/puppetdb
  # Configure puppetdb and its underlying database
  # NOTE Must run sudo /usr/sbin/puppetdb-ssl-setup
  class { 'puppetdb':
    database               => 'postgres',
    database_name          => 'puppetdb',
    database_password      => 'puppetdb',
    listen_address         => '0.0.0.0',
    listen_port            => '8080',
    ssl_listen_address     => '0.0.0.0',
    ssl_listen_port        => '8081',
    disable_ssl            => false,
    open_ssl_listen_port   => false,
    open_listen_port       => false,
    open_postgres_port     => false,
    require                => Package['puppet-server'],
    puppetdb_version       => latest,
  }
#   java_args             => '{ '-Xmx'                 => '512m', '-Xms' => '256m' }

  # Configure the puppet master to use puppetdb
  class { 'puppetdb::master::config':
    manage_config            => true,
    manage_storeconfigs      => true,
    manage_report_processor  => true,
    enable_reports           => true,
    strict_validation        => false,
    puppetdb_startup_timeout => 15,
    restart_puppet           => true,
  }

  file {'/etc/puppetdb/':
    ensure  => directory,
    owner   => puppetdb,
    group   => puppetdb,
    mode    => '0664',
    recurse => true,
  }

  file {'/var/lib/puppet/':
    ensure  => directory,
    owner   => puppet,
    group   => puppet,
    mode    => '0664',
    recurse => true,
  }

  exec {'chmod /etc/puppetdb':
    command   => '/bin/bash -c "/bin/chmod 775 /etc/puppetdb ; /bin/chmod g+ws /etc/puppetdb" ',
  }

  # http://docs.puppetlabs.com/puppetdb/1.3/install_from_source.html#step-3-option-a-run-the-ssl-configuration-script
  exec {'fix-keystore':
    command => '/usr/sbin/puppetdb-ssl-setup -f',
    onlyif => '/usr/bin/test -f /var/lib/puppet/ssl/certs/ca.pem',
  }
  exec {'fix-openssl':
    #command => '/bin/ln -s /etc/puppet/ssl/certs/ca.pem $(openssl version -d|cut -d\" -f2)/certs/$(openssl x509 -hash -noout -in /etc/puppet/ssl/certs/ca.pem).0', 
    command  => '/bin/ln -s /var/lib/puppet/ssl/certs/ca.pem $(openssl version -d|cut -d\" -f2)/certs/$(openssl x509 -hash -noout -in /var/lib/puppet/ssl/certs/ca.pem).0',
    onlyif   => '/usr/bin/test -f /etc/puppet/ssl/certs/ca.pem',
  }

#############
  # Dashboard: http://docs.puppetlabs.com/dashboard/manual/1.2/bootstrapping.html
  # https://github.com/puppetlabs/puppetlabs-dashboard
  # Dependencies: rubygems, ruby-rake, mysql-server, ruby-mysql
  # Should be automaic installed
  class {'dashboard':
    dashboard_site        => $fqdn,
    dashboard_port        => '3000',
#   dashboard_user        => 'puppet-dashboard',
#   dashboard_group       => 'puppet-dashboard',
#   dashboard_password    => 'changeme',
#   dashboard_db          => 'dashboard_production',
#   dashboard_charset     => 'utf8',
#   dashboard_environment => 'production',
#   passenger             => false,
#   mysql_root_pw         => 'changemetoo',
#   rails_base_uri        => '/',
#   require               => Package['puppet-dashboard'],
  }

/* Handled by class dashboard

  package {'rubygem-rake':
    ensure  =>  latest,
  }

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

/*
TODO
fix puppet-dashboard stop + start errors complaining about 
config.gem: Unpacked gem mocha-0.9.7 in vendor/gems has no specification file.
Run 'rake gems:refresh_specs' to fix this.

cd /usr/share/puppet-dashboard/vendor/gems ; rake gems:refresh_specs


ln -s /usr/share/puppet-dashboard/log/production.log /var/log/puppet
*/
