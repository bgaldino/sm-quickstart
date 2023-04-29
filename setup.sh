#!/bin/bash
# shellcheck shell=bash
export OS
OS="$(uname)"

. ./scripts/constants.sh
. ./scripts/functions.sh
export SFDX_NPM_REGISTRY="http://platform-cli-registry.eng.sfdc.net:4880/"
export SFDX_S3_HOST="http://platform-cli-s3.eng.sfdc.net:9000/sfdx/media/salesforce-cli"


# change to false for items that should be skipped - the script will soon start to get/set these values as part of an error handling process
export insertData=true
export deployCode=true
export createGateway=true
export createTaxEngine=true
export createCommunity=true
export installPackages=true
export includeCommunity=true
export includeCommerceConnector=true
export createConnectorStore=true
export includeConnectorStoreTemplate=true
export registerCommerceServices=true
export createStripeGateway=true
export deployConnectedApps=true

# runtime variables
export cdo=0
export sdo=0
export xdo=0
export rcido=0
export mfgido=0
export sbqq=0
export blng=0
export b2bvp=0
export cpqsm=0

declare -a smPermissionSets=(
  "SubscriptionManagementApplyCreditToInvoiceApi"
  "SubscriptionManagementBillingSetup"
  "SubscriptionManagementCalculateInvoiceLatePaymentRiskFeature"
  "SubscriptionManagementCalculatePricesApi"
  "SubscriptionManagementCalculateTaxesApi"
  "SubscriptionManagementCollectionsAgent"
  "SubscriptionManagementCollectionsManager"
  "SubscriptionManagementConvertNegativeInvoiceLinesToCreditApi"
  "SubscriptionManagementCreateBillingScheduleFromOrderItemApi"
  "SubscriptionManagementCreateInvoiceFromBillingScheduleApi"
  "SubscriptionManagementCreateInvoiceFromOrderApi"
  "SubscriptionManagementCreateOrderFromQuote"
  "SubscriptionManagementCreditAnInvoiceApi"
  "SubscriptionManagementCreditMemoRecoveryApi"
  "SubscriptionManagementInitiateAmendQuantityDecrease"
  "SubscriptionManagementInitiateAmendQuantityIncrease"
  "SubscriptionManagementInitiateCancellationApi"
  "SubscriptionManagementInitiateRenewalApi"
  "SubscriptionManagementInvoiceErrorRecoveryApi"
  "SubscriptionManagementIssueStandaloneCreditApi"
  "SubscriptionManagementOrderToAssetApi"
  "SubscriptionManagementPaymentScheduleAutomation"
  "SubscriptionManagementPaymentsConfiguration"
  "SubscriptionManagementPaymentsRuntimeApi"
  "SubscriptionManagementPlaceOrderApi"
  "SubscriptionManagementProductAndPriceConfigurationApi"
  "SubscriptionManagementProductImportApi"
  "SubscriptionManagementQuotePricesTaxes"
  "SubscriptionManagementRefundAutomation"
  "SubscriptionManagementScheduledBatchInvoicingApi"
  "SubscriptionManagementScheduledBatchPaymentsApi"
  "SubscriptionManagementTaxConfiguration"
  "SubscriptionManagementUnapplyCreditToInvoiceApi"
  "SubscriptionManagementVoidPostedInvoiceApi"
)

declare -a smQuickStartPermissionSets=(
  "SM_Cancel_Asset"
  "SM_Community"
  "SM_Renew_Asset"
  "SM_Account_Tables"
  "SM_Asset_Tables"
  "SM_Cart_Items"
  "SM_Rev_Error_Log_Table"
)

declare -a smQuickStartPermissionSetsNoCommunity=(
  "SM_Cancel_Asset"
  "SM_Renew_Asset"
  "SM_Account_Tables"
  "SM_Asset_Tables"
  "SM_Rev_Error_Log_Table"
  "SM_Temp"
)

declare -a b2bCommercePermissionSets=(
  "CommerceAdmin"
)

declare -a smBasePermissionSets=(
  "SM_Base"
)

while [[ ! $acceptDisclaimer =~ 0|1 ]]; do
  prompt_to_accept_disclaimer
done

prompt_for_scratch_org

orgTypeStrMap=([0]="Production https://login.salesforce.com"
  [1]="Scratch https://test.salesforce.com"
  [2]="Sandbox https://test.salesforce.com"
  [3]="Falcon https://login.test1.pc-rnd.salesforce.com"
  [4]="Developer https://login.salesforce.com")

if [ ! "$orgType" == 1 ]; then
  while true; do
    prompt_for_org_type
    if [[ ${orgTypeStrMap[$orgType]+_} ]]; then
      orgTypeStr=${orgTypeStrMap[$orgType]}
      if [[ $orgType == 0 ]]; then
        check_qbranch
      elif [[ $orgType == 3 ]]; then
        while true; do
          prompt_for_falcon_instance
          if [[ $falconInstance =~ 0|1 ]]; then
            break
          fi
        done
      fi
      break
    else
      echo_color red "Invalid org type selected. Please try again."
    fi
  done
else
  orgTypeStr="Scratch"
fi
echo_color orange "You are deploying to a $orgTypeStr instance type - ${orgTypeStrMap[$orgType]}"

prompt_to_install_connector

if [ $includeCommerceConnector == true ]; then
  prompt_to_create_commerce_community
  if [ $createConnectorStore == true ]; then
    prompt_to_install_commerce_store
  fi
fi

set_sfdx_user_info
get_sfdx_user_info
update_org_api_version
replace_api_version

# TODO - update to change login.salesforce.com to test.salesforce.com for scratch and sandbox
# TODO - change connected app names to include at least the RC prefix
sed -e "s/<callbackUrl>https:\/\/login.salesforce.com\/services\/oauth2\/callback<\/callbackUrl>/<callbackUrl>https:\/\/login.salesforce.com\/services\/oauth2\/callback\nhttps:\/\/$SFDX_MYDOMAIN\/services\/oauth2\/callback<\/callbackUrl>/g" quickstart-config/Postman.connectedApp-meta-template.xml >postmannew.xml
sed -e "s/<callbackUrl>https:\/\/login.salesforce.com\/services\/oauth2\/callback<\/callbackUrl>/<callbackUrl>https:\/\/login.salesforce.com\/services\/oauth2\/callback\nhttps:\/\/$SFDX_MYDOMAIN\/services\/oauth2\/callback\nhttps:\/\/$SFDX_MYDOMAIN\/services\/authcallback\/SF<\/callbackUrl>/g" quickstart-config/Salesforce.connectedApp-meta-template.xml >salesforcenew.xml
sed -e "s/www.salesforce.com/$SFDX_MYDOMAIN/g" quickstart-config/$NAMED_CREDENTIAL_SM.namedCredential-meta-template.xml >$NAMED_CREDENTIAL_SM.xml
mv postmannew.xml $SM_CONNECTED_APPS_DIR/default/connectedApps/Postman.connectedApp-meta.xml
mv salesforcenew.xml $SM_CONNECTED_APPS_DIR/default/connectedApps/Salesforce.connectedApp-meta.xml
mv $NAMED_CREDENTIAL_SM.xml $SM_CONNECTED_APPS_DIR//default/namedCredentials/$NAMED_CREDENTIAL_SM.namedCredential-meta.xml

if [ $deployCode == true ]; then
  echo_color green "Setting Default Org Settings"
  deploy_org_settings || error_and_exit "Setting Org Settings Failed."
fi

echo_color green "Assigning Permission Sets & Permission Set Groups"
assign_permset_license "RevSubscriptionManagementPsl"
assign_all_permsets "${smPermissionSets[@]}"
if [ $includeCommerceConnector == true ]; then
  assign_permset_license "CommerceAdminUserPsl"
  assign_all_permsets "${b2bCommercePermissionSets[@]}"
fi

if [ $deployCode == true ]; then
  echo_color green "Pushing sm-base to the Org. This will take a few minutes..."
  deploy $BASE_DIR
fi

echo_color green "Assigning Base Permission Sets"
assign_all_permsets "${smBasePermissionSets[@]}"

# Activate Standard Pricebook
echo_color green "Activating Standard Pricebook"
pricebook1=$(sfdx data query -q "SELECT Id FROM Pricebook2 WHERE Name='$STANDARD_PRICEBOOK_NAME' AND IsStandard=true LIMIT 1" -r csv | tail -n +2)
echo_keypair pricebook1 "$pricebook1"
sleep 1
if [ -n "$pricebook1" ]; then
  sfdx data update record -s Pricebook2 -i "$pricebook1" -v "IsActive=true"
  sleep 1
else
  error_and_exit "Could not determine Standard Pricebook.  Exiting."
fi

apexClassId=$(get_record_id ApexClass Name $PAYMENT_GATEWAY_ADAPTER_NAME)
sleep 1

if [ -z "$apexClassId" ]; then
  error_and_exit "No Payment Gateway Adapter Class"
else
  # Creating Payment Gateway
  echo_color green "Getting Payment Gateway Provider $PAYMENT_GATEWAY_PROVIDER_NAME"
  paymentGatewayProviderId=$(get_record_id PaymentGatewayProvider DeveloperName $PAYMENT_GATEWAY_PROVIDER_NAME)
  echo_keypair paymentGatewayProviderId "$paymentGatewayProviderId"
  sleep 1
fi

if [ $createGateway == true ]; then
  echo_color green "Checking for existing $PAYMENT_GATEWAY_NAME PaymentGateway record"
  paymentGatewayId=$(sfdx data query -q "SELECT Id FROM PaymentGateway WHERE PaymentGatewayName='$PAYMENT_GATEWAY_NAME' AND PaymentGatewayProviderId='$paymentGatewayProviderId' LIMIT 1" -r csv | tail -n +2)
  if [ -z "$paymentGatewayId" ]; then
    echo_color green "Getting Named Credential $NAMED_CREDENTIAL_MASTER_LABEL"
    namedCredentialId=$(get_record_id NamedCredential MasterLabel $NAMED_CREDENTIAL_MASTER_LABEL)
    echo_keypair namedCredentialId "$namedCredentialId"
    echo_color green "Creating PaymentGateway record using MerchantCredentialId=$namedCredentialId, PaymentGatewayProviderId=$paymentGatewayProviderId."
    sfdx data create record -s PaymentGateway -v "MerchantCredentialId=$namedCredentialId PaymentGatewayName=$PAYMENT_GATEWAY_NAME PaymentGatewayProviderId=$paymentGatewayProviderId Status=Active"
    echo_color green "Getting PaymentGateway record Id"
    paymentGatewayId=$(sfdx data query -q "SELECT Id FROM PaymentGateway WHERE PaymentGatewayName='$PAYMENT_GATEWAY_NAME' AND PaymentGatewayProviderId='$paymentGatewayProviderId' LIMIT 1" -r csv | tail -n +2)
    sleep 1
  fi
  echo_keypair paymentGatewayId "$paymentGatewayId"
fi

if [ $createCommunity == true ]; then
  echo_color green "Checking for existing Subscription Management Customer Account Portal Digital Experience"
  storeId=$(get_record_id Network Name $COMMUNITY_NAME)
  if [ -z "$storeId" ]; then
    create_sm_community
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

# This is a quick fix for issue #3.  CDO/SDO/MFGIDO has Action Plan feature enabled.
# TODO - Refactor to check for specific features and include/exclude specific routes and views accordingly.
# TODO - Refactor into function
if [ $cdo -eq 1 ] && [ $rcido -eq 0 ]; then
  echo_color green "Copying CDO/SDO community components to ${COMMUNITY_NAME}1"
  cp -f quickstart-config/cdo/experiences/${COMMUNITY_NAME}1/routes/actionPlan* $COMMUNITY_TEMPLATE_DIR/default/experiences/${COMMUNITY_NAME}1/routes/.
  cp -f quickstart-config/cdo/experiences/${COMMUNITY_NAME}1/views/actionPlan* $COMMUNITY_TEMPLATE_DIR/default/experiences/${COMMUNITY_NAME}1/views/.
  if [ $includeConnectorStoreTemplate == true ]; then
    echo_color green "Copying CDO/SDO community components to ${B2B_STORE_NAME}1"
    cp -f quickstart-config/sm-b2b-connector/experiences/${B2B_STORE_NAME}1/routes/actionPlan* $COMMERCE_CONNECTOR_TEMPLATE_DIR/default/experiences/${B2B_STORE_NAME}1/routes/.
    cp -f quickstart-config/sm-b2b-connector/experiences/${B2B_STORE_NAME}1/views/actionPlan* $COMMERCE_CONNECTOR_TEMPLATE_DIR/default/experiences/${B2B_STORE_NAME}1/views/.
    cp -f quickstart-config/sm-b2b-connector/experiences/${B2B_STORE_NAME}1/routes/recommendation* $COMMERCE_CONNECTOR_TEMPLATE_DIR/default/experiences/${B2B_STORE_NAME}1/routes/.
    cp -f quickstart-config/sm-b2b-connector/experiences/${B2B_STORE_NAME}1/views/recommendation* $COMMERCE_CONNECTOR_TEMPLATE_DIR/default/experiences/${B2B_STORE_NAME}1/views/.
    rm -f $$COMMERCE_CONNECTOR_TEMPLATE_DIR/default/experiences/${B2B_STORE_NAME}1/views/newsDetail.json
    rm -f $$COMMERCE_CONNECTOR_TEMPLATE_DIR/default/experiences/${B2B_STORE_NAME}1/routes/newsDetail.json
  fi
fi

# fix for MFGIDO
# TODO - Refactor into function
if [ $mfgido -eq 1 ]; then
  echo_color green "Removing Self Register components from $B2B_STORE_NAME for MFGIDO"
  rm -rf $COMMERCE_CONNECTOR_TEMPLATE_DIR/default/aura/selfRegister*
  rm -rf $COMMERCE_CONNECTOR_TEMPLATE_DIR/default/lwc/selfLogin*
  rm -rf $COMMERCE_CONNECTOR_TEMPLATE_DIR/default/lwc/selfRegister*
  rm -rf $COMMERCE_CONNECTOR_TEMPLATE_DIR/default/permissionsets/Account_Switcher_User.permissionset-meta.xml
fi

# quick fix for developer/falcon
# TODO - Refactor into function
echo_keypair orgType "$orgType"
if [ "$orgType" == 4 ] || [ "$orgType" = 3 ] || [ $rcido -eq 1 ] || [[ "$orgType" = 0  &&  $cdo -eq 0 ]]; then
  rm -f $COMMUNITY_TEMPLATE_DIR/default/experiences/${COMMUNITY_NAME}1/views/articleDetail.json
  rm -f $COMMUNITY_TEMPLATE_DIR/default/experiences/${COMMUNITY_NAME}1/routes/articleDetail.json
  rm -f $COMMUNITY_TEMPLATE_DIR/default/experiences/${COMMUNITY_NAME}1/views/topArticles.json
  rm -f $COMMUNITY_TEMPLATE_DIR/default/experiences/${COMMUNITY_NAME}1/routes/topArticles.json
fi

# quick fix for falcon standard DOT
if [ "$orgType" == 3 ]; then
  rm -f $COMMERCE_CONNECTOR_TEMPLATE_DIR/default/experiences/${B2B_STORE_NAME}1/views/newsDetail.json
  rm -f $COMMERCE_CONNECTOR_TEMPLATE_DIR/default/experiences/${B2B_STORE_NAME}1/routes/newsDetail.json
fi

# replace Admin profile in sm-temp for rc-ico
if [ $rcido = 1 ]; then
  cp -f quickstart-config/rc-ico/profiles/Admin* $SM_TEMP_DIR/default/profiles/.
fi

if [ $includeCommerceConnector == true ] && [ $createConnectorStore == true ]; then
  echo_color green "Checking for existing B2B Store"
  b2bStoreId=$(get_record_id Network Name $B2B_STORE_NAME)
  if [ -z "$b2bStoreId" ]; then
    echo_color green "B2B Store not found, creating it"
    create_commerce_store
    while [ -z "${b2bStoreId}" ]; do
      echo_color green "Subscription Management/B2B Commerce Webstore not yet created, waiting 10 seconds..."
      b2bStoreId=$(get_record_id Network Name $B2B_STORE_NAME)
      sleep 10
    done
  else
    echo_color green "B2B Store found with id ${b2bStoreId}"
  fi

  echo_color cyan "Subscription Management/B2B Commerce Webstore found with id ${b2bStoreId}"
  echo_keypair b2bStoreId "$b2bStoreId"
  echo ""
fi

if [ $createTaxEngine == true ]; then
  create_tax_engine
fi

if [ $insertData == true ]; then
  insert_data
fi
echo_color green "Getting Default Account and Contact IDs"
defaultAccountId=$(get_record_id Account Name "$DEFAULT_ACCOUNT_NAME")

if [ -z "$defaultAccountId" ]; then
  echo_color red "Default Account not found, exiting"
  exit 1
fi
echo_color green "Default Customer Account ID: "
echo_keypair defaultAccountId "$defaultAccountId"

IFS=',' read -r -a defaultContactArray <<<"$(sfdx data query -q "SELECT Id, FirstName, LastName FROM Contact WHERE AccountId='$defaultAccountId' LIMIT 1" -r csv | sed '1d' && printf '\n')"
defaultContactId=${defaultContactArray[0]}
defaultContactFirstName=${defaultContactArray[1]}
defaultContactLastName=${defaultContactArray[2]}
if [ -z "$defaultContactId" ]; then
  echo_color red "Default Contact not found, exiting"
  exit 1
fi
echo_color green "Default Customer Contact ID: "
echo_keypair defaultContactId "$defaultContactId"
echo_color green "Default Customer Contact First Name: "
echo_keypair defaultContactFirstName "$defaultContactFirstName"
echo_color green "Default Customer Contact Last Name: "
echo_keypair defaultContactLastName "$defaultContactLastName"
# TODO: add check for exiting records before creating
sfdx data create record -s ContactPointAddress -v "AddressType='Shipping' ParentId='$defaultAccountId' ActiveFromDate='2020-01-01' ActiveToDate='2040-01-01' City='San Francisco' Country='United States' IsDefault='true' Name='Default Shipping' PostalCode='94105' State='California' Street='415 Mission Street'"
sfdx data create record -s ContactPointAddress -v "AddressType='Billing' ParentId='$defaultAccountId' ActiveFromDate='2020-01-01' ActiveToDate='2040-01-01' City='San Francisco' Country='United States' IsDefault='true' Name='Default Billing' PostalCode='94105' State='California' Street='415 Mission Street'"
if [ $includeCommerceConnector == true ]; then
  echo_color green "Making Account a Buyer Account."
  buyerAccountId=$(get_record_id BuyerAccount BuyerId "$defaultAccountId")
  echo_keypair buyerAccountId "$buyerAccountId"
  if [ -z "$buyerAccountId" ]; then
    echo_color green "Default Account not Buyer Account - Creating"
    sfdx data create record -s BuyerAccount -v "BuyerId='$defaultAccountId' Name='$DEFAULT_ACCOUNT_NAME Buyer Account' isActive=true"
    buyerAccountId=$(get_record_id BuyerAccount BuyerId "$defaultAccountId")
    echo_keypair buyerAccountId "$buyerAccountId"
  fi
  echo_color green "Assigning Buyer Account to Buyer Group."
  #TODO: add check for existing record before creating
  echo_color green "Getting Buyer Group ID"
  buyerGroupId=$(get_record_id BuyerGroup Name "$BUYER_GROUP_NAME")
  echo_keypair buyerGroupId "$buyerGroupId"
  if [ -z "$buyerGroupId" ]; then
    echo_color red "Buyer Group not found, exiting"
    exit 1
  fi
  sfdx data create record -s BuyerGroupMember -v "BuyerGroupId='$buyerGroupId' BuyerId='$defaultAccountId'"
fi

if [ $deployCode == true ]; then
  if [ "$orgType" == 5 ]; then
    if [ $includeCommerceConnector == true ]; then
      populate_b2b_connector_custom_metadata
    fi
    echo_color green "Pushing all project source to the scratch org.  This will take a few minutes..."
    sf deploy metadata -g -c -a "$API_VERSION"
  else
    echo_color green "Pushing sm-asset-management to the org. This will take a few minutes..."
    deploy $ASSET_MANAGEMENT_DIR

    echo_color green "Pushing sm-utility-tables to the org. This will take a few minutes..."
    deploy $UTIL_DIR

    echo_color green "Pushing sm-cancel-asset to the org. This will take a few minutes..."
    deploy $CANCEL_DIR

    echo_color green "Pushing sm-refund-credit to the org. This will take a few minutes..."
    deploy $REFUND_DIR

    echo_color green "Pushing sm-renewals to the org. This will take a few minutes..."
    deploy $RENEW_DIR

    if [ $includeCommunity == true ]; then
      echo_color green "Pushing sm-my-community to the org. This will take a few minutes..."
      deploy $COMMUNITY_DIR
    fi

    if [ $includeCommunity == true ]; then
      echo_color green "Pushing sm-community-template to the org. This will take a few minutes..."
      deploy $COMMUNITY_TEMPLATE_DIR
    fi

    if [ $includeCommerceConnector == true ]; then
      populate_b2b_connector_custom_metadata
      echo_color green "Pushing sm-b2b-connector to the org. This will take a few minutes..."
      deploy $COMMERCE_CONNECTOR_DIR
      echo_color green "Pushing sm-b2b-connector-temp to the org. This will take a few minutes..."
      deploy $COMMERCE_CONNECTOR_TEMP_DIR
      if [ $includeConnectorStoreTemplate == true ] && [ "$b2b_aura_template" == 1 ]; then
        echo_color green "Pushing sm-b2b-connector-community-template to the org. This will take a few minutes..."
        deploy $COMMERCE_CONNECTOR_TEMPLATE_DIR
      elif [ $includeConnectorStoreTemplate == true ] && [ "$b2b_aura_template" == 0 ]; then
        echo_color rose "Skipping sm-b2b-connector-community-template deployment.  This is currently only supported for Aura based templates."
      fi
    fi

    echo_color green "Pushing sm-temp to the org. This will take a few minutes..."
    deploy $SM_TEMP_DIR

    if [ $deployConnectedApps == true ]; then
      echo_color green "Pushing sm-connected-apps to the org. This will take a few minutes..."
      deploy $SM_CONNECTED_APPS_DIR
    else
      echo_color green "Connected Apps are not being deployed.  They must be deployed later or created manually."
    fi
  fi
fi

echo_color green "Assigning SM QuickStart Permsets"
if [ $includeCommunity == true ]; then
  assign_all_permsets "${smQuickStartPermissionSets[@]}"
else
  assign_all_permsets "${smQuickStartPermissionSetsNoCommunity[@]}"
fi

if [ ! "$orgType" == 3 ] && [ $installPackages == true ]; then
  echo_color green "Installing Managed Packages"
  echo_color cyan "Installing Streaming API Monitor"
  #TODO: add check for existing package
  install_package $STREAMING_API_MONITOR_PACKAGE
fi

if [ $rcido -eq 1 ] && [ $installPackages == true ]; then
  echo_color green "Installing CPQ/SM Connector Package"
  install_package $CPQSM_PACKAGE
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
