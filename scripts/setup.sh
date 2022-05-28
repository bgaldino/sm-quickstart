#!/bin/sh
export SFDX_NPM_REGISTRY="http://platform-cli-registry.eng.sfdc.net:4880/"
export SFDX_S3_HOST="http://platform-cli-s3.eng.sfdc.net:9000/sfdx/media/salesforce-cli"

namedCredentialMasterLabel="Salesforce"
paymentGatewayAdapterName="SalesforceAdapter"
paymentGatewayProviderName="SalesforceGatewayProvider"
paymentGatewayName="MockPaymentGateway"
defaultDir="../sm"

baseDir="$defaultDir/sm-base/main"
communityDir="$defaultDir/sm-my-community/main"
utilDir="$defaultDir/sm-utility-tables/main"
cancelDir="$defaultDir/sm-cancel-asset/main"
refundDir="$defaultDir/sm-refund-credit/main"
renewDir="$defaultDir/sm-renewals/main"
tempDir="$defaultDir/sm-temp/main"
communityTemplateDir="$defaultDir/sm-community-template/main"

apiversion="55.0"

#change to 0 for items that should be skipped - the script will soon start to get/set these values as part of an error handling process
insertData=0
deployCode=0
createGateway=0
createCommunity=0

declare -a smPermissionSetGroups=("SubscriptionManagementBillingAdmin"
  "SubscriptionManagementBillingOperations"
  "SubscriptionManagementBuyerIntegrationUser"
  "SubscriptionManagementCollections"
  "SubscriptionManagementCreditMemoAdjustmentsOperations"
  "SubscriptionManagementPaymentAdministrator"
  "SubscriptionManagementPaymentOperations"
  "SubscriptionManagementProductAndPricingAdmin"
  "SubscriptionManagementSalesOperationsRep"
  "SubscriptionManagementTaxAdmin")

declare -a smPermissionSets=("SubscriptionManagementApplyCreditToInvoiceApi"
  "SubscriptionManagementBillingSetup"
  "SubscriptionManagementCalculateInvoiceLatePaymentRiskFeature"
  "SubscriptionManagementCalculatePricesApi"
  "SubscriptionManagementCalculateTaxesApi"
  "SubscriptionManagementCreateBillingScheduleFromOrderItemApi"
  "SubscriptionManagementCreateInvoiceFromBillingScheduleApi"
  "SubscriptionManagementCreateInvoiceFromOrderApi"
  "SubscriptionManagementCreditAnInvoiceApi"
  "SubscriptionManagementCreditMemoRecoveryApi"
  "SubscriptionManagementInitiateCancellationApi"
  "SubscriptionManagementInitiateRenewalApi"
  "SubscriptionManagementInvoiceErrorRecoveryApi"
  "SubscriptionManagementIssueStandaloneCreditApi"
  "SubscriptionManagementOrderToAssetApi"
  "SubscriptionManagementPaymentsConfiguration"
  "SubscriptionManagementPaymentsRuntimeApi"
  "SubscriptionManagementPlaceOrderApi"
  "SubscriptionManagementProductAndPriceConfigurationApi"
  "SubscriptionManagementProductImportApi"
  "SubscriptionManagementScheduledBatchInvoicingApi"
  "SubscriptionManagementScheduledBatchPaymentsApi"
  "SubscriptionManagementTaxConfiguration"
  "SubscriptionManagementUnapplyCreditToInvoiceApi"
  "SubscriptionManagementVoidPostedInvoiceApi")

declare -a smQuickStartPermissionSets=("SM_Cancel_Asset"
  "SM_Community"
  "SM_Renew_Asset"
  "SM_Account_Tables"
  "SM_Asset_Tables"
  "SM_Cart_Items"
  "SM_Rev_Error_Log_Table")

function echo_attention() {
  local green='\033[0;32m'
  local no_color='\033[0m'
  echo "${green}$1${no_color}"
}

function echo_red() {
  local red='\033[0;34m'
  local no_color='\033[0m'
  echo "${red}$1${no_color}"
}

function error_and_exit() {
  echo "$1"
  exit 1
}

function prompt_for_org_type() {
  echo_attention "What type of org are you deploying to?"
  echo "[0] Production/Developer"
  echo "[1] Scratch"
  echo "[2] Sandbox"
  echo "[3] Falcon (test1 - Internal SFDC only)"
  read -p "Please enter the org type you would like to set up > " orgType
}

function prompt_for_falcon_instance() {
  echo_attention "What type of org are you deploying to?"
  echo "[0] NA46 (main branch)"
  echo "[1] NA45 (main-2 branch)"
  read -p "Please enter the falcon instance you would like to target > " falconInstance
}

while [[ ! $orgType =~ 0|1|2|3 ]]; do
  prompt_for_org_type
done

case $orgType in
0)
  orgTypeStr="Production"
  echo_attention "You are deploying to a production/developer instance type - https://login.salesforce.com"
  ;;
1)
  orgTypeStr="Scratch"
  echo_attention "You are deploying to a Scratch org - https://test.salesforce.com"
  ;;
2)
  orgTypeStr="Sandbox"
  echo_attention "You are deploying to a Sandbox org type - https://test.salesforce.com"
  ;;
3)
  orgTypeStr="Falcon"
  echo_attention "You are requesting deployment to a falcon instance - https://login.test1.pc-rnd.salesforce.com"
  while [[ ! $falconInstance =~ 0|1 ]]; do
    prompt_for_falcon_instance
  done
  ;;
esac

function get_user_email {
  local un=$1
  userEmail=$(sfdx force:data:soql:query -q "SELECT Email from User WHERE Username='$un' LIMIT 1" -r csv | tail -n +2)
  if [ -z $userEmail ]; then
    echo_attention "Email lookup failed for username $un"
  else
    echo_attention "Email: "
    echo_red "$userEmail"
  fi
}

function get_sfdx_user_info() {
  tmpfile=$(mktemp)
  sfdx force:user:display >$tmpfile

  username=$(cat $tmpfile | grep "Username" | sed 's/Username//g;s/^[[:space:]]*//g' | awk '{$1=$1};1')
  userId=$(cat $tmpfile | grep "Id" | sed 's/Id//g;s/^[[:space:]]*//g' | head -1 | awk '{$1=$1};1')
  orgId=$(cat $tmpfile | grep "Org Id" | sed 's/Org Id//g;s/^[[:space:]]*//g' | awk '{$1=$1};1')
  instanceUrl=$(cat $tmpfile | grep "Instance Url" | sed 's/Instance Url//g;s/^[[:space:]]*//g' | awk '{$1=$1};1')
  myDomain=$(cat $tmpfile | grep "Instance Url" | sed 's/Instance Url//g;s/^[[:space:]]*//g' | sed 's/^........//' | awk '{$1=$1};1')
  mySubDomain=$(cat $tmpfile | grep "Instance Url" | sed 's/Instance Url//g;s/^[[:space:]]*//g' | sed 's/^........//' | cut -d "." -f 1 | awk '{$1=$1};1')

  echo_attention "Current Username: "
  echo_red $username
  echo_attention "Current User Id: "
  echo_red $userId
  echo_attention "Current Org Id: "
  echo_red $orgId
  echo_attention "Current Instance URL: "
  echo_red $instanceUrl
  echo_attention "Current myDomain: "
  echo_red $myDomain
  echo_attention "Current mySubDomain: "
  echo_red $mySubDomain
  rm $tmpfile
  echo ""
  if [ -z $userEmail ]; then
    get_user_email $username
  fi
}

function deploy() {
  sfdx force:source:deploy -p $1 --apiversion=$apiversion
}

function count_permset() {
  local q="SELECT COUNT(Id) FROM PermissionSetAssignment WHERE AssigneeID='$userId' AND PermissionSetId IN (SELECT Id FROM PermissionSet WHERE Name = '$1')"
  permsetCount=$(sfdx force:data:soql:query -q "$q" -r csv | tail -n +2)
}

function count_permset_licenses() {
  permsetCount=$(sfdx force:data:soql:query -q "Select COUNT(Id) from PermissionSetLicenseAssignment Where AssigneeId='$userId' and PermissionSetLicenseId IN (SELECT Id FROM PermissionSetLicense WHERE Name = '$1')" -r csv | tail -n +2)
}

function assign_permset() {
  local ps=("$@")
  for i in "${ps[@]}"; do
    count_permset "$i"
    if [ $permsetCount = "0" ]; then
      echo_attention "Assiging Permset: $i"
      sfdx force:user:permset:assign -n $i
    else
      echo_attention "Permset Assignment for Permset $i exists for $username"
    fi
  done
}

get_sfdx_user_info

sed -e "s/<callbackUrl>https:\/\/login.salesforce.com\/services\/oauth2\/callback<\/callbackUrl>/<callbackUrl>https:\/\/login.salesforce.com\/services\/oauth2\/callback\nhttps:\/\/$myDomain\/services\/oauth2\/callback<\/callbackUrl>/g" ../quickstart-config/Postman.connectedApp-meta-template.xml >postmannew.xml
sed -e "s/<callbackUrl>https:\/\/login.salesforce.com\/services\/oauth2\/callback<\/callbackUrl>/<callbackUrl>https:\/\/login.salesforce.com\/services\/oauth2\/callback\nhttps:\/\/$myDomain\/services\/oauth2\/callback\nhttps:\/\/$myDomain\/services\/authcallback\/SF<\/callbackUrl>/g" ../quickstart-config/Salesforce.connectedApp-meta-template.xml >salesforcenew.xml
sed -e "s/www.salesforce.com/$myDomain/g" ../quickstart-config/MySalesforce.namedCredential-meta-template.xml >mysalesforce.xml
mv postmannew.xml $baseDir/default/connectedApps/Postman.connectedApp-meta.xml
mv salesforcenew.xml $baseDir/default/connectedApps/Salesforce.connectedApp-meta.xml
mv mysalesforce.xml $tempDir/default/namedCredentials/MySalesforce.namedCredential-meta.xml

echo_attention "Setting Default Org Settings"
./set-org-settings.sh || error_and_exit "Setting Org Settings Failed."
echo ""

echo_attention "Assigning Permission Sets & Permission Set Groups"
assign_permset "RevSubscriptionManagementPsl"
assign_permset "${smPermissionSets[@]}"
#./assign-permsets.sh || error_and_exit "Permset Assignments Failed."
echo ""

if [ $deployCode -eq 1 ]; then
  echo_attention "Pushing sm-base to the Org. This will take few mins."
  deploy $baseDir

  echo_attention "Pushing sm-my-community to the Org. This will take few mins."
  deploy $communityDir

  echo_attention "Pushing sm-utility-tables to the Org. This will take few mins."
  deploy $utilDir

  echo_attention "Pushing sm-cancel-asset to the Org. This will take few mins."
  deploy $cancelDir

  echo_attention "Pushing sm-refund-credit to the Org. This will take few mins."
  deploy $refundDir

  echo_attention "Pushing sm-renewals to the Org. This will take few mins."
  deploy $renewDir
fi

assign_permset "SM_Base"
echo ""

# Get Standard Pricebooks for Store and replace in json files
echo_attention "Getting Standard Pricebook for Pricebook Entries and replacing in data files"
pricebook1=$(sfdx force:data:soql:query -q "SELECT Id FROM Pricebook2 WHERE Name='Standard Price Book' AND IsStandard=true LIMIT 1" -r csv | tail -n +2)
sed -e "s/\"Pricebook2Id\": \"PutStandardPricebookHere\"/\"Pricebook2Id\": \"${pricebook1}\"/g" ../data/PricebookEntry-template.json >../data/PricebookEntry.json
sleep 1

# Activate Standard Pricebook
echo_attention "Activating Standard Pricebook"
sfdx force:data:record:update -s Pricebook2 -i $pricebook1 -v "IsActive=true"
sleep 1

if [ $insertData -eq 1 ]; then
  echo_attention "Pushing Tax & Billing Policy Data to the Org"
  sfdx force:data:tree:import -p ../data/data-plan-1.json
  echo ""

  echo_attention "Activating Tax & Billing Policies and Updating Product2 data records with Activated Policy Ids"
  ./pilot-activate-tax-and-billing-policies.sh || error_and_exit "Tax & Billing Policy Activation Failed"
  echo ""

  echo_attention "Pushing Product & Pricing Data to the Org"
  # Choose to seed data with all SM Product setup completed or choose the base option to not add PSMO and PBE for use in workshops
  sfdx force:data:tree:import -p ../data/data-plan-2.json
  #sfdx force:data:tree:import -p ../data/data-plan-2-base.json
  echo ""

  echo_attention "Pushing Default Account & Contact"
  sfdx force:data:tree:import -p ../data/data-plan-3.json
  echo ""
fi

apexClassId=$(sfdx force:data:soql:query -q "SELECT Id FROM ApexClass WHERE Name='$paymentGatewayAdapterName' LIMIT 1" -r csv | tail -n +2)
sleep 1

if [ -z "$apexClassId" ]; then
  error_and_exit "No Payment Gateway Adapter Class"
else
  # Creating Payment Gateway
  echo_attention "Getting Payment Gateway Provider $paymentGatewayProviderName"
  paymentGatewayProviderId=$(sfdx force:data:soql:query -q "SELECT Id FROM PaymentGatewayProvider WHERE DeveloperName='$paymentGatewayProviderName' LIMIT 1" -r csv | tail -n +2)
  echo_attention paymentGatewayProviderId=$paymentGatewayProviderId
  sleep 1
fi

echo_attention "Getting Named Credential $namedCredentialMasterLabel"
namedCredentialId=$(sfdx force:data:soql:query -q "SELECT Id FROM NamedCredential WHERE MasterLabel='$namedCredentialMasterLabel' LIMIT 1" -r csv | tail -n +2)
echo_attention namedCredentialId=$namedCredentialId
sleep 1
echo ""

if [ $createGateway -eq 1 ]; then
  echo_attention "Creating PaymentGateway record using MerchantCredentialId=$namedCredentialId, PaymentGatewayProviderId=$paymentGatewayProviderId."
  sfdx force:data:record:create -s PaymentGateway -v "MerchantCredentialId=$namedCredentialId PaymentGatewayName=$paymentGatewayName PaymentGatewayProviderId=$paymentGatewayProviderId Status=Active"
  sleep 1
fi

echo_attention "Pushing sm-temp to the Org. This will take few mins."
sfdx force:source:deploy -p $tempDir --apiversion=$apiversion

if [ $createCommunity -eq 1 ]; then
  echo_attention "Creating Customer Account Portal Digital Experience"
  sfdx force:community:create --name "customers" --templatename "Customer Account Portal" --urlpathprefix "customers" --description "Customer Portal created by Subscription Management Quickstart"
fi

while [ -z "${storeId}" ]; do
  echo_attention "Customer Community not yet created, waiting 10 seconds..."
  storeId=$(sfdx force:data:soql:query -q "SELECT Id FROM Network WHERE Name='customers' LIMIT 1" -r csv | tail -n +2)
  sleep 10
done

echo_attention "Customer Community found with id ${storeId}"
echo ""

roles=$(sfdx force:data:soql:query --query \ "SELECT COUNT(Id) FROM UserRole WHERE Name = 'CEO'" -r csv | tail -n +2)

if [ "$roles" = "0" ]; then
  sfdx force:data:record:create -s UserRole -v "Name='CEO' DeveloperName='CEO' RollupDescription='CEO'"
  sleep 1
  newRoleID=$(sfdx force:data:soql:query --query \ "SELECT Id FROM UserRole WHERE Name = 'CEO'" -r csv | tail -n +2)
else
  echo_attention "CEO Role already exists - proceeding without creating it."
fi

echo_attention $newRoleID
sleep 1

sfdx force:data:record:update -s User -v "UserRoleId='$newRoleID'" -w "Username='$username'"
sleep 1

if [ $orgType -eq 1 ]; then
  defaultAccountId=$(sfdx force:data:soql:query -q "SELECT Id FROM Account WHERE Name='Apple Inc' LIMIT 1" -r csv | tail -n +2)
  echo_attention "Default Customer Account ID: "
  echo_red $defaultAccountId
  sleep 1

  defaultContact=$(sfdx force:data:soql:query -q "SELECT Id, FirstName, LastName FROM Contact WHERE AccountId='$defaultAccountId' LIMIT 1" -r csv | tail -n +2)
  defaultContactArray=($(echo $defaultContact | tr "," "\n"))

  defaultContactId=${defaultContactArray[0]}
  defaultContactFirstName=${defaultContactArray[1]}
  defaultContactLastName=${defaultContactArray[2]}
  #defaultContactId=$(sfdx force:data:soql:query -q "SELECT Id FROM Contact WHERE AccountId='$defaultAccountId' LIMIT 1" -r csv | tail -n +2)
  #defaultContactFirstName=$(sfdx force:data:soql:query -q "SELECT FirstName FROM Contact WHERE AccountId='$defaultAccountId' LIMIT 1" -r csv | tail -n +2)
  #defaultContactLastName=$(sfdx force:data:soql:query -q "SELECT LastName FROM Contact WHERE AccountId='$defaultAccountId' LIMIT 1" -r csv | tail -n +2)
  echo_attention "Default Customer Contact ID: "
  echo_red $defaultContactId
  echo_attention "Default Customer Contact First Name: "
  echo_red $defaultContactFirstName
  echo_attention "Default Customer Contact Last Name: "
  echo_red $defaultContactLastName

  sed -e "s/buyer@scratch.org/buyer@$mySubDomain.sm.sd/g;s/InsertFirstName/$defaultContactFirstName/g;s/InsertLastName/$defaultContactLastName/g;s/InsertContactId/$defaultContactId/g" ../quickstart-config/buyer-user-def.json >../quickstart-config/buyer-user-def-new.json
fi

#echo_attention "Pricebook1 value before query: $pricebook1"
if [ -z "$pricebook1" ]; then
  pricebook1=$(sfdx force:data:soql:query -q "SELECT Id FROM Pricebook2 WHERE Name='Standard Price Book' AND IsStandard=true LIMIT 1" -r csv | tail -n +2)
  sleep 1
fi

paymentGatewayId=$(sfdx force:data:soql:query -q "Select Id from PaymentGateway Where PaymentGatewayName='MockPaymentGateway' and Status='Active'" -r csv | tail -n +2)
sleep 1

if [ -n "$pricebook1" ] && [ -n "$paymentGatewayId" ]; then
  local tmpfile=$(mktemp)
  sed -e "s/INSERT_GATEWAY/$paymentGatewayId/g;s/INSERT_PRICEBOOK/$pricebook1/g" ../quickstart-config/home.json >$tmpfile
  mv -f $tmpfile ../sm/sm-community-template/main/default/experiences/customers1/views/home.json
fi

#./setup-community.sh "customers" || error_and_exit "Community Setup Failed"
sfdx force:source:deploy -p $communityTemplateDir --apiversion=$apiversion -g

echo_attention "Assigning SM QuickStart Permsets"
assign_permset "${smQuickStartPermissionSets[@]}"

sfdx force:community:publish -n "customers"
echo_attention "All operations completed"
