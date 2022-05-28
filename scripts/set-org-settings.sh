#!/bin/sh
apiVersion="55.0"

function echo_attention() {
  local green='\033[0;32m'
  local no_color='\033[0m'
  echo "${green}$1${no_color}"
}

baseDir="sm/sm-base/main"
sfdx force:source:deploy -p $baseDir/default/settings/Order.settings-meta.xml --apiversion=$apiVersion
sfdx force:source:deploy -p $baseDir/default/settings/Quote.settings-meta.xml --apiversion=$apiVersion
sfdx force:source:deploy -p $baseDir/default/settings/SubscriptionManagement.settings-meta.xml --apiversion=$apiVersion
sfdx force:source:deploy -p $baseDir/default/settings/InvLatePymntRiskCalc.settings-meta.xml --apiversion=$apiVersion
sfdx force:source:deploy -p $baseDir/default/settings/PaymentsManagementEnabled.settings-meta.xml --apiversion=$apiVersion
sfdx force:source:deploy -p $baseDir/default/settings/Communities.settings-meta.xml --apiversion=$apiVersion
