#!/bin/bash
# shellcheck shell=bash

. ./scripts/constants.sh
. ./scripts/functions.sh
export SFDX_NPM_REGISTRY="http://platform-cli-registry.eng.sfdc.net:4880/"
export SFDX_S3_HOST="http://platform-cli-s3.eng.sfdc.net:9000/sfdx/media/salesforce-cli"

# change to 0 for items that should be skipped - the script will soon start to get/set these values as part of an error handling process
#insertData=false
#deployCode=true
#createGateway=true
#createTaxEngine=true
createCommunity=true
#installPackages=true
includeCommunity=true
includeCommerceConnector=true
createConnectorStore=true
includeConnectorStoreTemplate=true
registerCommerceServices=false
createStripeGateway=false
deployConnectedApps=true

# runtime variables
cdo=1
#sdo=0
#xdo=0
rcido=0
#mfgido=0
sbqq=0
blng=0
b2bvp=0
#cpqsm=1

orgType=0

check_qbranch
if [ $rcido != 1 ]; then
  echo_color red "The setup_smartbytes.sh script is only for a Revenue Cloud IDO.  You must either create a new Revenue Cloud IDO or run the regular setup.sh script to set up other environemnts.  Exiting."
  exit 1
fi
set_sfdx_user_info
get_sfdx_user_info
convert_files

if [ $createCommunity == true ]; then
  echo_color green "Checking for existing Subscription Management Customer Account Portal Digital Experience"
  storeId=$(get_record_id Network Name $COMMUNITY_NAME)
  if [ -z "$storeId" ]; then
    echo_color green "Creating Subscription Management Customer Account Portal Digital Experience"
    sfdx community create -n "$COMMUNITY_NAME" -t "Customer Account Portal" -p "$COMMUNITY_NAME" -d "Customer Portal created by Subscription Management Quickstart"
  else
    echo_color green "Subscription Management Customer Account Portal Digital Experience already exists"
  fi
fi

if [ $includeCommunity == true ]; then
  while [ -z "${storeId}" ]; do
    echo_color green "Subscription Management Customer Community not yet created, waiting 10 seconds..."
    storeId=$(get_record_id Network Name $COMMUNITY_NAME)
    sleep 10
  done

  echo_color cyan "Subscription Management Customer Community found with id ${storeId}"
  echo_keypair storeId "$storeId"
  echo ""

  roles=$(sfdx data query --query \ "SELECT COUNT(Id) FROM UserRole WHERE Name = 'CEO'" -r csv | tail -n +2)

  if [ "$roles" = "0" ]; then
    sfdx data create record -s UserRole -v "Name='CEO' DeveloperName='CEO' RollupDescription='CEO'"
    sleep 1
  else
    echo_color green "CEO Role already exists - proceeding without creating it."
  fi

  ceoRoleId=$(get_record_id UserRole Name CEO)

  echo_color green "CEO role ID: "
  echo_keypair ceoRoleId "$ceoRoleId"
  sleep 1

  sfdx data update record -s User -v "UserRoleId='$ceoRoleId' Country='United States'" -w "Username='$SFDX_USERNAME'"
  sleep 1
fi

if [ -z "$pricebook1" ]; then
  pricebook1=$(sfdx data query -q "SELECT Id FROM Pricebook2 WHERE Name='$STANDARD_PRICEBOOK_NAME' AND IsStandard=true LIMIT 1" -r csv | tail -n +2)
  echo_keypair pricebook1 "$pricebook1"
  sleep 1
fi

if [ -z "$paymentGatewayProviderId" ]; then
    echo_color green "Getting Payment Gateway Provider $PAYMENT_GATEWAY_PROVIDER_NAME"
    paymentGatewayProviderId=$(get_record_id PaymentGatewayProvider DeveloperName $PAYMENT_GATEWAY_PROVIDER_NAME)
    echo_keypair paymentGatewayProviderId "$paymentGatewayProviderId"
fi

if [ -z "$paymentGatewayId" ]; then
  paymentGatewayId=$(sfdx data query -q "SELECT Id FROM PaymentGateway WHERE PaymentGatewayName='$PAYMENT_GATEWAY_NAME' AND PaymentGatewayProviderId='$paymentGatewayProviderId' LIMIT 1" -r csv | tail -n +2)
  echo_keypair paymentGatewayId "$paymentGatewayId"
  sleep 1
fi

if [ -n "$pricebook1" ] && [ -n "$paymentGatewayId" ]; then
  tmpfile=$(mktemp)
  sed -e "s/INSERT_GATEWAY/$paymentGatewayId/g;s/INSERT_PRICEBOOK/$pricebook1/g" quickstart-config/home.json >"$tmpfile"
  mv -f "$tmpfile" $COMMUNITY_TEMPLATE_DIR/default/experiences/${COMMUNITY_NAME}1/views/home.json
else
  error_and_exit "Could not retrieve Pricebook or Payment Gateway.  Exiting before pushing community template"
fi

# quick fix for developer/falcon
# TODO - Refactor into function
if [ "$orgType" == 4 ] || [ "$orgType" == 3 ] || [ $rcido -eq 1 ]; then
  rm -f $COMMUNITY_TEMPLATE_DIR/default/experiences/${COMMUNITY_NAME}1/{views/articleDetail.json,routes/articleDetail.json,views/topArticles.json,routes/topArticles.json}
fi

# replace Admin profile in sm-temp for rc-ico
if [ $rcido = 1 ]; then
  cp -f quickstart-config/rc-ido/profiles/Admin.profile-meta.xml $SM_CONNECTED_APPS_DIR/default/profiles/.
fi

echo_color green "Getting Default Account and Contact IDs"
defaultAccountId=$(get_record_id Account Name "$DEFAULT_ACCOUNT_NAME")
#defaultAccountId=$(sfdx data query -q "SELECT Id FROM Account WHERE Name='$DEFAULT_ACCOUNT_NAME' LIMIT 1" -r csv | tail -n +2)
echo_keypair defaultAccountId "$defaultAccountId"

if [ -z "$defaultAccountId" ]; then
  echo_color red "Default Account not found, exiting"
  exit 1
fi

if [ $includeCommerceConnector == true ]; then
    echo_color green "Checking for existing TaxEngine $TAX_PROVIDER_CLASS_NAME"
    taxEngineId=$(get_record_id TaxEngine TaxEngineName $TAX_PROVIDER_CLASS_NAME)
    populate_b2b_connector_custom_metadata_smartbytes
fi

if [ $deployConnectedApps == true ]; then
    echo_color green "Pushing sm-connected-apps to the org. This will take a few minutes..."
    deploy $SM_CONNECTED_APPS_DIR
else
    echo_color green "Connected Apps are not being deployed.  They must be deployed later or created manually."
fi

if [ $includeCommunity == true ]; then
  sfdx community publish -n "$COMMUNITY_NAME"
fi

if [ $includeCommerceConnector == true ]; then
  if [ -n "$commerceStoreId" ] && [ $registerCommerceServices == true ]; then
    register_commerce_services
    if [ $createStripeGateway == true ]; then
      create_stripe_gateway
    fi
  fi
  echo_color green "Publishing B2B Connector Store $B2B_STORE_NAME"
  sfdx community publish -n "$B2B_STORE_NAME"
  if  [ -z "$commerce_plugin" ] || [ "$commerce_plugin" == false ]; then
    check_sfdx_commerce_plugin
  fi
  if [ "$commerce_plugin" == true ]; then
    echo_color green "Building Search Index for B2B Connector Store $B2B_STORE_NAME"
    sfdx commerce search start -n "$B2B_STORE_NAME"
  fi
fi

echo_color green "All operations completed - opening configured org in google chrome"
sfdx org open -p /lightning/setup/SetupOneHome/home --browser chrome