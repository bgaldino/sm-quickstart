#!/bin/sh
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

# api version to run sfdx commands
apiversion="56.0"

# module directories
defaultDir="sm"

# base metadata for all other modules
baseDir="$defaultDir/sm-base/main"

# forked from https://github.com/SalesforceLabs/RevenueCloudCodeSamples
assetManagementDir="$defaultDir/sm-asset-management/main"

# forked from https://github.com/samcheck/sm-my-community
communityDir="$defaultDir/sm-my-community/main"

# forked from https://github.com/samcheck/sm-utility-tables
utilDir="$defaultDir/sm-utility-tables/main"

# forked from https://github.com/samcheck/sm-cancel-asset
cancelDir="$defaultDir/sm-cancel-asset/main"

# forked from https://github.com/samcheck/sm-refund-credit
refundDir="$defaultDir/sm-refund-credit/main"

# forked from https://github.com/samcheck/sm-renewals
renewDir="$defaultDir/sm-renewals/main"

# forked from https://github.com/samcheck/sm-community-template
communityTemplateDir="$defaultDir/sm-community-template/main"

# forked from https://github.com/bgaldino/sm-b2b-connector
commerceConnectorDir="$defaultDir/sm-b2b-connector"
commerceConnectorLibsDir="$defaultDir/sm-b2b-connector/libs"
commerceConnectorMainDir="$defaultDir/sm-b2b-connector/main"

# forked from https://github.com/bgaldino/sm-b2b-connector
commerceConnectorTemplateDir="$defaultDir/sm-b2b-connector-community-template/main"

# temp directory to be merged into one or more new modules - mainly layouts, pages, etc
tempDir="$defaultDir/sm-temp/main"

# named credential for example customer community storefront to access SM APIs
namedCredentialMasterLabel="Salesforce"
stripeNamedCredential="StripeAdapter"

# Sample Experience Cloud Customer Community Storefront Name
communityName="sm"
communityName1="sm1"

# Sample B2B Commerce Storefront Name"
b2bStoreName="B2BSmConnector"
b2bStoreName1="B2BSmConnector1"
b2bCategoryName="Software"

# mock payment gateway
paymentGatewayAdapterName="SalesforceGatewayAdapter"
paymentGatewayProviderName="SalesforceGatewayProvider"
paymentGatewayName="MockPaymentGateway"

# stripe payment gateway
stripeGatewayAdapterName="B2BStripeAdapter"
stripeGatewayProviderName="Stripe_Adapter"
stripePaymentGatewayName="Stripe"

# mock tax provider
taxProviderClassName="MockAdapter"

# commerce interfaces
inventoryInterface="B2BInventoryConnector"
inventoryExternalService="COMPUTE_INVENTORY_B2BSmConnector"
priceInterface="B2BPriceConnector"
priceExternalService="COMPUTE_PRICE_B2BSmConnector"
shipmentInterface="B2BShipmentConnector"
shipmentExternalService="COMPUTE_SHIPMENT_B2BSmConnector"
taxInterface="B2BTaxConnector"
taxExternalService="COMPUTE_TAX_B2BSmConnector"

# default data values
# qbranch org - CDO, SDO, xDO
cdo=0
sdo=0
xdo=0

# managed package IDs
# Salesforce Labs Managed Packages
# Streaming API monitor - currently v3.7.0 - summer 22
streamingAPIMonitor="04t1t000003Y9d7AAC"
# CMS Content Type Manager - currently v 1.3.0 - summer 21
cmsContentTypeManagerPackageId="04t3h000004KnZfAAK"

# B2B Video Player for commerce connector
b2bVideoPlayer="04t6g0000083hTPAAY"
b2bvp=0

# Salesforce CPQ Managed Package - currently 238.2 - summer 22
cpq="04t4N000000xBcT"
billing="04t0K000000wUsV"

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

# ----------------------------------
# Colors
# ----------------------------------
NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTCYAN='\033[1;36m'
WHITE='\033[1;37m'

function echo_attention() {
  local green='\033[0;32m'
  local no_color='\033[0m'
  echo -e "${green}$1${no_color}"
}

function echo_red() {
  local red='\033[0;34m'
  local no_color='\033[0m'
  echo -e "${red}$1${no_color}"
}

function echo_color() {
  case $1 in
  red)
    echo "${RED}$2${NOCOLOR}"
    ;;
  green)
    echo "${GREEN}$2${NOCOLOR}"
    ;;
  orange)
    echo "${ORANGE}$2${NOCOLOR}"
    ;;
  blue)
    echo "${BLUE}$2${NOCOLOR}"
    ;;
  purple)
    echo "${PURPLE}$2${NOCOLOR}"
    ;;
  cyan)
    echo "${CYAN}$2${NOCOLOR}"
    ;;
  gray)
    echo "${LIGHTGRAY}$2${NOCOLOR}"
    ;;
  lightred)
    echo "${LIGHTRED}$2${NOCOLOR}"
    ;;
  lightgreen)
    echo "${LIGHTGREEN}$2${NOCOLOR}"
    ;;
  lightblue)
    echo "${LIGHTBLUE}$2${NOCOLOR}"
    ;;
  lightpurple)
    echo "${LIGHTPURPLE}$2${NOCOLOR}"
    ;;
  yellow)
    echo "${YELLOW}$2${NOCOLOR}"
    ;;
  *)
    echo "${NOCOLOR}$2"
    ;;
  esac
}

echo_keypair() {
  echo "${CYAN}$1${NOCOLOR}:${ORANGE}$2${NOCOLOR}"
}

function error_and_exit() {
  echo "$1"
  exit 1
}

function prompt_to_accept_disclaimer() {
  echo_color green "This setup can create an example storefront that is built using Experience Cloud to faciliate development with and understanding of Subscription Management."
  echo_color green "Because Subscription Management isn't yet licensed for use with Experience Cloud, the Customer Account Portal that is created as part of this setup will execute some operations to access the Subscription Management APIs as a privleged internal user for developmet purposes."
  echo_color red "This may not be used in a licensed and active production org - doing so may violate your license agreement and create a security risk."
  echo_color cyan "[0] No, proceed with setup without Experience Cloud"
  echo_color cyan "[1] Yes, proceed with setup including Experience Cloud"
  echo_color cyan "[2] No, do not proceed and exit setup"
  echo_color red "Do you agree to these conditions?"
  read -p "Please enter a value > " acceptDisclaimer
  local t1=$(grep -x "sm/sm-my-community" .forceignore)
  local t2=$(grep -x "sm/sm-community-template" .forceignore)
  local t3=$(grep -x "sm/sm-nocommunity" .forceignore)
  case $acceptDisclaimer in
  0)
    createCommunity=0
    includeCommunity=0
    if [ -z $t1 ]; then
      echo "sm/sm-my-community" >>.forceignore
    fi
    if [ -z $t2 ]; then
      echo "sm/sm-community-template" >>.forceignore
    fi
    if [ -n $t3 ]; then
      sed -i '' '/^sm\/sm-nocommunity$/d' .forceignore
    fi
    ;;
  1)
    # TODO - this overwrites any explicit overrides from above.
    # This needs to be refactored to retain any overrides such as createCommunity if script is being run after a failure but the community was created.
    createCommunity=1
    includeCommunity=1
    if [ -n $t1 ]; then
      sed -i '' '/^sm\/sm-my-community$/d' .forceignore
    fi
    if [ -n $t2 ]; then
      sed -i '' '/^sm\/sm-community-template$/d' .forceignore
    fi
    if [ -z $t3 ]; then
      echo "sm/sm-nocommunity" >>.forceignore
    fi
    ;;
  2)
    error_and_exit "Disclaimer conditions not accepted - exiting"
    ;;
  esac
}

function prompt_to_create_scratch() {
  echo_color green "Would you like to create a scratch org?"
  echo_color cyan "[0] No"
  echo_color cyan "[1] Yes"
  read -p "Please enter a value > " createScratch
  if [ $createScratch -eq 1 ]; then
    orgType=1
  fi
}

function prompt_for_scratch_edition() {
  echo_color green "What type of scratch org would you like to create?"
  echo_color cyan "[0] Developer"
  echo_color cyan "[1] Enterprise"
  read -p "Please enter the scratch org type you would like to create > " scratchEdition
}

function prompt_for_scratch_alias() {
  read -p "Please enter an alias for your scratch org > " scratchAlias
}

function prompt_for_org_type() {
  echo_color green "What type of org are you deploying to?"
  echo_color cyan "[0] Production/Developer"
  echo_color cyan "[1] Scratch"
  echo_color cyan "[2] Sandbox"
  echo_color cyan "[3] Falcon (test1 - Internal SFDC only)"
  read -p "Please enter the org type you would like to set up > " orgType
}

function prompt_for_falcon_instance() {
  echo_color green "Which falcon instance are you using?"
  echo_color cyan "[0] NA46 (main branch)"
  echo_color cyan "[1] NA45 (main-2 branch)"
  read -p "Please enter the falcon instance you would like to target > " falconInstance
}

function prompt_to_install_connector() {
  echo_color green "Would you like to install the Subscription Management/B2B Commerce connector and configured store?"
  echo_color red "NOTICE:  This feature is currently under development and requires additional configuration after the quickstart process completes"
  echo_color cyan "[0] No"
  echo_color cyan "[1] Yes"
  read -p "Please enter a value > " includeCommerceConnector
}

function get_user_email {
  local un=$1
  userEmail=$(sfdx force:data:soql:query -q "SELECT Email from User WHERE Username='$un' LIMIT 1" -r csv | tail -n +2)
  if [ -z $userEmail ]; then
    echo_color green "Email lookup failed for username $un"
  else
    echo_color green "Email: "
    echo_color cyan "$userEmail"
  fi
}

function get_sfdx_user_info() {
  tmpfile=$(mktemp)
  sfdx force:user:display --json >$tmpfile

  username=$(cat $tmpfile | grep -o '"username": *"[^"]*' | grep -o '[^"]*$')
  userId=$(cat $tmpfile | grep -o '"id": *"[^"]*' | grep -o '[^"]*$')
  orgId=$(cat $tmpfile | grep -o '"orgId": *"[^"]*' | grep -o '[^"]*$')
  instanceUrl=$(cat $tmpfile | grep -o '"instanceUrl": *"[^"]*' | grep -o '[^"]*$')
  myDomain=$(echo $instanceUrl | sed 's/^........//')
  mySubDomain=$(echo $myDomain | cut -d "." -f 1)

  echo_color green "Current Username: "
  echo_keypair username $username
  echo_color green "Current User Id: "
  echo_keypair userId $userId
  echo_color green "Current Org Id: "
  echo_keypair orgId $orgId
  echo_color green "Current Instance URL: "
  echo_keypair instanceUrl $instanceUrl
  echo_color green "Current myDomain: "
  echo_keypair myDomain $myDomain
  echo_color green "Current mySubDomain: "
  echo_keypair mySubDomain $mySubDomain
  rm $tmpfile
  echo ""
  if [ -z $userEmail ]; then
    get_user_email $username
  fi
}

function create_scratch_org() {
  local alias=$1
  local defFile="config/project-scratch-def.json"

  case $scratchEdition in
  0)
    defFile="config/dev-scratch-def.json"
    ;;
  1)
    defFile="config/enterprise-scratch-def.json"
    ;;
  esac

  #sfdx force:org:create -f $defFile -a $alias -s -d 30
  sf env create scratch -f $defFile -a $alias -d -y 30
}

function deploy() {
  #sfdx force:source:deploy -p $1 -g --apiversion=$apiversion
  sf deploy metadata -g -c -d $1 -a $apiversion
}

function install_package() {
  sfdx force:package:beta:install -p $1 --apiversion=$apiversion
}

function count_permset_license() {
  permsetCount=$(sfdx force:data:soql:query -q "Select COUNT(Id) from PermissionSetLicenseAssign Where AssigneeId='$userId' and PermissionSetLicenseId IN (SELECT Id FROM PermissionSetLicense WHERE DeveloperName = '$1')" -r csv | tail -n +2)
}

function count_permset() {
  local ps=("$@")
  local q="SELECT COUNT(Id) FROM PermissionSetAssignment WHERE AssigneeID='$userId' AND PermissionSetId IN (SELECT Id FROM PermissionSet WHERE Name IN ($1))"
  permsetCount=$(sfdx force:data:soql:query -q "$q" -r csv | tail -n +2)
}

function assign_permset_license() {
  local ps=("$@")
  for i in "${ps[@]}"; do
    count_permset_license "$i"
    if [ $permsetCount = "0" ]; then
      echo_color green "Assiging Permission Set License: $i"
      sfdx force:user:permsetlicense:assign -n $i
    else
      echo_color green "Permission Set License Assignment for Permset $i exists for $username"
    fi
  done
}

function assign_permset() {
  local ps=("$@")
  for i in "${ps[@]}"; do
    count_permset "$i"
    if [ $permsetCount = "0" ]; then
      echo_color green "Assiging Permset: $i"
      sfdx force:user:permset:assign -n $i
    else
      echo_color green "Permset Assignment for Permset $i exists for $username"
    fi
  done
}

function assign_all_permsets() {
  local ps=("$@")
  local delim="'"
  local joined=""
  local sq="'"
  local len=${#ps[@]}
  local lenstr=$lenstr$len
  for i in "${ps[@]}"; do
    joined="$joined$delim$i"
    delim="','"
  done
  joined=$joined$sq
  count_permset $joined
  if [ $permsetCount != $lenstr ]; then
    echo_color green "Permsets Missing - Attempting to Assign All Permsets"
    sfdx force:user:permset:assign -n $joined
  else
    echo_color green "All Permsets Assigned"
  fi
}

function check_qbranch() {
  if [ $orgType -eq 0 ]; then
    tmpfile=$(mktemp)
    echo_color green "Checking for QBranch Utils"
    sfdx force:package:installed:list --json >$tmpfile
    qbranch=$(cat $tmpfile | grep -o '"SubscriberPackageNamespace": *"[^"]*' | grep -o 'qbranch')
    if [ -n "$qbranch" ]; then
      echo_color cyan "QBranch Utils Found - CDO/SDO"
      cdo=1
    fi
  fi
}

function check_b2b_videoplayer() {
  if [ $b2bvp -eq 0 ]; then
    tmpfile=$(mktemp)
    echo_color green "Checking for B2B LE Video Player"
    sfdx force:package:installed:list --json >$tmpfile
    qbranch=$(cat $tmpfile | grep -o '"SubscriberPackageNamespace": *"[^"]*' | grep -o 'b2bvp')
    if [ -n "$b2bvp" ]; then
      echo_color cyan "B2B LE Video Player Found"
      b2bvp=1
    fi
  fi
}

function get_store_url() {
  if [ $orgType -eq 1 ]; then
    storeBaseUrl="$mySubDomain.scratch.my.site.com"
  else
    storeBaseUrl="$mySubDomain.my.site.com"
  fi
  echo_keypair storeBaseUrl $storeBaseUrl
}

function get_org_base_url() {
  if [ $orgType -eq 1 ]; then
    orgBaseUrl="$mySubDomain.scratch.lightning.force.com"
    oauthUrl="test.salesforce.com"
  else
    orgBaseUrl="$mySubDomain.lightning.force.com"
    oauthUrl="login.salesforce.com"
  fi
  echo_keypair orgBaseUrl $orgBaseUrl
  echo_keypair oauthUrl $oauthUrl
}

function populate_b2b_connector_custom_metadata() {
  echo_color green "Populating variables for B2B Connector Custom Metadata"
  get_store_url
  get_org_base_url
  echo_color green "Getting Id for WebStore $b2bStoreName"
  commerceStoreId=$(sfdx force:data:soql:query -q "SELECT Id FROM WebStore WHERE Name='$b2bStoreName' LIMIT 1" -r csv | tail -n +2)
  echo_keypair commerceStoreId $commerceStoreId
  defaultCategoryId=$(sfdx force:data:soql:query -q "SELECT Id FROM ProductCategory WHERE Name='$b2bCategoryName' LIMIT 1" -r csv | tail -n +2)
  echo_keypair defaultCategoryId $defaultCategoryId

  sed -e "s/INSERT_CATEGORY_ID/$defaultCategoryId/g" quickstart-config/sm-b2b-connector/customMetadata/B2B_Store_Configuration.CategoryId.md-meta.xml >temp_b2b_store_configuration_categoryid.xml
  sed -e "s/INSERT_WEBSTORE_ID/$commerceStoreId/g" quickstart-config/sm-b2b-connector/customMetadata/B2B_Store_Configuration.WebStoreId.md-meta.xml >temp_b2b_store_configuration_webstoreid.xml
  sed -e "s/INSERT_INTERNAL_ACCOUNT_ID/$userId/g" quickstart-config/sm-b2b-connector/customMetadata/B2B_Store_Configuration.InternalAccountId.md-meta.xml >temp_b2b_store_configuration_internalaccountid.xml
  sed -e "s/INSERT_SUPER_USER_INTERNAL_ACCOUNT_ID/$userId/g" quickstart-config/sm-b2b-connector/customMetadata/B2B_Store_Configuration.SuperUserInternalAccountId.md-meta.xml >temp_b2b_store_configuration_superuserinternalaccountid.xml
  sed -e "s/INSERT_STORE_BASE_URL/https:\/\/$storeBaseUrl/g" quickstart-config/sm-b2b-connector/customMetadata/B2B_Store_Configuration.StoreBaseUrl.md-meta.xml >temp_b2b_store_configuration_storebaseurl.xml
  sed -e "s/INSERT_STORE_URL/https:\/\/$storeBaseUrl\/$b2bStoreName/g" quickstart-config/sm-b2b-connector/customMetadata/B2B_Store_Configuration.StoreUrl.md-meta.xml >temp_b2b_store_configuration_storeurl.xml
  sed -e "s/INSERT_ORG_DOMAIN_URL/https:\/\/$orgBaseUrl/g" quickstart-config/sm-b2b-connector/customMetadata/B2B_Store_Configuration.OrgDomainUrl.md-meta.xml >temp_b2b_store_configuration_orgdomainurl.xml
  sed -e "s/INSERT_TAX_ENGINE_ID/$taxEngineId/g" quickstart-config/sm-b2b-connector/customMetadata/B2B_Store_Configuration.TaxEngineId.md-meta.xml >temp_b2b_store_configuration_taxengineid.xml
  sed -e "s/INSERT_WEBSTORE_ID/$commerceStoreId/g" -e "s/INSERT_USERNAME/$username/g" -e "s/INSERT_CERTIFICATE_NAME/SMB2BPrivateKey/g" -e "s/INSERT_SALESFORCE_BASE_URL/https:\/\/$oauthUrl/g" -e "s/INSERT_EFFECTIVE_ACCOUNT_ID/$defaultAccountId/g" -e "s/INSERT_COMMUNITY_BASE_URL/https:\/\/$oauthUrl/g" quickstart-config/sm-b2b-connector/customMetadata/B2B_User_Login_Configuration.System_Admin_Configurations.md-meta.xml >temp_b2b_user_login_configuration.xml
  sed -e "s/INSERT_ORG_BASE_URL/https:\/\/$orgBaseUrl/g" quickstart-config/sm-b2b-connector/remoteSiteSettings/SFLabs.remoteSite-meta.xml >temp_SFLabs.remoteSite-meta.xml
  sed -e "s/INSERT_MYDOMAIN_URL/https:\/\/$myDomain/g" quickstart-config/sm-b2b-connector/remoteSiteSettings/MyDomain.remoteSite-meta.xml >temp_MyDomain.remoteSite-meta.xml

  mv temp_b2b_store_configuration_categoryid.xml $commerceConnectorMainDir/connectorConfigs/customMetadata/B2B_Store_Configuration.CategoryId.md-meta.xml
  mv temp_b2b_store_configuration_webstoreid.xml $commerceConnectorMainDir/connectorConfigs/customMetadata/B2B_Store_Configuration.WebStoreId.md-meta.xml
  mv temp_b2b_store_configuration_internalaccountid.xml $commerceConnectorMainDir/connectorConfigs/customMetadata/B2B_Store_Configuration.InternalAccountId.md-meta.xml
  mv temp_b2b_store_configuration_superuserinternalaccountid.xml $commerceConnectorMainDir/connectorConfigs/customMetadata/B2B_Store_Configuration.SuperUserInternalAccountId.md-meta.xml
  mv temp_b2b_store_configuration_storebaseurl.xml $commerceConnectorMainDir/connectorConfigs/customMetadata/B2B_Store_Configuration.StoreBaseUrl.md-meta.xml
  mv temp_b2b_store_configuration_storeurl.xml $commerceConnectorMainDir/connectorConfigs/customMetadata/B2B_Store_Configuration.StoreUrl.md-meta.xml
  mv temp_b2b_store_configuration_orgdomainurl.xml $commerceConnectorMainDir/connectorConfigs/customMetadata/B2B_Store_Configuration.OrgDomainUrl.md-meta.xml
  mv temp_b2b_store_configuration_taxengineid.xml $commerceConnectorMainDir/connectorConfigs/customMetadata/B2B_Store_Configuration.TaxEngineId.md-meta.xml
  mv temp_b2b_user_login_configuration.xml $commerceConnectorMainDir/connectorConfigs/customMetadata/B2B_User_Login_Configuration.System_Admin_Configurations.md-meta.xml
  mv temp_SFLabs.remoteSite-meta.xml $commerceConnectorMainDir/default/remoteSiteSettings/SFLabs.remoteSite-meta.xml
  mv temp_MyDomain.remoteSite-meta.xml $commerceConnectorMainDir/default/remoteSiteSettings/MyDomain.remoteSite-meta.xml

}

function insert_data() {
  if [ $insertData -eq 1 ]; then

    echo_color green "Copying Mock Tax Engine to TaxTreatment.json"
    sed -e "s/\"TaxEngineId\": \"INSERT_TAX_ENGINE_ID\"/\"TaxEngineId\": \"${taxEngineId}\"/g" data/TaxTreatment-template.json >data/TaxTreatment.json
    sleep 2

    echo_color green "Pushing Tax & Billing Policy Data to the Org"
    sfdx force:data:tree:import -p data/data-plan-1.json
    echo ""

    echo_color green "Activating Tax & Billing Policies and Updating Product2 data records with Activated Policy Ids"
    scripts/activate-tax-and-billing-policies.sh || error_and_exit "Tax & Billing Policy Activation Failed"
    echo ""

    echo_color green "Pushing Product & Pricing Data to the Org"
    # Choose to seed data with all SM Product setup completed or choose the base option to not add PSMO and PBE for use in workshops
    if [ $includeCommerceConnector -eq 1 ]; then
      commerceStoreId=$(sfdx force:data:soql:query -q "SELECT Id FROM WebStore WHERE Name='$b2bStoreName' LIMIT 1" -r csv | tail -n +2)
      echo_keypair commerceStoreId $commerceStoreId
      standardPricebook2Id=$(sfdx force:data:soql:query -q "SELECT Id FROM Pricebook2 WHERE Name='Standard Price Book' AND IsStandard=true LIMIT 1" -r csv | tail -n +2)
      echo_keypair standardPricebook2Id $standardPricebook2Id
      smPricebook2Id=$(sfdx force:data:soql:query -q "SELECT Id FROM Pricebook2 WHERE Name='Subscription Management Price Book' LIMIT 1" -r csv | tail -n +2)
      echo_keypair smPricebook2Id $standardPricebook2Id
      commercePricebook2Id=$(sfdx force:data:soql:query -q "SELECT Id FROM Pricebook2 WHERE Name='B2B Commerce Price Book' LIMIT 1" -r csv | tail -n +2)
      echo_keypair commercePricebook2Id $commercePricebook2Id
      echo_color green "Getting Standard and Commerce Pricebooks for Pricebook Entries and replacing in data files"
      sed -e "s/\"Pricebook2Id\": \"STANDARD_PRICEBOOK\"/\"Pricebook2Id\": \"${standardPricebook2Id}\"/g" -e "s/\"Pricebook2Id\": \"SM_PRICEBOOK\"/\"Pricebook2Id\": \"${smPricebook2Id}\"/g" -e "s/\"Pricebook2Id\": \"COMMERCE_PRICEBOOK\"/\"Pricebook2Id\": \"${commercePricebook2Id}\"/g" data/PricebookEntry-template.json >data/PricebookEntry.json
      sed -e "s/\"Pricebook2Id\": \"COMMERCE_PRICEBOOK_ID\"/\"Pricebook2Id\": \"${commercePricebook2Id}\"/g" -e "s/\"Pricebook2Id\": \"SM_PRICEBOOK_ID\"/\"Pricebook2Id\": \"${smPricebook2Id}\"/g" data/BuyerGroupPricebooks-template.json >data/BuyerGroupPricebooks.json
      sed -e "s/\"WebStoreId\": \"PutWebStoreIdHere\"/\"WebStoreId\": \"${commerceStoreId}\"/g" data/WebStoreBuyerGroups-template.json >data/WebStoreBuyerGroups.json
      sed -e "s/\"SalesStoreId\": \"PutWebStoreIdHere\"/\"SalesStoreId\": \"${commerceStoreId}\"/g" data/WebStoreCatalogs-template.json >data/WebStoreCatalogs.json
      sed -e "s/\"WebStoreId\": \"PutWebStoreIdHere\"/\"WebStoreId\": \"${commerceStoreId}\"/g" -e "s/\"Pricebook2Id\": \"COMMERCE_PRICEBOOK_ID\"/\"Pricebook2Id\": \"${commercePricebook2Id}\"/g" -e "s/\"Pricebook2Id\": \"SM_PRICEBOOK_ID\"/\"Pricebook2Id\": \"${smPricebook2Id}\"/g" data/WebStorePricebooks-template.json >data/WebStorePricebooks.json
      sfdx force:data:tree:import -p data/data-plan-commerce.json
      echo_color green "Updating Webstore $b2bStoreName StrikethroughPricebookId to $commercePricebook2Id"
      sfdx force:data:record:update -s WebStore -i $commerceStoreId -v "StrikethroughPricebookId='$commercePricebook2Id'"
    else
      sfdx force:data:tree:import -p data/data-plan-2.json
    fi
    #sfdx force:data:tree:import -p data/data-plan-2-base.json
    echo ""

    echo_color green "Pushing Default Account & Contact"
    sfdx force:data:tree:import -p data/data-plan-3.json
    echo ""
  fi
}

function create_tax_engine() {
  echo_color green "Getting Id for ApexClass $taxProviderClassName"
  taxProviderClassId=$(sfdx force:data:soql:query -q "SELECT Id FROM ApexClass WHERE Name='$taxProviderClassName' LIMIT 1" -r csv | tail -n +2)
  echo_keypair taxProviderClassId $taxProviderClassId
  echo_color green "Creating TaxEngineProvider $taxProviderClassName"
  sfdx force:data:record:create -s TaxEngineProvider -v "DeveloperName='$taxProviderClassName' MasterLabel='$taxProviderClassName' ApexAdapterId=$taxProviderClassId"
  echo_color green "Getting Id for TaxEngineProvider $taxProviderClassName"
  taxEngineProviderId=$(sfdx force:data:soql:query -q "SELECT Id FROM TaxEngineProvider WHERE DeveloperName='$taxProviderClassName' LIMIT 1" -r csv | tail -n +2)
  echo_keypair taxEngineProviderId $taxEngineProviderId
  echo_color green "Getting Id for NamedCredential $namedCredentialMasterLabel"
  taxMerchantCredentialId=$(sfdx force:data:soql:query -q "SELECT Id from NamedCredential WHERE DeveloperName='$namedCredentialMasterLabel' LIMIT 1" -r csv | tail -n +2)
  echo_keypair taxMerchantCredentialId $taxMerchantCredentialId
  echo_color green "Creating TaxEngine $taxProviderClassName"
  sfdx force:data:record:create -s TaxEngine -v "TaxEngineName='$taxProviderClassName' MerchantCredentialId=$taxMerchantCredentialId TaxEngineProviderId=$taxEngineProviderId Status='Active' SellerCode='Billing2' TaxEngineCity='San Francisco' TaxEngineCountry='United States' TaxEnginePostalCode='94105' TaxEngineState='California'"
  taxEngineId=$(sfdx force:data:soql:query -q "SELECT Id FROM TaxEngine WHERE TaxEngineName='$taxProviderClassName' LIMIT 1" -r csv | tail -n +2)
  echo_color green "$taxProviderClassName Tax Engine Id:"
  echo_keypair taxEngineId $taxEngineId
}

function register_commerce_services() {
  stripeApexClassId=$(sfdx force:data:soql:query -q "SELECT Id FROM ApexClass WHERE Name='$stripeGatewayAdapterName' LIMIT 1" -r csv | tail -n +2)
  echo_keypair stripeApexClassId $stripeApexClassId
  sleep 1

  if [ -z "$stripeApexClassId" ]; then
    error_and_exit "No Stripe Payment Gateway Adapter Class"
  else
    # Creating Payment Gateway
    echo_color green "Getting Stripe Payment Gateway Provider $stripeGatewayProviderName"
    stripePaymentGatewayProviderId=$(sfdx force:data:soql:query -q "SELECT Id FROM PaymentGatewayProvider WHERE DeveloperName='$stripeGatewayProviderName' LIMIT 1" -r csv | tail -n +2)
    echo_keypair stripePaymentGatewayProviderId $stripePaymentGatewayProviderId
    sleep 1
  fi

  echo_color green "Getting Stripe Named Credential $stripeNamedCredential"
  stripeNamedCredentialId=$(sfdx force:data:soql:query -q "SELECT Id FROM NamedCredential WHERE MasterLabel='$stripeNamedCredential' LIMIT 1" -r csv | tail -n +2)
  echo_keypair stripeNamedCredentialId $stripeNamedCredentialId
  sleep 1
  echo ""

  if [ $createStripeGateway -eq 1 ]; then
    echo_color green "Creating PaymentGateway record using MerchantCredentialId=$stripeNamedCredentialId, PaymentGatewayProviderId=$stripePaymentGatewayProviderId."
    sfdx force:data:record:create -s PaymentGateway -v "MerchantCredentialId=$stripeNamedCredentialId PaymentGatewayName=$stripePaymentGatewayName PaymentGatewayProviderId=$stripePaymentGatewayProviderId Status=Active"
    sleep 1
  fi

  echo_color green "Getting Id for ApexClass $inventoryInterface"
  inventoryInterfaceId=$(sfdx force:data:soql:query -q "SELECT Id FROM ApexClass WHERE Name='$inventoryInterface' LIMIT 1" -r csv | tail -n +2)
  echo_keypair inventoryInterfaceId $inventoryInterfaceId
  echo_color green "Getting Id for ApexClass $priceInterface"
  priceInterfaceId=$(sfdx force:data:soql:query -q "SELECT Id FROM ApexClass WHERE Name='$priceInterface' LIMIT 1" -r csv | tail -n +2)
  echo_keypair priceInterfaceId $priceInterfaceId
  echo_color green "Getting Id for ApexClass $shipmentInterface"
  shipmentInterfaceId=$(sfdx force:data:soql:query -q "SELECT Id FROM ApexClass WHERE Name='$shipmentInterface' LIMIT 1" -r csv | tail -n +2)
  echo_keypair shipmentInterfaceId $shipmentInterfaceId
  echo_color green "Getting Id for ApexClass $taxInterface"
  taxInterfaceId=$(sfdx force:data:soql:query -q "SELECT Id FROM ApexClass WHERE Name='$taxInterface' LIMIT 1" -r csv | tail -n +2)
  echo_keypair taxInterfaceId $taxInterfaceId

  echo_color green "Registering External Service $inventoryExternalService"
  sfdx force:data:record:create -s RegisteredExternalService -v "DeveloperName=$inventoryExternalService ExternalServiceProviderId=$inventoryInterfaceId ExternalServiceProviderType=Inventory MasterLabel=$inventoryExternalService"
  echo_color green "Registering External Service $priceExternalService"
  sfdx force:data:record:create -s RegisteredExternalService -v "DeveloperName=$priceExternalService ExternalServiceProviderId=$priceInterfaceId ExternalServiceProviderType=Price MasterLabel=$priceExternalService"
  echo_color green "Registering External Service $shipmentExternalService"
  sfdx force:data:record:create -s RegisteredExternalService -v "DeveloperName=$shipmentExternalService ExternalServiceProviderId=$shipmentInterfaceId ExternalServiceProviderType=Shipment MasterLabel=$shipmentExternalService"
  echo_color green "Registering External Service $taxExternalService"
  sfdx force:data:record:create -s RegisteredExternalService -v "DeveloperName=$taxExternalService ExternalServiceProviderId=$taxInterfaceId ExternalServiceProviderType=Tax MasterLabel=$taxExternalService"

  inventoryRegisteredService=$(sfdx force:data:soql:query -q "SELECT Id FROM RegisteredExternalService WHERE DeveloperName='$inventoryExternalService' LIMIT 1" -r csv | tail -n +2)
  echo_keypair inventoryRegisteredService $inventoryRegisteredService
  priceRegisteredService=$(sfdx force:data:soql:query -q "SELECT Id FROM RegisteredExternalService WHERE DeveloperName='$priceExternalService' LIMIT 1" -r csv | tail -n +2)
  echo_keypair priceRegisteredService $priceRegisteredService
  shipmentRegisteredService=$(sfdx force:data:soql:query -q "SELECT Id FROM RegisteredExternalService WHERE DeveloperName='$shipmentExternalService' LIMIT 1" -r csv | tail -n +2)
  echo_keypair shipmentRegisteredService $shipmentRegisteredService
  taxRegisteredService=$(sfdx force:data:soql:query -q "SELECT Id FROM RegisteredExternalService WHERE DeveloperName='$taxExternalService' LIMIT 1" -r csv | tail -n +2)
  echo_keypair taxRegisteredService $taxRegisteredService

  echo_color green "Creating StoreIntegratedService $inventoryExternalService"
  sfdx force:data:record:create -s StoreIntegratedService -v "integration=$inventoryRegisteredService StoreId=$commerceStoreId ServiceProviderType=Inventory"
  echo_color green "Creating StoreIntegratedService $priceExternalService"
  sfdx force:data:record:create -s StoreIntegratedService -v "integration=$priceRegisteredService StoreId=$commerceStoreId ServiceProviderType=Price"
  echo_color green "Creating StoreIntegratedService $shipmentExternalService"
  sfdx force:data:record:create -s StoreIntegratedService -v "integration=$shipmentRegisteredService StoreId=$commerceStoreId ServiceProviderType=Shipment"
  echo_color green "Creating StoreIntegratedService $taxExternalService"
  sfdx force:data:record:create -s StoreIntegratedService -v "integration=$taxRegisteredService StoreId=$commerceStoreId ServiceProviderType=Tax"

  serviceMappingId=$(sfdx force:data:soql:query -q "SELECT Id FROM StoreIntegratedService WHERE StoreId='$commerceStoreId' AND ServiceProviderType='Payment' LIMIT 1" -r csv | tail -n +2)
  if [ ! -z $serviceMappingId ]; then
    echo "StoreMapping already exists.  Deleting old mapping."
    sfdx force:data:record:delete -s StoreIntegratedService -i $serviceMappingId
  fi
  stripePaymentGatewayId=$(sfdx force:data:soql:query -q "SELECT Id FROM PaymentGateway WHERE PaymentGatewayName='$stripePaymentGatewayName' LIMIT 1" -r csv | tail -n +2)
  echo_color green "Creating StoreIntegratedService using the $b2bStoreName store and Integration=$stripePaymentGatewayId (PaymentGatewayId)"
  sfdx force:data:record:create -s StoreIntegratedService -v "Integration=$stripePaymentGatewayId StoreId=$commerceStoreId ServiceProviderType=Payment"
}

while [[ ! $acceptDisclaimer =~ 0|1 ]]; do
  prompt_to_accept_disclaimer
done

while [[ ! $createScratch =~ 0|1 ]]; do
  prompt_to_create_scratch
done

if [ $createScratch -eq 1 ]; then
  while [[ ! $scratchEdition =~ 0|1 ]]; do
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
    esac
    echo_color green "Creating $type scratch org with alias $scratchAlias"
    create_scratch_org $scratchAlias
  else
    error_and_exit "Cannot create scratch org - exiting"
  fi
fi

while [[ ! $orgType =~ 0|1|2|3 ]]; do
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
esac

prompt_to_install_connector

get_sfdx_user_info

sed -e "s/<callbackUrl>https:\/\/login.salesforce.com\/services\/oauth2\/callback<\/callbackUrl>/<callbackUrl>https:\/\/login.salesforce.com\/services\/oauth2\/callback\nhttps:\/\/$myDomain\/services\/oauth2\/callback<\/callbackUrl>/g" quickstart-config/Postman.connectedApp-meta-template.xml >postmannew.xml
sed -e "s/<callbackUrl>https:\/\/login.salesforce.com\/services\/oauth2\/callback<\/callbackUrl>/<callbackUrl>https:\/\/login.salesforce.com\/services\/oauth2\/callback\nhttps:\/\/$myDomain\/services\/oauth2\/callback\nhttps:\/\/$myDomain\/services\/authcallback\/SF<\/callbackUrl>/g" quickstart-config/Salesforce.connectedApp-meta-template.xml >salesforcenew.xml
sed -e "s/www.salesforce.com/$myDomain/g" quickstart-config/MySalesforce.namedCredential-meta-template.xml >mysalesforce.xml
mv postmannew.xml $baseDir/default/connectedApps/Postman.connectedApp-meta.xml
mv salesforcenew.xml $baseDir/default/connectedApps/Salesforce.connectedApp-meta.xml
mv mysalesforce.xml $tempDir/default/namedCredentials/MySalesforce.namedCredential-meta.xml

if [ $deployCode -eq 1 ]; then
  echo_color green "Setting Default Org Settings"
  scripts/set-org-settings.sh || error_and_exit "Setting Org Settings Failed."
  echo ""
fi

echo_color green "Assigning Permission Sets & Permission Set Groups"
assign_permset_license "RevSubscriptionManagementPsl"
assign_all_permsets "${smPermissionSets[@]}"
if [ $includeCommerceConnector -eq 1 ]; then
  assign_permset_license "CommerceAdminUserPsl"
  assign_all_permsets "${b2bCommercePermissionSets[@]}"
fi

#./assign-permsets.sh || error_and_exit "Permset Assignments Failed."
echo ""

if [ $deployCode -eq 1 ]; then
  echo_color green "Pushing sm-base to the Org. This will take few mins."
  deploy $baseDir
fi

assign_permset "'SM_Base'"
echo ""

# Activate Standard Pricebook
echo_color green "Activating Standard Pricebook"
pricebook1=$(sfdx force:data:soql:query -q "SELECT Id FROM Pricebook2 WHERE Name='Standard Price Book' AND IsStandard=true LIMIT 1" -r csv | tail -n +2)
echo_keypair pricebook1 $pricebook1
sleep 1
if [ -n "$pricebook1" ]; then
  sfdx force:data:record:update -s Pricebook2 -i $pricebook1 -v "IsActive=true"
  sleep 1
else
  error_and_exit "Could not determine Standard Pricebook.  Exiting."
fi

apexClassId=$(sfdx force:data:soql:query -q "SELECT Id FROM ApexClass WHERE Name='$paymentGatewayAdapterName' LIMIT 1" -r csv | tail -n +2)
sleep 1

if [ -z "$apexClassId" ]; then
  error_and_exit "No Payment Gateway Adapter Class"
else
  # Creating Payment Gateway
  echo_color green "Getting Payment Gateway Provider $paymentGatewayProviderName"
  paymentGatewayProviderId=$(sfdx force:data:soql:query -q "SELECT Id FROM PaymentGatewayProvider WHERE DeveloperName='$paymentGatewayProviderName' LIMIT 1" -r csv | tail -n +2)
  echo_keypair paymentGatewayProviderId $paymentGatewayProviderId
  sleep 1
fi

echo_color green "Getting Named Credential $namedCredentialMasterLabel"
namedCredentialId=$(sfdx force:data:soql:query -q "SELECT Id FROM NamedCredential WHERE MasterLabel='$namedCredentialMasterLabel' LIMIT 1" -r csv | tail -n +2)
echo_keypair cyan namedCredentialId $namedCredentialId
sleep 1
echo ""

if [ $createGateway -eq 1 ]; then
  echo_color green "Creating PaymentGateway record using MerchantCredentialId=$namedCredentialId, PaymentGatewayProviderId=$paymentGatewayProviderId."
  sfdx force:data:record:create -s PaymentGateway -v "MerchantCredentialId=$namedCredentialId PaymentGatewayName=$paymentGatewayName PaymentGatewayProviderId=$paymentGatewayProviderId Status=Active"
  sleep 1
fi

if [ $createCommunity -eq 1 ]; then
  echo_color green "Creating Subscription Management Customer Account Portal Digital Experience"
  sfdx force:community:create --name "$communityName" --templatename "Customer Account Portal" --urlpathprefix "$communityName" --description "Customer Portal created by Subscription Management Quickstart"
fi

if [ $includeCommunity -eq 1 ]; then
  while [ -z "${storeId}" ]; do
    echo_color green "Subscription Management Customer Community not yet created, waiting 10 seconds..."
    storeId=$(sfdx force:data:soql:query -q "SELECT Id FROM Network WHERE Name='$communityName' LIMIT 1" -r csv | tail -n +2)
    sleep 10
  done

  echo_color cyan "Subscription Management Customer Community found with id ${storeId}"
  echo_keypair storeId $storeId
  echo ""

  roles=$(sfdx force:data:soql:query --query \ "SELECT COUNT(Id) FROM UserRole WHERE Name = 'CEO'" -r csv | tail -n +2)

  if [ "$roles" = "0" ]; then
    sfdx force:data:record:create -s UserRole -v "Name='CEO' DeveloperName='CEO' RollupDescription='CEO'"
    sleep 1
  else
    echo_color green "CEO Role already exists - proceeding without creating it."
  fi

  ceoRoleId=$(sfdx force:data:soql:query --query \ "SELECT Id FROM UserRole WHERE Name = 'CEO'" -r csv | tail -n +2)

  echo_color green "CEO role ID: "
  echo_keypair ceoRoleId $ceoRoleId
  sleep 1

  sfdx force:data:record:update -s User -v "UserRoleId='$ceoRoleId' Country='United States'" -w "Username='$username'"
  sleep 1
fi

if [ -z "$pricebook1" ]; then
  pricebook1=$(sfdx force:data:soql:query -q "SELECT Id FROM Pricebook2 WHERE Name='Standard Price Book' AND IsStandard=true LIMIT 1" -r csv | tail -n +2)
  echo_keypair pricebook1 $pricebook1
  sleep 1
fi

paymentGatewayId=$(sfdx force:data:soql:query -q "Select Id from PaymentGateway Where PaymentGatewayName='MockPaymentGateway' and Status='Active'" -r csv | tail -n +2)
echo_keypair paymentGatewayId $paymentGatewayId
sleep 1

if [ -n "$pricebook1" ] && [ -n "$paymentGatewayId" ]; then
  tmpfile=$(mktemp)
  sed -e "s/INSERT_GATEWAY/$paymentGatewayId/g;s/INSERT_PRICEBOOK/$pricebook1/g" quickstart-config/home.json >$tmpfile
  mv -f $tmpfile $communityTemplateDir/default/experiences/$communityName1/views/home.json
else
  error_and_exit "Could not retrieve Pricebook or Payment Gateway.  Exiting before pushing community template"
fi

# This is a quick fix for issue #3.  CDO/SDO has Action Plan feature enabled.
# TODO - Refactor to check for specific features and include/exclude specific routes and views accordingly.
if [ $cdo -eq 1 ]; then
  echo_color green "Copying CDO/SDO community components to $communityName1"
  cp -f quickstart-config/cdo/experiences/$communityName1/routes/actionPlan* $communityTemplateDir/default/experiences/$communityName1/routes/.
  cp -f quickstart-config/cdo/experiences/$communityName1/views/actionPlan* $communityTemplateDir/default/experiences/$communityName1/views/.
  if [ $includeConnectorStoreTemplate -eq 1 ]; then
    echo_color green "Copying CDO/SDO community components to $b2bStoreName1"
    cp -f quickstart-config/sm-b2b-connector/experiences/$b2bStoreName1/routes/actionPlan* $commerceConnectorTemplateDir/default/experiences/$b2bStoreName1/routes/.
    cp -f quickstart-config/sm-b2b-connector/experiences/$b2bStoreName1/views/actionPlan* $commerceConnectorTemplateDir/default/experiences/$b2bStoreName1/views/.
  fi
fi

if [ $includeCommerceConnector -eq 1 ] && [ $createConnectorStore -eq 1 ]; then
  echo_color green "Creating B2B Store"
  ./scripts/commerce/create-commerce-store.sh
fi

while [ -z "${b2bStoreId}" ]; do
  echo_color green "Subscription Management/B2B Commerce Webstore not yet created, waiting 10 seconds..."
  b2bStoreId=$(sfdx force:data:soql:query -q "SELECT Id FROM Network WHERE Name='$b2bStoreName' LIMIT 1" -r csv | tail -n +2)
  sleep 10
done

echo_color cyan "Subscription Management/B2B Commerce Webstore found with id ${b2bStoreId}"
echo_keypair b2bStoreId $b2bStoreId
echo ""

echo_color green "Waiting 10 seconds before installing B2B Commerce Video Player package"
echo ""
sleep 10

if [ $includeCommerceConnector -eq 1 ]; then
  echo_color green "Installing B2B Commerce Video Player"
  install_package $b2bVideoPlayer
fi

if [ $createTaxEngine -eq 1 ]; then
  create_tax_engine
fi

if [ $insertData -eq 1 ]; then
  insert_data
fi

defaultAccountId=$(sfdx force:data:soql:query -q "SELECT Id FROM Account WHERE Name='Apple Inc' LIMIT 1" -r csv | tail -n +2)
echo_color green "Default Customer Account ID: "
echo_keypair defaultAccountId $defaultAccountId
sleep 1

defaultContact=$(sfdx force:data:soql:query -q "SELECT Id, FirstName, LastName FROM Contact WHERE AccountId='$defaultAccountId' LIMIT 1" -r csv | tail -n +2)
defaultContactArray=($(echo $defaultContact | tr "," "\n"))
defaultContactId=${defaultContactArray[0]}
defaultContactFirstName=${defaultContactArray[1]}
defaultContactLastName=${defaultContactArray[2]}

echo_color green "Default Customer Contact ID: "
echo_keypair defaultContactId $defaultContactId
echo_color green "Default Customer Contact First Name: "
echo_keypair defaultContactFirstName $defaultContactFirstName
echo_color green "Default Customer Contact Last Name: "
echo_keypair defaultContactLastName $defaultContactLastName

sfdx force:data:record:create -s ContactPointAddress -v "AddressType='Shipping' ParentId='$defaultAccountId' ActiveFromDate='2020-01-01' ActiveToDate='2040-01-01' City='San Francisco' Country='United States' IsDefault='true' Name='Default Shipping' PostalCode='94105' State='California' Street='415 Mission Street'"
sfdx force:data:record:create -s ContactPointAddress -v "AddressType='Billing' ParentId='$defaultAccountId' ActiveFromDate='2020-01-01' ActiveToDate='2040-01-01' City='San Francisco' Country='United States' IsDefault='true' Name='Default Billing' PostalCode='94105' State='California' Street='415 Mission Street'"

echo "Making Account a Buyer Account."
buyerAccountId=$(sfdx force:data:soql:query --query \ "SELECT Id FROM BuyerAccount WHERE BuyerId = '${defaultAccountId}'" -r csv | tail -n +2)
echo_keypair buyerAccountId $buyerAccountId
if [ -z $buyerAccountId ]; then
  echo_color green "Default Account not Buyer Account - Creating"
  sfdx force:data:record:create -s BuyerAccount -v "BuyerId='$defaultAccountId' Name='Apple Buyer Account' isActive=true"
  buyerAccountId=$(sfdx force:data:soql:query --query \ "SELECT Id FROM BuyerAccount WHERE BuyerId = '${defaultAccountId}'" -r csv | tail -n +2)
  echo_keypair buyerAccountId $buyerAccountId
fi
echo "Assigning Buyer Account to Buyer Group."
buyergroupName="Default Buyer Group"
buyergroupID=$(sfdx force:data:soql:query --query \ "SELECT Id FROM BuyerGroup WHERE Name = '${buyergroupName}'" -r csv | tail -n +2)
echo_keypair buyergroupID $buyergroupID
sfdx force:data:record:create -s BuyerGroupMember -v "BuyerGroupId='$buyergroupID' BuyerId='$defaultAccountId'"
#sed -e "s/buyer@scratch.org/buyer@$mySubDomain.sm.sd/g;s/InsertFirstName/$defaultContactFirstName/g;s/InsertLastName/$defaultContactLastName/g;s/InsertContactId/$defaultContactId/g" quickstart-config/buyer-user-def.json >quickstart-config/buyer-user-def-new.json
#echo_attention "Creating Default Community Buyer Account"
#sfdx force:user:create -f quickstart-config/buyer-user-def-new.json
#fi

if [ $deployCode -eq 1 ]; then
  if [ $orgType -eq 4 ]; then
    if [ $includeCommerceConnector -eq 1 ]; then
      while [ $b2bvp -eq 0 ]; do
        check_b2b_videoplayer
        sleep 10
      done
      populate_b2b_connector_custom_metadata
    fi
    echo_color green "Pushing all project source to the scratch org"
    #sfdx force:source:beta:push -f -g --apiversion $apiversion
    sf deploy metadata -g -c -a $apiversion
  else
    if [ $includeCommunity -eq 1 ]; then
      echo_color green "Pushing sm-my-community to the org"
      deploy $communityDir
    fi

    echo_color green "Pushing sm-asset-management to the org"
    deploy $assetManagementDir

    echo_color green "Pushing sm-utility-tables to the org"
    deploy $utilDir

    echo_color green "Pushing sm-cancel-asset to the org"
    deploy $cancelDir

    echo_color green "Pushing sm-refund-credit to the org"
    deploy $refundDir

    echo_color green "Pushing sm-renewals to the org"
    deploy $renewDir

    if [ $includeCommunity -eq 1 ]; then
      echo_color green "Pushing sm-community-template to the org"
      deploy $communityTemplateDir
    fi

    if [ $includeCommerceConnector -eq 1 ]; then
      while [ $b2bvp -eq 0 ]; do
        check_b2b_videoplayer
        if [ $b2bvp -eq 0 ]; then
          sleep 10
        fi
      done
      populate_b2b_connector_custom_metadata
      echo_color green "Pushing sm-b2b-connector to the org"
      deploy $commerceConnectorDir
      if [ $includeConnectorStoreTemplate -eq 1 ]; then
        echo_color green "Pushing sm-b2b-connector-community-template to the org"
        deploy $commerceConnectorTemplateDir
      fi
    fi

    echo_color green "Pushing sm-temp to the org"
    deploy $tempDir
  fi
fi

echo_color green "Assigning SM QuickStart Permsets"
if [ $includeCommunity -eq 1 ]; then
  assign_all_permsets "${smQuickStartPermissionSets[@]}"
else
  assign_all_permsets "${smQuickStartPermissionSetsNoCommunity[@]}"
fi

if [ $installPackages -eq 1 ]; then
  echo_color green "Installing Managed Packages"
  echo_color cyan "Installing Streaming API Monitor"
  install_package $streamingAPIMonitor
fi

if [ $includeCommunity -eq 1 ]; then
  sfdx force:community:publish -n "$communityName"
fi

if [ $includeCommerceConnector -eq 1 ]; then
  if [ -n $commerceStoreId ] && [ $registerCommerceServices -eq 1 ]; then
    register_commerce_services
  fi
  echo_color green "Publishing B2B Connector Store $b2bStoreName"
  sfdx force:community:publish -n "$b2bStoreName"
  echo_color green "Building Search Index for B2B Connector Store $b2bStoreName"
  sfdx 1commerce:search:start -n "$b2bStoreName"
fi

echo_color green "All operations completed - opening configured org in google chrome"
sf env open -p /lightning/setup/SetupOneHome/home -e $username --browser chrome
