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
    ensure  =>  latest,
    require => Host['puppet.home.lan'],
  }

  package {'puppetdb':
    ensure  =>  latest,
    require => Host['puppet.home.lan'],
  }
  /*
  */
}
