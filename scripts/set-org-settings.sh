#!/bin/sh
apiversion="55.0"
baseDir="sm/sm-base/main/default/settings"

declare -a settingsArray=(
  "$baseDir/Order.settings-meta.xml"
  "$baseDir/Quote.settings-meta.xml"
  "$baseDir/SubscriptionManagement.settings-meta.xml"
  "$baseDir/InvLatePymntRiskCalc.settings-meta.xml"
  "$baseDir/PaymentsManagementEnabled.settings-meta.xml"
  "$baseDir/Communities.settings-meta.xml"
)

function echo_attention() {
  local green='\033[0;32m'
  local no_color='\033[0m'
  echo "${green}$1${no_color}"
}

function echo_blue() {
  local blue='\033[0;34m'
  local no_color='\033[0m'
  echo "${blue}$1${no_color}"
}

function error_and_exit() {
  echo "$1"
  exit 1
}

function deploy() {
  sfdx force:source:deploy -p "$1" -g --apiversion=$apiversion
}

function deploy_settings() {
  local ps=("$@")
  local delim=""
  local joined=""
  for i in "${ps[@]}"; do
    joined="$joined$delim$i"
    delim=","
  done
  echo_attention "Deploying default org settings"
  #echo_blue $joined
  deploy $joined
}

deploy_settings "${settingsArray[@]}"