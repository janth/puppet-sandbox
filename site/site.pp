# Work around the fact that we cannot trust facts ;->
# See  http://projects.puppetlabs.com/issues/19514
# $verifiedcert = certcheck()

#
node default {
  # include epel
  # include puppetlabs_yum
  # include apache

  host { 'puppet.home.lan':
    ensure       => 'present',
    host_aliases => ['puppet'],
    ip           => '172.16.10.10',
    target       => '/etc/hosts',
  }

  package {'puppet-server':
    ensure  =>  latest,
    require => Host['puppet.home.lan'],
  }

  package {'puppet-dashboard':
    # Doc: http://docs.puppetlabs.com/dashboard/manual/1.2/bootstrapping.html
    ensure  =>  latest,
    require => Host['puppet.home.lan'],
    # config/database.yml
    # config/settings.yml 
  }

  package {'puppetdb':
    ensure  =>  latest,
    require => Host['puppet.home.lan'],
  }

  /*
node puppetmaster {
  # Doc: http://forge.puppetlabs.com/puppetlabs/puppetdb
  # Configure puppetdb and its underlying database
  class { 'puppetdb': }
  # Configure the puppet master to use puppetdb
  class { 'puppetdb::master::config': }
}

$ sudo puppet resource service puppet ensure=running enable=true
$ sudo puppet resource service puppetmaster ensure=running enable=true
add vagrant to group puppet; read /var/log/puppet without sudo
  */
  notify {"I'm notifying you.":}

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
      content => "This Learning Puppet VM's IP address is ${ipaddress}. It thinks its
    hostname is ${fqdn}, but you might not be able to reach it there
    from your host machine. It is running ${operatingsystem} ${operatingsystemrelease} and
    Puppet ${puppetversion}.
    Web console login:
      URL: https://${ipaddress_eth0}
      User: puppet@example.com
      Password: learningpuppet
    ",
    }

  */
}
