#!/bin/sh
apiVersion="56.0"

function echo_attention() {
  local green='\033[0;32m'
  local no_color='\033[0m'
  echo "${green}$1${no_color}"
}

sfdx force:community:create --name "B2BSmConnector" --templatename "B2B Commerce" --urlpathprefix "B2BSmConnector" --description "B2B Commerce created by Subscription Management Quickstart"