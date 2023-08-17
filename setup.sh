#!/bin/bash
# shellcheck shell=bash

#set -euo pipefail

. ./scripts/constants.sh
. ./scripts/functions.sh

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
export refreshSmartbytes=false

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
  "SM_Tax"
)

declare -a smQuickStartPermissionSetsNoCommunity=(
  "SM_Cancel_Asset"
  "SM_Renew_Asset"
  "SM_Account_Tables"
  "SM_Asset_Tables"
  "SM_Rev_Error_Log_Table"
  "SM_Temp"
  "SM_Tax"
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
        if $rcido || $refreshSmartbytes; then
          prepare_refresh_smartbytes
        fi
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
echo
echo_color orange "You are deploying to a $orgTypeStr instance type - ${orgTypeStrMap[$orgType]}"
echo

if ! $rcido; then
  add_line_to_forceignore "$RCIDO_DIR"
fi

prompt_to_install_connector

if $includeCommerceConnector; then
  prompt_to_create_commerce_community
  if $createConnectorStore; then
    prompt_to_install_commerce_store
  fi
fi

set_sfdx_user_info
get_sfdx_user_info
update_org_api_version
replace_api_version
convert_files

if $deployCode; then
  echo_color green "Setting Default Org Settings"
  deploy_org_settings || error_and_exit "Setting Org Settings Failed."
fi

echo_color green "Assigning Permission Sets & Permission Set Groups"
assign_permset_license "RevSubscriptionManagementPsl"
echo_color green "Assinging Managed Subscription Management Permission Sets Groups"
assign_all_permsets "${smPermissionSetGroups[@]}"
echo_color green "Assinging Managed Subscription Management Permission Sets"
assign_all_permsets "${smPermissionSets[@]}"
if $includeCommerceConnector; then
  assign_permset_license "CommerceAdminUserPsl"
  assign_all_permsets "${b2bCommercePermissionSets[@]}"
fi

if $deployCode; then
  echo_color green "Pushing sm-base to the Org. This will take a few minutes..."
  deploy $BASE_DIR
fi

echo_color green "Assigning Base Permission Sets"
assign_all_permsets "${smBasePermissionSets[@]}"

# Activate Standard Pricebook
echo_color green "Activating Standard Pricebook"
pricebook1=$(get_standard_pricebook_id)
echo_keypair pricebook1 "$pricebook1"
if [ -n "$pricebook1" ]; then
  $sfdx data update record -s Pricebook2 -i "$pricebook1" -v "IsActive=true"
else
  error_and_exit "Could not determine Standard Pricebook.  Exiting."
fi

apexClassId=$(get_record_id ApexClass Name "$PAYMENT_GATEWAY_ADAPTER_NAME")

if [ -z "$apexClassId" ]; then
  error_and_exit "No Payment Gateway Adapter Class"
else
  # Creating Payment Gateway
  echo_color green "Getting Payment Gateway Provider $PAYMENT_GATEWAY_PROVIDER_NAME"
  paymentGatewayProviderId=$(get_record_id PaymentGatewayProvider DeveloperName "$PAYMENT_GATEWAY_PROVIDER_NAME")
  echo_keypair paymentGatewayProviderId "$paymentGatewayProviderId"
fi

if $createGateway; then
  echo_color green "Checking for existing $PAYMENT_GATEWAY_NAME PaymentGateway record"
  paymentGatewayId=$(get_payment_gateway_id "$paymentGatewayProviderId")
  if [ -z "$paymentGatewayId" ] || [ -x "$paymentGatewayProviderId" ]; then
    create_mock_payment_gateway "$paymentGatewayProviderId"
    if [ -z "$paymentGatewayId" ]; then
      echo_color red "Error: Failed to obtain PaymentGateway record"
      exit 1
    fi
  fi
  echo_keypair paymentGatewayId "$paymentGatewayId"
fi

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

prepare_experiences_directory

# replace Admin profile in sm-temp for rc-ico
if $rcido; then
  cp -f quickstart-config/rc-ido/profiles/Admin.profile-meta.xml $SM_TEMP_DIR/default/profiles/.
fi

if $includeCommerceConnector && $createConnectorStore; then
  echo_color green "Checking for existing B2B Store"
  b2bStoreId=$(get_record_id Network Name "$B2B_STORE_NAME")
  if [ -z "$b2bStoreId" ]; then
    echo_color green "B2B Store not found, creating it"
    create_commerce_store
    while [ -z "${b2bStoreId}" ]; do
      echo_color green "Subscription Management/B2B Commerce Webstore not yet created, waiting 10 seconds..."
      b2bStoreId=$(get_record_id Network Name "$B2B_STORE_NAME")
      sleep 10
    done
  else
    echo_color green "B2B Store found with id ${b2bStoreId}"
  fi

  echo_color cyan "Subscription Management/B2B Commerce Webstore found with id ${b2bStoreId}"
  echo_keypair b2bStoreId "$b2bStoreId"
  echo ""
fi

if $createTaxEngine; then
  deploy "$SM_TAX_DIR"
  create_tax_engine "mock"
fi

if $insertData && ! $refreshSmartbytes; then
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
q="SELECT Id, FirstName, LastName FROM Contact WHERE AccountId='$defaultAccountId' LIMIT 1"
IFS=',' read -r -a defaultContactArray <<<"$($sfdx data query -q "$q" -r csv | sed '1d' && printf '\n')"
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

# Create Buyer Account, Buyer Group and Buyer Group Member
if $includeCommerceConnector; then
  echo_color green "Checking for existing Default ContactPointAddress records"
  defaultShippingAddressId=$($sfdx data query -q "SELECT Id FROM ContactPointAddress WHERE ParentId='$defaultAccountId' AND AddressType='Shipping' AND IsDefault=true LIMIT 1" -r csv | tail -n +2)
  defaultBillingAddressId=$($sfdx data query -q "SELECT Id FROM ContactPointAddress WHERE ParentId='$defaultAccountId' AND AddressType='Billing' AND IsDefault=true LIMIT 1" -r csv | tail -n +2)
  if [ -z "$defaultShippingAddressId" ]; then
    echo_color green "Default Shipping Address not found, creating it"
    $sfdx data create record -s ContactPointAddress -v "AddressType='Shipping' ParentId='$defaultAccountId' ActiveFromDate='2020-01-01' ActiveToDate='2040-01-01' City='San Francisco' Country='United States' IsDefault='true' Name='Default Shipping' PostalCode='94105' State='California' Street='415 Mission Street'"
    sleep 1
  fi
  if [ -z "$defaultBillingAddressId" ]; then
    echo_color green "Default Billing Address not found, creating it"
    $sfdx data create record -s ContactPointAddress -v "AddressType='Billing' ParentId='$defaultAccountId' ActiveFromDate='2020-01-01' ActiveToDate='2040-01-01' City='San Francisco' Country='United States' IsDefault='true' Name='Default Billing' PostalCode='94105' State='California' Street='415 Mission Street'"
    sleep 1
  fi
  echo_color green "Making Account a Buyer Account."
  buyerAccountId=$(get_record_id BuyerAccount BuyerId "$defaultAccountId")
  echo_keypair buyerAccountId "$buyerAccountId"
  if [ -z "$buyerAccountId" ]; then
    echo_color green "Default Account not Buyer Account - Creating"
    $sfdx data create record -s BuyerAccount -v "BuyerId='$defaultAccountId' Name='$DEFAULT_ACCOUNT_NAME Buyer Account' isActive=true"
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
  echo_color green "Checking for existing Buyer Group Member ID"
  buyerGroupMemberId=$(get_record_id BuyerGroupMember BuyerGroupId "$buyerGroupId" BuyerId "$defaultAccountId")
  echo_keypair buyerGroupMemberId "$buyerGroupMemberId"
  if [ -z "$buyerGroupMemberId" ]; then
    echo_color green "Buyer Group Member not found, creating it"
    $sfdx data create record -s BuyerGroupMember -v "BuyerGroupId='$buyerGroupId' BuyerId='$defaultAccountId'"
  fi
fi

# deploy code
if $deployCode; then
  if [ "$orgType" == 5 ]; then
    if $includeCommerceConnector; then
      populate_b2b_connector_custom_metadata
    fi
    echo_color green "Pushing all project source to the scratch org.  This will take a few minutes..."
    $sfdx deploy metadata -g -c -a "$API_VERSION"
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

    if $includeCommunity; then
      echo_color green "Pushing sm-my-community to the org. This will take a few minutes..."
      deploy $COMMUNITY_DIR
    fi

    #if $includeCommunity && ! $refreshSmartbytes; then
    if $includeCommunity; then
      echo_color green "Pushing sm-community-template to the org. This will take a few minutes..."
      deploy $COMMUNITY_TEMPLATE_DIR
    fi

    if $includeCommerceConnector; then
      populate_b2b_connector_custom_metadata
      echo_color green "Pushing sm-b2b-connector to the org. This will take a few minutes..."
      deploy $COMMERCE_CONNECTOR_DIR
      echo_color green "Pushing sm-b2b-connector-temp to the org. This will take a few minutes..."
      deploy $COMMERCE_CONNECTOR_TEMP_DIR
      if [ -z "$b2b_aura_template" ]; then
        echo_color green "checking for b2b-aura-template..."
        check_b2b_aura_template
      fi
      if $includeConnectorStoreTemplate && [ "$b2b_aura_template" == 1 ] && ! $refreshSmartbytes; then
        echo_color green "Pushing sm-b2b-connector-community-template to the org. This will take a few minutes..."
        deploy $COMMERCE_CONNECTOR_TEMPLATE_DIR
      elif $includeConnectorStoreTemplate && [ "$b2b_aura_template" == 0 ]; then
        echo_color rose "Skipping sm-b2b-connector-community-template deployment.  This is currently only supported for Aura based templates."
      else
        echo_color rose "Skipping sm-b2b-connector-community-template deployment due to variable settings:"
        echo_keypair includeCommerceConnector "$includeCommerceConnector"
        echo_keypair includeConnectorStoreTemplate "$includeConnectorStoreTemplate"
        echo_keypair b2b_aura_template "$b2b_aura_template"
        echo_keypair refreshSmartbytes "$refreshSmartbytes"
      fi
    fi

    echo_color green "Pushing sm-temp to the org. This will take a few minutes..."
    deploy $SM_TEMP_DIR

    if $deployConnectedApps; then
      echo_color green "Pushing sm-connected-apps to the org. This will take a few minutes..."
      deploy $SM_CONNECTED_APPS_DIR
    else
      echo_color green "Connected Apps are not being deployed.  They must be deployed later or created manually."
    fi

    if $includeCommerceConnector && $deployConnectedApps; then
      echo_color green "Extracting consumer key from connected app and replacing in custom metadata"
      populate_b2b_connector_custom_metadata_consumer_key
      #deploy $B2B_CUSTOM_METADATA_CONSUMER_KEY
      deploy $B2B_CONNECTED_APP
    fi
  fi
fi

echo_color green "Assigning SM QuickStart Permsets"
if $includeCommunity; then
  assign_all_permsets "${smQuickStartPermissionSets[@]}"
else
  assign_all_permsets "${smQuickStartPermissionSetsNoCommunity[@]}"
fi

if [ ! "$orgType" == 3 ] && $installPackages && ! $refreshSmartbytes; then
  echo_color green "Installing Managed Packages"
  echo_color cyan "Installing Streaming API Monitor"
  check_package "smon"
  if ! $smon; then
    install_package $STREAMING_API_MONITOR_PACKAGE
  fi
fi

#TODO - test to see if a reinstall purges existing configuration
if $rcido && $installPackages && ! $refreshSmartbytes; then
  echo_color green "Installing CPQ/SM Connector Package"
  check_package "CPQSM"
  if ! $cpqsm; then
    if ! $sbqq; then
      check_package "sbqq"
      if $sbqq; then
        install_package $CPQSM_PACKAGE
      fi
    fi
  fi
fi

if $includeCommunity; then
  $sfdx community publish -n "$COMMUNITY_NAME"
fi

if $includeCommerceConnector; then
  if [ -n "$commerceStoreId" ] && $registerCommerceServices && ! $refreshSmartbytes; then
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

case $(uname -s | tr '[:upper:]' '[:lower:]') in
msys)
  open_org setup
  ;;
*)
  open_org setup chrome
  ;;
esac
