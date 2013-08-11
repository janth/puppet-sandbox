#!/bin/bash

# vim:background=dark:foldmethod=syntax

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

currentdir=$PWD
list=${script_basedir}/VagrantConf/modules.txt
moduledir=${script_basedir}/VagrantConf/modules
if [[ ! -r ${list} ]] ; then
   logg "ERROR: Can't read '${list}'"
   exit 1
fi

#cat --squeeze-blank site/modules.txt | while read -a line ; do
#egrep -v "^#|^$" site/modules.txt | while read -a line ; do
while read -a line ; do
  # Skip comments
  [[ "${line}" =~ ^#.*$ ]] && continue
  [[ "${line}" =~ ^$ ]] && continue

  repo=${line[0]}
  module=${repo##*/}
  module=${module%%.*}
  path=${moduledir}/${line[1]}
  ref=${line[2]}

  if [[ ! -d ${path} ]]; then
    logg "[${path}] Cloning module ${module} from ${repo} into ${path}"
    git clone --quiet ${repo} ${path}
  else
    logg "[${path}] Running git pull origin"
    ( cd ${path} && git pull origin )
    cd ${currentdir}
  fi

  logg "[${path}] Checking out ${ref}"
  ( cd ${path} && git checkout ${ref} )
  cd ${currentdir}

done < ${list}

 : << X

mkdir -p modules hieradata/nodes site/sitelib

# read by ../modules-update.sh
# whitespace separated
# giturl module-path release-hash

git://github.com/stahnma/puppet-module-epel.git                modules/epel               4fc5b13bc3
git://github.com/stahnma/puppet-module-puppetlabs_yum.git      modules/puppetlabs_yum     15d87ae0c5
git://github.com/ripienaar/puppet-concat.git                   modules/concat             8c9615dd4e
git://github.com/puppetlabs/puppetlabs-stdlib.git              modules/stdlib             6f9361e383
X
