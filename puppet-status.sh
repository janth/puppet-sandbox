#!/bin/bash

# vim:background=dark:foldmethod=syntax:ft=sh

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
   tstamp=$( date +'%Y-%m-%d %H:%M:%S' )
   echo -e "\033[33;1m[${tstamp}] ${script_name}\033[0m: ${1}"
}

for service in iptables puppet puppetmaster puppet-dashboard puppet-dashboard-workers puppetdb puppetqueue mysqld postgresql ; do 
   logg "service ${service} /etc/init.d/${service} status:"
   sudo /etc/init.d/${service} status
   echo
done

sudo netstat -tlpn
