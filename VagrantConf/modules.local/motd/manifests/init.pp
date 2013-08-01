# vim:ft=puppet:foldmethod=syntax
# Created by /home/et2441/EVRY/lab/mkmodule.sh at 2013-08-01 12:30 by et2441

# class to setup basic motd, include on all nodes
# https://github.com/ripienaar/puppet-concat

class motd {
  $motd = '/etc/motd'

  concat{$motd:
    owner => root,
    group => root,
    mode  => '0644',
  }

  concat::fragment{'motd_header':
    target      => $motd,
    content     => "\nThis EVRY Vagrant LAB Learning Puppet VM.
IP address is ${::ipaddress} and ${ipaddress_eth1}.
It thinks its hostname is ${::fqdn}, but you might not be able
to reach it there from your host machine.
It is running ${::operatingsystem} ${::operatingsystemrelease}
and Puppet ${::puppetversion}.

login: ssh -l vagrant ${ipaddress_eth1}
User: vagrant
Password: vagrant

\n\nPuppet modules on this server:\n\n",
    order       => 01,
  }

  # local users on the machine can append to motd by just creating
  # /etc/motd.local
  concat::fragment{'motd_local':
    ensure  => '/etc/motd.local',
    target  => $motd,
    order   => 15
  }
}

/*
# used by other modules to register themselves in the motd
define motd::register($content="", $order=10) {
  if $content == "" {
    $body = $name
  } else {
    $body = $content
  }

  concat::fragment{"motd_fragment_$name":
    target  => "/etc/motd",
    content => "    -- $body\n"
  }
}
*/
