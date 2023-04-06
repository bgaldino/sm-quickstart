#!/bin/sh

apiversion="57.0"
baseDir="sm/sm-base/main/default/settings"

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

deploy() {
  sfdx project deploy start -d $baseDir -a $apiversion -w 10
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

deploy_settings