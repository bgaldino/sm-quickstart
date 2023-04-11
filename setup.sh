#!/bin/sh
source ./scripts/constants.sh
source ./scripts/functions.sh
export SFDX_NPM_REGISTRY="http://platform-cli-registry.eng.sfdc.net:4880/"
export SFDX_S3_HOST="http://platform-cli-s3.eng.sfdc.net:9000/sfdx/media/salesforce-cli"

# change to 0 for items that should be skipped - the script will soon start to get/set these values as part of an error handling process
insertData=1
deployCode=1
createGateway=1
createTaxEngine=1
createCommunity=1
installPackages=1
includeCommunity=1
includeCommerceConnector=1
createConnectorStore=1
includeConnectorStoreTemplate=1
registerCommerceServices=1
createStripeGateway=1
deployConnectedApps=0

# runtime variables
cdo=0
sdo=0
xdo=0
rcido=0
mfgido=0
sbqq=0
blng=0
b2bvp=0
cpqsm=0

declare -a smPermissionSetGroups=(
  "SubscriptionManagementBillingAdmin"
  "SubscriptionManagementBillingOperations"
  "SubscriptionManagementBuyerIntegrationUser"
  "SubscriptionManagementCollections"
  "SubscriptionManagementCreditMemoAdjustmentsOperations"
  "SubscriptionManagementPaymentAdministrator"
  "SubscriptionManagementPaymentOperations"
  "SubscriptionManagementProductAndPricingAdmin"
  "SubscriptionManagementSalesOperationsRep"
  "SubscriptionManagementTaxAdmin"
)

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

local_sfdx=$(sfdx_version)

while [[ ! $acceptDisclaimer =~ 0|1 ]]; do
  prompt_to_accept_disclaimer
done

while [[ ! $createScratch =~ 0|1 ]]; do
  prompt_to_create_scratch
done

if [ $createScratch -eq 1 ]; then
  while [[ ! $scratchEdition =~ 0|1|2 ]]; do
    prompt_for_scratch_edition
  done
  while [[ -z "$scratchAlias" ]]; do
    prompt_for_scratch_alias
  done
  if [ -n "$scratchEdition" ] && [ -n "$scratchAlias" ]; then
    case $scratchEdition in
    0)
      type="Developer"
      ;;
    1)
      type="Enterprise"
      ;;
    2)
      type="Enterprise with Rebates"
      ;;
    esac
    echo_color green "Creating $type scratch org with alias $scratchAlias"
    create_scratch_org $scratchAlias
  else
    error_and_exit "Cannot create scratch org - exiting"
  fi
fi

while [[ ! $orgType =~ 0|1|2|3|4 ]]; do
  prompt_for_org_type
done

case $orgType in
0)
  orgTypeStr="Production"
  echo_color orange "You are deploying to a production/developer instance type - https://login.salesforce.com"
  check_qbranch
  ;;
1)
  orgTypeStr="Scratch"
  echo_color orange "You are deploying to a Scratch org - https://test.salesforce.com"
  ;;
2)
  orgTypeStr="Sandbox"
  echo_color orange "You are deploying to a Sandbox org type - https://test.salesforce.com"
  ;;
3)
  orgTypeStr="Falcon"
  echo_color orange "You are requesting deployment to a falcon instance - https://login.test1.pc-rnd.salesforce.com"
  while [[ ! $falconInstance =~ 0|1 ]]; do
    prompt_for_falcon_instance
  done
  ;;
4)
  orgTypeStr="Developer"
  echo_color orange "You are deploying to a Developer org type - https://login.salesforce.com"
  ;;
esac

prompt_to_install_connector

if [ $includeCommerceConnector -eq 1 ]; then
  prompt_to_create_commerce_community
  if [ $createConnectorStore -eq 1 ]; then
    prompt_to_install_commerce_store
  fi
fi

set_sfdx_user_info
get_sfdx_user_info

sed -e "s/<callbackUrl>https:\/\/login.salesforce.com\/services\/oauth2\/callback<\/callbackUrl>/<callbackUrl>https:\/\/login.salesforce.com\/services\/oauth2\/callback\nhttps:\/\/$SFDX_MYDOMAIN\/services\/oauth2\/callback<\/callbackUrl>/g" quickstart-config/Postman.connectedApp-meta-template.xml >postmannew.xml
sed -e "s/<callbackUrl>https:\/\/login.salesforce.com\/services\/oauth2\/callback<\/callbackUrl>/<callbackUrl>https:\/\/login.salesforce.com\/services\/oauth2\/callback\nhttps:\/\/$SFDX_MYDOMAIN\/services\/oauth2\/callback\nhttps:\/\/$SFDX_MYDOMAIN\/services\/authcallback\/SF<\/callbackUrl>/g" quickstart-config/Salesforce.connectedApp-meta-template.xml >salesforcenew.xml
sed -e "s/www.salesforce.com/$SFDX_MYDOMAIN/g" quickstart-config/$NAMED_CREDENTIAL_SM.namedCredential-meta-template.xml >$NAMED_CREDENTIAL_SM.xml
mv postmannew.xml $SM_CONNECTED_APPS_DIR/default/connectedApps/Postman.connectedApp-meta.xml
mv salesforcenew.xml $SM_CONNECTED_APPS_DIR/default/connectedApps/Salesforce.connectedApp-meta.xml
mv $NAMED_CREDENTIAL_SM.xml $SM_TEMP_DIR/default/namedCredentials/$NAMED_CREDENTIAL_SM.namedCredential-meta.xml

if [ $deployCode -eq 1 ]; then
  echo_color green "Setting Default Org Settings"
  deploy_org_settings || error_and_exit "Setting Org Settings Failed."
fi

echo_color green "Assigning Permission Sets & Permission Set Groups"
assign_permset_license "RevSubscriptionManagementPsl"
assign_all_permsets "${smPermissionSets[@]}"
if [ $includeCommerceConnector -eq 1 ]; then
  assign_permset_license "CommerceAdminUserPsl"
  assign_all_permsets "${b2bCommercePermissionSets[@]}"
fi

if [ $deployCode -eq 1 ]; then
  echo_color green "Pushing sm-base to the Org. This will take a few minutes..."
  deploy $BASE_DIR
fi

echo_color green "Assigning Base Permission Sets"
assign_all_permsets "${smBasePermissionSets[@]}"

# Activate Standard Pricebook
echo_color green "Activating Standard Pricebook"
pricebook1=$(sfdx data query -q "SELECT Id FROM Pricebook2 WHERE Name='$STANDARD_PRICEBOOK_NAME' AND IsStandard=true LIMIT 1" -r csv | tail -n +2)
echo_keypair pricebook1 $pricebook1
sleep 1
if [ -n "$pricebook1" ]; then
  sfdx data update record -s Pricebook2 -i $pricebook1 -v "IsActive=true"
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
  echo_keypair paymentGatewayProviderId $paymentGatewayProviderId
  sleep 1
fi

if [ $createGateway -eq 1 ]; then
  echo_color green "Checking for existing $PAYMENT_GATEWAY_NAME PaymentGateway record"
  paymentGatewayId=$(sfdx data query -q "SELECT Id FROM PaymentGateway WHERE PaymentGatewayName='$PAYMENT_GATEWAY_NAME' AND PaymentGatewayProviderId='$paymentGatewayProviderId' LIMIT 1" -r csv | tail -n +2)
  if [ -z "$paymentGatewayId" ]; then
    echo_color green "Getting Named Credential $NAMED_CREDENTIAL_MASTER_LABEL"
    namedCredentialId=$(get_record_id NamedCredential MasterLabel $NAMED_CREDENTIAL_MASTER_LABEL)
    echo_keypair namedCredentialId $namedCredentialId
    echo_color green "Creating PaymentGateway record using MerchantCredentialId=$namedCredentialId, PaymentGatewayProviderId=$paymentGatewayProviderId."
    sfdx data create record -s PaymentGateway -v "MerchantCredentialId=$namedCredentialId PaymentGatewayName=$PAYMENT_GATEWAY_NAME PaymentGatewayProviderId=$paymentGatewayProviderId Status=Active"
    echo_color green "Getting PaymentGateway record Id"
    paymentGatewayId=$(sfdx data query -q "SELECT Id FROM PaymentGateway WHERE PaymentGatewayName='$PAYMENT_GATEWAY_NAME' AND PaymentGatewayProviderId='$paymentGatewayProviderId' LIMIT 1" -r csv | tail -n +2)
    sleep 1
  fi
  echo_keypair paymentGatewayId $paymentGatewayId
fi

if [ $createCommunity -eq 1 ]; then
  echo_color green "Checking for existing Subscription Management Customer Account Portal Digital Experience"
  storeId=$(get_record_id Network Name $COMMUNITY_NAME)
  if [ -z "$storeId" ]; then
    echo_color green "Creating Subscription Management Customer Account Portal Digital Experience"
    sfdx community create -n "$COMMUNITY_NAME" -t "Customer Account Portal" -p "$COMMUNITY_NAME" -d "Customer Portal created by Subscription Management Quickstart"
  else
    echo_color green "Subscription Management Customer Account Portal Digital Experience already exists"
  fi
fi

if [ $includeCommunity -eq 1 ]; then
  while [ -z "${storeId}" ]; do
    echo_color green "Subscription Management Customer Community not yet created, waiting 10 seconds..."
    storeId=$(get_record_id Network Name $COMMUNITY_NAME)
    sleep 10
  done

  echo_color cyan "Subscription Management Customer Community found with id ${storeId}"
  echo_keypair storeId $storeId
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
  echo_keypair ceoRoleId $ceoRoleId
  sleep 1

  sfdx data update record -s User -v "UserRoleId='$ceoRoleId' Country='United States'" -w "Username='$SFDX_USERNAME'"
  sleep 1
fi

if [ -z "$pricebook1" ]; then
  pricebook1=$(sfdx data query -q "SELECT Id FROM Pricebook2 WHERE Name='$STANDARD_PRICEBOOK_NAME' AND IsStandard=true LIMIT 1" -r csv | tail -n +2)
  echo_keypair pricebook1 $pricebook1
  sleep 1
fi

if [ -z "$paymentGatewayId" ]; then
  paymentGatewayId=$(sfdx data query -q "SELECT Id FROM PaymentGateway WHERE PaymentGatewayName='$PAYMENT_GATEWAY_NAME' AND PaymentGatewayProviderId='$paymentGatewayProviderId' LIMIT 1" -r csv | tail -n +2)
  echo_keypair paymentGatewayId $paymentGatewayId
  sleep 1
fi

if [ -n "$pricebook1" ] && [ -n "$paymentGatewayId" ]; then
  tmpfile=$(mktemp)
  sed -e "s/INSERT_GATEWAY/$paymentGatewayId/g;s/INSERT_PRICEBOOK/$pricebook1/g" quickstart-config/home.json >$tmpfile
  mv -f $tmpfile $COMMUNITY_TEMPLATE_DIR/default/experiences/${COMMUNITY_NAME}1/views/home.json
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
  if [ $includeConnectorStoreTemplate -eq 1 ]; then
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
if [ $orgType -eq 4 ] || [ $orgType -eq 3 ] || [ $rcido -eq 1 ]; then
  rm -f $COMMUNITY_TEMPLATE_DIR/default/experiences/${COMMUNITY_NAME}1/views/articleDetail.json
  rm -f $COMMUNITY_TEMPLATE_DIR/default/experiences/${COMMUNITY_NAME}1/routes/articleDetail.json
  rm -f $COMMUNITY_TEMPLATE_DIR/default/experiences/${COMMUNITY_NAME}1/views/topArticles.json
  rm -f $COMMUNITY_TEMPLATE_DIR/default/experiences/${COMMUNITY_NAME}1/routes/topArticles.json
fi

# quick fix for falcon standard DOT
if [ $orgType -eq 3 ]; then
  rm -f $COMMERCE_CONNECTOR_TEMPLATE_DIR/default/experiences/${B2B_STORE_NAME}1/views/newsDetail.json
  rm -f $COMMERCE_CONNECTOR_TEMPLATE_DIR/default/experiences/${B2B_STORE_NAME}1/routes/newsDetail.json
fi

if [ $includeCommerceConnector -eq 1 ] && [ $createConnectorStore -eq 1 ]; then
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
  echo_keypair b2bStoreId $b2bStoreId
  echo ""
fi

if [ $createTaxEngine -eq 1 ]; then
  create_tax_engine
fi

if [ $insertData -eq 1 ]; then
  insert_data
fi
echo_color green "Getting Default Account and Contact IDs"
#defaultAccountId=$(get_record_id Account Name $DEFAULT_ACCOUNT_NAME)
defaultAccountId=$(sfdx data query -q "SELECT Id FROM Account WHERE Name='$DEFAULT_ACCOUNT_NAME' LIMIT 1" -r csv | tail -n +2)

if [ -z "$defaultAccountId" ]; then
  echo_color red "Default Account not found, exiting"
  exit 1
fi
echo_color green "Default Customer Account ID: "
echo_keypair defaultAccountId $defaultAccountId

defaultContact=$(sfdx data query -q "SELECT Id, FirstName, LastName FROM Contact WHERE AccountId='$defaultAccountId' LIMIT 1" -r csv | tail -n +2)
defaultContactArray=($(echo $defaultContact | tr "," "\n"))
defaultContactId=${defaultContactArray[0]}
defaultContactFirstName=${defaultContactArray[1]}
defaultContactLastName=${defaultContactArray[2]}
if [ -z "$defaultContactId" ]; then
  echo_color red "Default Contact not found, exiting"
  exit 1
fi
echo_color green "Default Customer Contact ID: "
echo_keypair defaultContactId $defaultContactId
echo_color green "Default Customer Contact First Name: "
echo_keypair defaultContactFirstName $defaultContactFirstName
echo_color green "Default Customer Contact Last Name: "
echo_keypair defaultContactLastName $defaultContactLastName
# TODO: add check for exiting records before creating
sfdx data create record -s ContactPointAddress -v "AddressType='Shipping' ParentId='$defaultAccountId' ActiveFromDate='2020-01-01' ActiveToDate='2040-01-01' City='San Francisco' Country='United States' IsDefault='true' Name='Default Shipping' PostalCode='94105' State='California' Street='415 Mission Street'"
sfdx data create record -s ContactPointAddress -v "AddressType='Billing' ParentId='$defaultAccountId' ActiveFromDate='2020-01-01' ActiveToDate='2040-01-01' City='San Francisco' Country='United States' IsDefault='true' Name='Default Billing' PostalCode='94105' State='California' Street='415 Mission Street'"
if [ $includeCommerceConnector -eq 1 ]; then
  echo_color green "Making Account a Buyer Account."
  buyerAccountId=$(get_record_id BuyerAccount BuyerId $defaultAccountId)
  echo_keypair buyerAccountId $buyerAccountId
  if [ -z $buyerAccountId ]; then
    echo_color green "Default Account not Buyer Account - Creating"
    sfdx data create record -s BuyerAccount -v "BuyerId='$defaultAccountId' Name='$DEFAULT_ACCOUNT_NAME Buyer Account' isActive=true"
    buyerAccountId=$(get_record_id BuyerAccount BuyerId $defaultAccountId)
    echo_keypair buyerAccountId $buyerAccountId
  fi
  echo_color green "Assigning Buyer Account to Buyer Group."
  #TODO: add check for existing record before creating
  echo_color green "Getting Buyer Group ID"
  buyerGroupId=$(sfdx data query --query \ "SELECT Id FROM BuyerGroup WHERE Name = '${BUYER_GROUP_NAME}'" -r csv | tail -n +2)
  #buyerGroupId=$(get_record_id BuyerGroup Name $BUYER_GROUP_NAME)
  echo_keypair buyerGroupId $buyerGroupId
  if [ -z $buyerGroupId ]; then
    echo_color red "Buyer Group not found, exiting"
    exit 1
  fi
  sfdx data create record -s BuyerGroupMember -v "BuyerGroupId='$buyerGroupId' BuyerId='$defaultAccountId'"
fi

if [ $deployCode -eq 1 ]; then
  if [ $orgType -eq 5 ]; then
    if [ $includeCommerceConnector -eq 1 ]; then
      populate_b2b_connector_custom_metadata
    fi
    echo_color green "Pushing all project source to the scratch org.  This will take a few minutes..."
    sf deploy metadata -g -c -a $API_VERSION
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

    if [ $includeCommunity -eq 1 ]; then
      echo_color green "Pushing sm-my-community to the org. This will take a few minutes..."
      deploy $COMMUNITY_DIR
    fi

    if [ $includeCommunity -eq 1 ]; then
      echo_color green "Pushing sm-community-template to the org. This will take a few minutes..."
      deploy $COMMUNITY_TEMPLATE_DIR
    fi

    if [ $includeCommerceConnector -eq 1 ]; then
      populate_b2b_connector_custom_metadata
      echo_color green "Pushing sm-b2b-connector to the org. This will take a few minutes..."
      deploy $COMMERCE_CONNECTOR_DIR
      echo_color green "Pushing sm-b2b-connector-temp to the org. This will take a few minutes..."
      deploy $COMMERCE_CONNECTOR_TEMP_DIR
      if [ $includeConnectorStoreTemplate -eq 1 ]; then
        echo_color green "Pushing sm-b2b-connector-community-template to the org. This will take a few minutes..."
        deploy $COMMERCE_CONNECTOR_TEMPLATE_DIR
      fi
    fi

    echo_color green "Pushing sm-temp to the org. This will take a few minutes..."
    deploy $SM_TEMP_DIR

    if [ $deployConnectedApps -eq 1 ]; then
      echo_color green "Pushing sm-connected-apps to the org. This will take a few minutes..."
      deploy $SM_CONNECTED_APPS_DIR
    else
      echo_color green "Connected Apps are not being deployed.  They must be deployed later or created manually."
    fi
  fi
fi

echo_color green "Assigning SM QuickStart Permsets"
if [ $includeCommunity -eq 1 ]; then
  assign_all_permsets "${smQuickStartPermissionSets[@]}"
else
  assign_all_permsets "${smQuickStartPermissionSetsNoCommunity[@]}"
fi

if [ $orgType -ne 3 ] && [ $installPackages -eq 1 ]; then
  echo_color green "Installing Managed Packages"
  echo_color cyan "Installing Streaming API Monitor"
  #TODO: add check for existing package
  install_package $STREAMING_API_MONITOR_PACKAGE
fi

if [ $rcido -eq 1 ] && [ $installPackages -eq 1 ]; then
  echo_color green "Installing CPQ/SM Connector Package"
  install_package $CPQSM_PACKAGE
fi

if [ $includeCommunity -eq 1 ]; then
  sfdx community publish -n "$COMMUNITY_NAME"
fi

if [ $includeCommerceConnector -eq 1 ]; then
  if [ -n $commerceStoreId ] && [ $registerCommerceServices -eq 1 ]; then
    register_commerce_services
  fi
  echo_color green "Publishing B2B Connector Store $B2B_STORE_NAME"
  sfdx community publish -n "$B2B_STORE_NAME"
  echo_color green "Building Search Index for B2B Connector Store $B2B_STORE_NAME"
  sfdx commerce search start -n "$B2B_STORE_NAME"
fi

echo_color green "All operations completed - opening configured org in google chrome"
sfdx org open -p /lightning/setup/SetupOneHome/home --browser chrome
