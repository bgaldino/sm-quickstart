#!/bin/bash
# shellcheck shell=bash

. ./scripts/constants.sh
. ./scripts/functions.sh

# change to 0 for items that should be skipped - the script will soon start to get/set these values as part of an error handling process
#insertData=false
deployCode=true
#createGateway=true
#createTaxEngine=true
createCommunity=true
#installPackages=true
includeCommunity=true
deployCommunity=true
includeCommerceConnector=true
createConnectorStore=true
includeConnectorStoreTemplate=true
deployConnectorStore=false
registerCommerceServices=false
createStripeGateway=false
deployConnectedApps=true

# runtime variables
export cdo=false
export sdo=false
export xdo=false
export rcido=false
export mfgido=false
export autoido=false
export sbqq=false
export blng=false
export b2bvp=false
export cpqsm=false
export smon=false

orgType=0

sfdx=$(get_sfdx)

check_qbranch
if ! $rcido; then
  echo_color red "The setup_smartbytes.sh script is only for a Revenue Cloud IDO.  You must either create a new Revenue Cloud IDO or run the regular setup.sh script to set up other environemnts.  Exiting."
  exit 1
fi
set_sfdx_user_info
get_sfdx_user_info
convert_files

if $createCommunity; then
  echo_color green "Checking for existing Subscription Management Customer Account Portal Digital Experience"
  storeId=$(get_record_id Network Name "$COMMUNITY_NAME")
  if [ -z "$storeId" ]; then
    create_sm_community
  else
    echo_color green "Subscription Management Customer Account Portal Digital Experience already exists"
  fi
fi

if $includeCommunity; then
  while [ -z "${storeId}" ]; do
    echo_color green "Subscription Management Customer Community not yet created, waiting 10 seconds..."
    storeId=$(get_record_id Network Name "$COMMUNITY_NAME")
    sleep 10
  done

  echo_color cyan "Subscription Management Customer Community found with id ${storeId}"
  echo_keypair storeId "$storeId"
  echo ""
  rolesQuery="SELECT COUNT(Id) FROM UserRole WHERE Name = 'CEO'"
  roles=$($sfdx data query -q "$rolesQuery" -r csv | tail -n +2)

  if [ "$roles" = "0" ]; then
    $sfdx data create record -s UserRole -v "Name='CEO' DeveloperName='CEO' RollupDescription='CEO'"
  else
    echo_color green "CEO Role already exists - proceeding without creating it."
  fi

  ceoRoleId=$(get_record_id UserRole Name CEO)
  echo_color green "CEO role ID: "
  echo_keypair ceoRoleId "$ceoRoleId"
  $sfdx data update record -s User -v "UserRoleId='$ceoRoleId' Country='United States'" -w "Username='$SFDX_USERNAME'"
fi

if [ -z "$pricebook1" ]; then
  pricebook1=$(get_standard_pricebook_id)
  echo_keypair pricebook1 "$pricebook1"
  sleep 1
fi

if [ -z "$paymentGatewayProviderId" ]; then
  echo_color green "Getting Payment Gateway Provider $PAYMENT_GATEWAY_PROVIDER_NAME"
  paymentGatewayProviderId=$(get_record_id PaymentGatewayProvider DeveloperName "$PAYMENT_GATEWAY_PROVIDER_NAME")
  echo_keypair paymentGatewayProviderId "$paymentGatewayProviderId"
fi

if [ -z "$paymentGatewayId" ]; then
  paymentGatewayId=$(get_payment_gateway_id "$paymentGatewayProviderId")
  echo_keypair paymentGatewayId "$paymentGatewayId"
  sleep 1
fi

prepare_experiences_directory

# replace Admin profile in sm-temp for rc-ico
if $rcido; then
  cp -f quickstart-config/rc-ido/profiles/Admin.profile-meta.xml $SM_CONNECTED_APPS_DIR/default/profiles/.
fi

echo_color green "Getting Default Account and Contact IDs"
defaultAccountId=$(get_record_id Account Name "$DEFAULT_ACCOUNT_NAME")

if [ -z "$defaultAccountId" ]; then
  echo_color red "Default Account not found, exiting"
  exit 1
fi

echo_color green "Default Customer Account ID: "
echo_keypair defaultAccountId "$defaultAccountId"

if $includeCommerceConnector; then
  echo_color green "Checking for existing TaxEngine $TAX_PROVIDER_CLASS_NAME"
  taxEngineId=$(get_record_id TaxEngine TaxEngineName "$TAX_PROVIDER_CLASS_NAME")
  populate_b2b_connector_custom_metadata_smartbytes
fi

deploy "sm/sm-base/main/default/settings/Site.settings-meta.xml"
deploy "sm/sm-base/main/default/settings/ExperienceBundle.settings-meta.xml"
deploy "sm/sm-temp/main/default/objects/Invoice/Invoice.object-meta.xml"
# These are temporary fixes for the heroku sample service decommissioning effective 9/25/2023
deploy "sm/sm-b2b-connector-temp/main/default/classes/B2BShipmentConnector.cls"
deploy "sm/sm-b2b-connector-temp/main/default/classes/B2BDeliverySample_58.cls"

if $deployCode; then
  deploy_component "$deployCommunity" "Deploying $COMMUNITY_TEMPLATE_DIR to the org. This will take a few minutes..." "$COMMUNITY_TEMPLATE_DIR"
  #deploy_component "$deployConnectorStore" "Deploying $CONNECTOR_STORE_TEMPLATE_DIR to the org. This will take a few minutes..." "$CONNECTOR_STORE_TEMPLATE_DIR"
  deploy_component "$deployConnectedApps" "Pushing $SM_CONNECTED_APPS_DIR to the org. This will take a few minutes..." "$SM_CONNECTED_APPS_DIR"
fi

if $includeCommerceConnector && $deployConnectedApps; then
  echo_color green "Extracting consumer key from connected app and replacing in custom metadata"
  populate_b2b_connector_custom_metadata_consumer_key
  deploy $B2B_CUSTOM_METADATA_CONSUMER_KEY
  deploy $B2B_CONNECTED_APP
fi

if $includeCommunity; then
  $sfdx community publish -n "$COMMUNITY_NAME"
fi

if $includeCommerceConnector; then
  if [ -n "$commerceStoreId" ] && $registerCommerceServices; then
    register_commerce_services
    if $createStripeGateway; then
      create_stripe_gateway
    fi
  fi
  echo_color green "Publishing B2B Connector Store $B2B_STORE_NAME"
  $sfdx community publish -n "$B2B_STORE_NAME"
  if [ -z "$commerce_plugin" ] || ! $commerce_plugin; then
    check_sfdx_commerce_plugin
  fi
  if $commerce_plugin; then
    echo_color green "Building Search Index for B2B Connector Store $B2B_STORE_NAME"
    $sfdx commerce search start -n "$B2B_STORE_NAME"
  fi
fi

echo_color green "All operations completed - opening configured org in google chrome"

case $(uname -o | tr '[:upper:]' '[:lower:]') in
msys)
  open_org setup
  ;;
*)
  open_org setup chrome
  ;;
esac
