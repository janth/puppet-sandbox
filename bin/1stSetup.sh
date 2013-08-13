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
got_curl=0
got_wget=0
got_puppet=0
progs_missing=0

# Check executables
[[ $( type -P curl ) = '/usr/bin/curl' ]] && got_curl=1
[[ $( type -P wget ) = '/usr/bin/wget' ]] && got_wget=1

if [[ $( type -P git ) == '' ]] ; then
   logg "\nERROR: Can't find git on this host\nPlease get git from http://git-scm.com/downloads/ (or use sudo yum or apt-get install git)\n"
   progs_missing=$((progs_missing + 1))
fi

if [[ $( type -P vagrant ) == '' ]] ; then
   logg "ERROR: Can't find vagrant on this host\nPlease get vagrant from http://downloads.vagrantup.com/"
   progs_missing=$((progs_missing + 1))
else 
   version_num=$( vagrant -v | awk '{print $NF}' | sed -e 's/\.//g' )
   if [[ ${version_num} -lt 127 ]] ; then
      logg "ERROR: vagrant version too low: ${version}, we need at least 1.2.7\nPlease get vagrant from http://downloads.vagrantup.com/"
      progs_missing=$((progs_missing + 1))
   fi
fi

if [[ $( type -P VBoxManage ) == '' ]] ; then
   logg "ERROR: Can't find VirtualBox (VBoxManage) on this host\nPlease get VirtualBox from https://www.virtualbox.org/wiki/Downloads"
   progs_missing=$((progs_missing + 1))
fi
if [[ $( type -P puppet ) == '' ]] ; then
   logg "WARNING: Can't find puppet on this host\nIf you want to install puppet, use the instructions on http://docs.puppetlabs.com/guides/puppetlabs_package_repositories.html\n"
else
   got_puppet=1
fi
if [[ ${progs_missing} -gt 0 ]] ; then
   logg "One or more errors detected. Please correct and the re-run ${script_name}\n"
   exit 1
fi
logg "Required binaries {culr/wget,git,VBoxManage,vagrant} checked and found ok"

grep -Eq '^172.16.10.1[0-2]\s+' /etc/hosts
if [[ $? -eq 1 ]] ; then
   if [[ ${got_puppet} -eq 0 ]] ; then
      logg "\nPlease add the following to your /etc/hosts, for easy ssh to the boxes:\n(content from ${script_path}/addme-etc-hosts):\n\n"
      cat ${script_path}/addme-etc-hosts
      echo -e "\n"
   else
      logg "Adding puppetmaster and clients to /etc/hosts, using puppet"
      # This doesn't work, how to specify an array to host_aliases on the cli
      #sudo puppet resource host puppet.evry.dev ensure=present host_aliases="['puppet', 'pm']" ip=172.16.10.10 target=/etc/hosts

      fixit=/tmp/fixit.pp
      cat > ${fixit} <<X
node default {
  host { 'puppet.evry.dev':
    ensure       => 'present',
    host_aliases => ['puppet', 'pm'],
    ip           => '172.16.10.10',
    target       => '/etc/hosts',
    comment      => 'Added by ${script_path_name} for easy access to EVRY Puppet Lab boxes',
  }

  host { 'client1.evry.dev':
    ensure       => 'present',
    host_aliases => ['client1', 'c1'],
    ip           => '172.16.10.11',
    target       => '/etc/hosts',
    comment      => 'Added by ${script_path_name} for easy access to EVRY Puppet Lab boxes',
  }

  host { 'client2.evry.dev':
    ensure       => 'present',
    host_aliases => ['client2', 'c2'],
    ip           => '172.16.10.12',
    target       => '/etc/hosts',
    comment      => 'Added by ${script_path_name} for easy access to EVRY Puppet Lab boxes',
  }
}
X
      sudo puppet apply ${fixit}
      rm ${fixit}
   fi
else logg "/etc/hosts OK"
fi

grep -q '^host 172.16.10.* pm puppetmaster c1 c2 client1 client2' $HOME/.ssh/config
if [[ $? -ne 0 ]] ; then
   logg "\nPlease add this to your ~/.ssh/config for easy ssh-access to the lab-boxes:\n(content from ${script_path}/addme-ssh-config):\n\n"
   #cat ${script_path}/addme-ssh-config | sed "s/\$USER/$USER/"
   while read line ; do
      eval echo "${line}"
   done < ${script_path}/addme-ssh-config
   echo -e "\n"
else logg "\~/.ssh/config OK"
fi

if [[ ! -r $HOME/.ssh/vagrant || ! -r $HOME/.ssh/vagrant.pub ]] ; then
   logg "getting vagrant keys"
   if [[ ${got_curl} -eq 0 ]] ; then
      if [[ ${got_wget} -eq 0 ]] ; then
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
else logg "vagrant ssh-rsa keys OK"
fi

## logg "These boxes are currently defined in vagrant:\n"
## vagrant box list
## echo -e "\n"
## logg "These boxes are currently used in EVRY LAB Vagrantfile ${script_basedir}/Vagrantfile:\n"
## grep -o ":box => '.*',"  ${script_basedir}/Vagrantfile
## echo -e "\n"
## logg "If boxes are missing from vagrant, please load the box(es) first:\n"
## cat <<X
## copy the *.box files from http://212.18.136.81/vagrant/boxes/ to your PC
## (or load them directly):
## load the box into vagrant:
## 
## vagrant box add boxname path/url
## 
## NB! The boxname must match boxname in EVRY LAB Vagrantfile ${script_path}/Vagrantfile
## check with
## vagrant box list
## and
## grep -o ":box => '.*',"  ${script_path}/Vagrantfile
## 
## X

logg "Now getting required 3rdparty modules, using ${script_path}/modules-update.sh"
${script_path}/modules-update.sh

logg "\n\nIf everything is ok, you may now proceed with:\nvagrant up puppet\nvagrant provision puppet (repeat untill no errors!)\nvagrant up client1\n"
