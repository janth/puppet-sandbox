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
}
