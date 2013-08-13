#!/bin/bash

usage() {
  echo $0 <MODULE_PATH>
}

test -z "$1" && { usage(); exit 1; }
test -d "$1" && { usage(); exit 1; }

# remove old style references in dashboard module templates
sed -i 's/@dashboard_/dashboard_/g' $1/dashboard/templates/*.erb #in case they fixed it we first un-fix it
sed -i 's/dashboard_/@dashboard_/g' $1/dashboard/templates/*.erb #then we fix it:-)
