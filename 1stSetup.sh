#!/bin/bash

# vim:background=dark:foldmethod=syntax:ft=sh

#####
# Copyright 2012- Jan Thomas Moldung
# git http: https://github.com/janth/cos.git
# git readonly: git://github.com/janth/cos.git
#####

script_name=${0##*/}                               # Basename, or drop /path/to/file
script=${script_name%%.*}                          # Drop .ext.a.b
script_path=${0%/*}                                # Dirname, or only /path/to
script_path=$( [[ -d ${script_path} ]] && cd ${script_path} ; pwd)             # Absolute path
script_path_name="${script_path}/${script_name}"   # Full path and full filename to $0
script_basedir=${script_path%/*}                   # basedir, if script_path is .../bin/


# WARNING: Intentionally no submodule support!

# set -o <option> enables, set +o <option> disables option...
set -o noglob        # Don't glob
set -o pipefail      #
set -o allexport     # export all variables
set -o braceexpand   # expand {a,b} to a b
#set -o errexit      # -e, exit on first command not returning 0
#set -o nounset       # Abort on unset variables
#set -o xtrace       # -x, debug

shopt -s xpg_echo    # Let echo parse escapecodes by default

#####
# Functions
#####

logg () {
   tstamp=$(date +'%Y-%m-%d %H:%M:%S')
   echo -e "\033[33;1m[${tstamp}] ${script_name}\033[0m: ${1}"
}

date=$( date +'%Y-%m-%d %H:%M' )
user=$( id -un )
modbase=modules

if [[ $( type -P puppet ) != '/usr/bin/puppet' ]] ; then
   logg "\nWARNING: Can't find puppet on this host\nIf you want to install puppet, use the instructions on http://docs.puppetlabs.com/guides/puppetlabs_package_repositories.html\n"
   logg "\nPlease add the following to your /etc/hosts, for easy ssh to the boxes:\n"
   cat <<X

172.16.10.10   puppet.evry.dev   puppet pm
172.16.10.11   client1.evry.dev  client1 c1
172.16.10.12   client2.evry.dev  client2 c2

X
else

   logg "Adding puppetmaster and clients to /etc/hosts, using puppet"
   # This doesn't work, how to specify an array to host_aliases on the cli
   #sudo puppet resource host puppet.evry.dev ensure=present host_aliases="['puppet', 'pm']" ip=172.16.10.10 target=/etc/hosts
   #sudo puppet resource host client1.evry.dev ensure=present host_aliases=client1 ip=172.16.10.11 target=/etc/hosts
   #sudo puppet resource host client2.evry.dev ensure=present host_aliases=client2 ip=172.16.10.12 target=/etc/hosts

   fixit=/tmp/fixit.pp
   cat > ${fixit} <<X
   node default {
     host { 'puppet.evry.dev':
       ensure       => 'present',
       host_aliases => ['puppet', 'pm'],
       ip           => '172.16.10.10',
       target       => '/etc/hosts',
     }

     host { 'client1.evry.dev':
       ensure       => 'present',
       host_aliases => ['client1', 'c1'],
       ip           => '172.16.10.11',
       target       => '/etc/hosts',
     }

     host { 'client2.evry.dev':
       ensure       => 'present',
       host_aliases => ['client2', 'c2'],
       ip           => '172.16.10.12',
       target       => '/etc/hosts',
     }
   }
X

   sudo puppet apply ${fixit}
   rm ${fixit}
fi

logg "Now getting required 3rdparty modules"
${script_path}/modules-update.sh

if [[ $( type -P curl ) != '/usr/bin/curl' ]] ; then
   if [[ $( type -P wget ) != '/usr/bin/wget' ]] ; then
      logg "\nERROR: Can't find curl or wget on this host\nPlease get the ssh keys yourself by other means:\n"
      echo "... https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub > $HOME/.ssh/vagrant.pub"
      echo "... https://raw.github.com/mitchellh/vagrant/master/keys/vagrant > $HOME/.ssh/vagrant"
   else
      logg "Getting Vagrant ssh keys from https://github.com/mitchellh/vagrant/tree/master/keys using wget"
      wget --output-document=$HOME/.ssh/vagrant.pub https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub
      wget --output-document=$HOME/.ssh/vagrant     https://raw.github.com/mitchellh/vagrant/master/keys/vagrant
   fi
else
   logg "Getting Vagrant ssh keys from https://github.com/mitchellh/vagrant/tree/master/keys using curl"
   curl --no-verbose --no-progress-bar --no-cookie-jar --no-include https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub > $HOME/.ssh/vagrant.pub
   curl --no-verbose --no-progress-bar --no-cookie-jar --no-include https://raw.github.com/mitchellh/vagrant/master/keys/vagrant > $HOME/.ssh/vagrant
fi



logg "\nPlease add this to your ~/.ssh/config for easy ssh-access to the lab-boxes:\n(content from addme-ssh-config):\n\n"
cat ${script_path}/addme-ssh-config
echo -e "\n"

if [[ $( type -P vagrant ) != '/usr/bin/vagrant' ]] ; then
   logg "\nERROR: Can't find vagrant on this host\nPlease get vagrant from http://downloads.vagrantup.com/\n"
   exit 1
fi

version=$( vagrant -v | awk '{print $NF}')
version_num=$( vagrant -v | awk '{print $NF}' | sed -e 's/\.//g' )
if [[ ${version_num} -lt 127 ]] ; then
   logg "\nERROR: vagrant version too low: ${version}, we need at least 1.2.7\nPlease get vagrant from http://downloads.vagrantup.com/\n"
   exit 1
fi

if [[ $( type -P VBoxManage ) != '/usr/bin/VBoxManage' ]] ; then
   logg "\nERROR: Can't find VirtualBox (VBoxManage) on this host\nPlease get VirtualBox from https://www.virtualbox.org/wiki/Downloads\n"
   exit 1
fi

logg "These boxes are currently defined in vagrant:"
vagrant box list
logg "These boxes are currently used in EVRY LAB Vagrantfile ${script_path}/Vagrantfile:"
grep -o ":box => '.*',"  ${script_path}/Vagrantfile
logg "If boxes are missing from vagrant, please load the box(es) first:\n"
cat <<X
copy the *.box files from http://212.18.136.81/vagrant/boxes/ to your PC
(or load them directly):
load the box into vagrant:

vagrant box add boxname path/url

NB! The boxname must match boxname in EVRY LAB Vagrantfile ${script_path}/Vagrantfile
check with
vagrant box list
and
grep -o ":box => '.*',"  ${script_path}/Vagrantfile

X

logg "\n\nIf everything is ok, you may now proceed with:\nvagrant up puppet\nvagrant provision puppet (repeat untill no errors!)\nvagrant up client1\n"
