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

# http://docs.puppetlabs.com/puppet/latest/reference/modules_fundamentals.html

while [[ ! -z $1 ]] ; do
  module=$1
  if [[ -d ${modbase}/${module} ]] ; then
    logg "WARNING: ${modbase}/${module} already exists! Skipping..."
    continue
  fi

  logg "Creating module ${modbase}/${module}"
  mkdir -p ${modbase}/${module}/{manifests,files,lib,templates,tests,spec}

  logg "Creating Modulefile ${modbase}/${module}/Modulefile"
  cat > ${modbase}/${module}/Modulefile <<X
name    '${module}'
version '1.0'
source 'git://git.sandsli.dnb.no/...FIXME:'
author '${user}'
summary 'FIXME:'
description 'FIXME:'
project_page 'http://git.sandsli.dnb.no/...FIXME:'

## Add dependencies, if any:
# dependency 'username/name', '>= 1.2.0'
X
  logg "Creating base manifest ${modbase}/${module}/manifests/init.pp"
  cat > ${modbase}/${module}/manifests/init.pp <<X
# vim:ft=puppet:foldmethod=syntax
# Created by ${script_path_name} at ${date} by ${user}

class ${module} {
   # ... to be created...
}
X

  [[ -x /usr/bin/tree ]] && ( cd ${modbase} ; tree -A --dirsfirst -L 2 ${module} )
  shift
done
