#!/bin/sh

apiversion="57.0"
baseDir="sm/sm-base/main/default/settings"
SFDX_RC_VERSION=7.195
settingsArray=(
  "$baseDir/Order.settings-meta.xml"
  "$baseDir/Quote.settings-meta.xml"
  "$baseDir/SubscriptionManagement.settings-meta.xml"
  "$baseDir/InvLatePymntRiskCalc.settings-meta.xml"
  "$baseDir/ExperienceBundle.settings-meta.xml"
  #  "$baseDir/PaymentsManagementEnabled.settings-meta.xml"
  #  "$baseDir/Communities.settings-meta.xml"
  "$baseDir/Commerce.settings-meta.xml"
)

echo_attention() {
  printf '\033[0;32m%s\033[0m\n' "$1"
}

echo_blue() {
  printf '\033[0;34m%s\033[0m\n' "$1"
}

error_and_exit() {
  echo "$1"
  exit 1
}

function sfdx_version() {
  sfdx --version | grep "sfdx-cli" | awk '{print $1}' | cut -d "/" -f 2 | cut -d "." -f 1,2 | bc
}

deploy() {
  if [ "$(echo "$local_sfdx == $SFDX_RC_VERSION" | bc)" -ge 1 ]; then
    #sfdx project deploy start -d $baseDir -a $apiversion -w 10
    sfdx project deploy start -g -c -r -d $baseDir -a $apiversion -l NoTestRun
  else
    sfdx force:source:deploy -p $baseDir
  fi
}

deploy_settings() {
  local joined=$(printf '%s,' "${settingsArray[@]}")
  joined=${joined%,}
  echo_attention "Deploying default org settings"
  deploy "$joined"
}

if ! command -v sfdx &> /dev/null; then
  error_and_exit "sfdx command not found. Please install the Salesforce CLI and try again."
fi
local_sfdx=$(sfdx_version)
deploy_settings