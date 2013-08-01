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

node puppet.evry.dev inherits basenode {
  include motd
  # FIXME This should not have to be duplicated...
  host { 'puppet.evry.dev':
    ensure       => present,
    host_aliases => ['puppet'],
    ip           => '172.16.10.10',
    target       => '/etc/hosts',
  }

  user { 'vagrant':
    ensure     => present,
    groups     => ['puppet', 'puppetdb', 'puppet-dashboard'],
    membership => minimum,
    require    => [ Package['puppet-server'], Package['puppet-dashboard'],
      Package['puppetdb'] ],
  }

  package {'puppet-server':
    ensure  =>  latest,
    require => Host['puppet.evry.dev'],
  }

  package {'puppet-dashboard':
    # Doc: http://docs.puppetlabs.com/dashboard/manual/1.2/bootstrapping.html
    # config/database.yml and config/settings.yml
    ensure  =>  latest,
    require => Host['puppet.evry.dev'],
  }

  # https://github.com/puppetlabs/puppetlabs-dashboard
  class {'dashboard':
    dashboard_ensure          => 'present',
    dashboard_user            => 'puppet-dbuser',
    dashboard_group           => 'puppet-dbgroup',
    dashboard_password        => 'changeme',
    dashboard_db              => 'dashboard_prod',
    dashboard_charset         => 'utf8',
    dashboard_site            => $fqdn,
    dashboard_port            => '8080',
    mysql_root_pw             => 'changemetoo',
    passenger                 => true,
  }

  package {'puppetdb':
    ensure  =>  latest,
    require => Host['puppet.evry.dev'],
  }
  # Doc: http://forge.puppetlabs.com/puppetlabs/puppetdb
  # Configure puppetdb and its underlying database
  #class { 'puppetdb': }
  # Configure the puppet master to use puppetdb
  #class { 'puppetdb::master::config': }
  notify {'puppetmaster setup on node puppetmaster complete.':}
  # puppetdb: http://puppetmaster:8080/
  # /etc/puppetdb/conf.d/database.ini
}

  /*
$ sudo puppet resource service puppet ensure=running enable=true
$ sudo puppet resource service puppetmaster ensure=running enable=true
add vagrant to group puppet; read /var/log/puppet without sudo
  */

  /*

    $apache = $operatingsystem ? {
      centos                => 'httpd',
      redhat                => 'httpd',
      /(?i)(ubuntu|debian)/ => 'apache2',
      default               => undef,
    }

# /root/examples/motd.pp

  file {'motd':
    ensure  => file,
    path    => '/etc/motd',
    mode    => 0644,
    content => "This Learning Puppet VM's IP address is ${ipaddress}.
    It thinks its hostname is ${fqdn}, but you might not be able to reach it
    there from your host machine. It is running ${operatingsystem}
    ${operatingsystemrelease} and Puppet ${puppetversion}.
  Web console login:
    URL: https://${ipaddress_eth0}
    User: puppet@example.com
    Password: learningpuppet
  ",
  }

  */
