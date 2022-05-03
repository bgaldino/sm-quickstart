#!/bin/sh
apiVersion="55.0";

function echo_attention() {
  local green='\033[0;32m'
  local no_color='\033[0m'
  echo "${green}$1${no_color}"
}

defaultDir="../sm/main";
sfdx force:source:deploy -p $defaultDir/default/settings/Order.settings-meta.xml --apiversion=$apiVersion
sfdx force:source:deploy -p $defaultDir/default/settings/Quote.settings-meta.xml --apiversion=$apiVersion
sfdx force:source:deploy -p $defaultDir/default/settings/SubscriptionManagement.settings-meta.xml --apiversion=$apiVersion
sfdx force:source:deploy -p $defaultDir/default/settings/InvLatePymntRiskCalc.settings-meta.xml --apiversion=$apiVersion
sfdx force:source:deploy -p $defaultDir/default/settings/PaymentsManagementEnabled.settings-meta.xml --apiversion=$apiVersion
#sfdx force:source:deploy -p $defaultDir/default/classes/MockAdapter.cls --apiversion=$apiVersion
#sfdx force:source:deploy -p $defaultDir/default/classes/SalesforceValidationException.cls --apiversion=$apiVersion
#sfdx force:source:deploy -p $defaultDir/default/classes/SalesforceAdapter.cls --apiversion=$apiVersion