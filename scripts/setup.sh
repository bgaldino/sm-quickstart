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
insertData=1
deployCode=1
createGateway=1
createCommunity=1

function echo_attention() {
  local green='\033[0;32m'
  local no_color='\033[0m'
  echo "${green}$1${no_color}"
}

function error_and_exit() {
  echo "$1"
  exit 1
}

function prompt_for_org_type() {
  echo_attention "What type of org are you deploying to?"
  echo "[0] Production"
  echo "[1] Scratch"
  echo "[2] Sandbox"
  echo "[3] Falcon (test1 - Internal SFDC only)"
  read -p "Please enter the org type you would like to set up > " orgType
}

function prompt_for_falcon_instance() {
  echo_attention "What type of org are you deploying to?"
  echo "[0] NA46"
  echo "[1] NA45"
  read -p "Please enter the falcon instance you would like to target > " falconInstance
}

while [[ ! $orgType =~ 0|1|2|3 ]]; do
  prompt_for_org_type
done

case $orgType in
0)
  orgTypeStr="Production"
  echo_attention "You are deploying to a production/developer instance type"
  ;;
1)
  orgTypeStr="Scratch"
  echo_attention "You are deploying to a scratch org"
  ;;
2)
  orgTypeStr="Sandbox"
  echo_attention "You are deploying to a sandbox org"
  ;;
3)
  orgTypeStr="Falcon"
  echo_attention "You are requesting deployment to a falcon instance"
  while [[ ! $falconInstance =~ 0|1 ]]; do
    prompt_for_falcon_instance
  done
  ;;
esac

function get_sfdx_user_info() {
  username=$(sfdx force:user:display | grep "Username" | sed 's/Username//g;s/^[[:space:]]*//g')
  echo ""
  echo_attention "Current user=$username"
  echo ""
  userId=$(sfdx force:user:display | grep "Id" | sed 's/Id//g;s/^[[:space:]]*//g' | head -1)
  echo ""
  echo_attention "Current user ID=$userId"
  echo ""
  orgId=$(sfdx force:user:display | grep "Org Id" | sed 's/Org Id//g;s/^[[:space:]]*//g')
  echo ""
  echo_attention "Current org ID=$orgId"
  echo ""
  instanceUrl=$(sfdx force:user:display | grep "Instance Url" | sed 's/Instance Url//g;s/^[[:space:]]*//g')
  echo ""
  echo_attention "Current instance URL=$instanceUrl"
  echo ""
  myDomain=$(sfdx force:user:display | grep "Instance Url" | sed 's/Instance Url//g;s/^[[:space:]]*//g' | sed 's/^........//')
  echo ""
  echo_attention "Current myDomain=$myDomain"
  echo ""
  mySubDomain=$(sfdx force:user:display | grep "Instance Url" | sed 's/Instance Url//g;s/^[[:space:]]*//g' | sed 's/^........//' | cut -d "." -f 1)
  echo ""
  echo_attention "Current mySubDomain=$mySubDomain"
  echo ""
}

function count_permsets() {
  permsetCount=$(sfdx force:data:soql:query -q "Select COUNT(Id) from PermissionSetAssignment Where AssigneeId='$userId' and PermissionSetId IN (SELECT Id FROM PermissionSet WHERE Name = '$1')" -r csv | tail -n +2)
}

function assign_permset {
  local permsetName=$1
  count_permsets $1
  if [ $permsetCount = "0" ]; then
    echo_attention "Assiging Permset: $1"
    sfdx force:user:permset:assign -n $1
  fi
}

get_sfdx_user_info

sed -e "s/<callbackUrl>https:\/\/login.salesforce.com\/services\/oauth2\/callback<\/callbackUrl>/<callbackUrl>https:\/\/login.salesforce.com\/services\/oauth2\/callback\nhttps:\/\/$myDomain\/services\/oauth2\/callback<\/callbackUrl>/g" ../quickstart-config/Postman.connectedApp-meta-template.xml >postmannew.xml
sed -e "s/<callbackUrl>https:\/\/login.salesforce.com\/services\/oauth2\/callback<\/callbackUrl>/<callbackUrl>https:\/\/login.salesforce.com\/services\/oauth2\/callback\nhttps:\/\/$myDomain\/services\/oauth2\/callback\nhttps:\/\/$myDomain\/services\/authcallback\/SF<\/callbackUrl>/g" ../quickstart-config/Salesforce.connectedApp-meta-template.xml >salesforcenew.xml
sed -e "s/www.salesforce.com/$myDomain/g" ../quickstart-config/MySalesforce.namedCredential-meta-template.xml >mysalesforce.xml
mv postmannew.xml $baseDir/default/connectedApps/Postman.connectedApp-meta.xml
mv salesforcenew.xml $baseDir/default/connectedApps/Salesforce.connectedApp-meta.xml
mv mysalesforce.xml $tempDir/default/namedCredentials/MySalesforce.namedCredential-meta.xml
#rm postman.xml
#rm salesforce.xml

echo_attention "Setting Default Org Settings"
./set-org-settings.sh || error_and_exit "Setting Org Settings Failed."

echo ""

echo_attention "Assigning Permission Sets & Permission Set Groups"
./assign-permsets.sh || error_and_exit "Permset Assignments Failed."

echo ""

if [ $deployCode -eq 1 ]; then
  echo_attention "Pushing sm-base to the Org. This will take few mins."
  sfdx force:source:deploy -p $baseDir --apiversion=$apiversion

  echo_attention "Pushing sm-my-community to the Org. This will take few mins."
  sfdx force:source:deploy -p $communityDir --apiversion=$apiversion

  echo_attention "Pushing sm-utility-tables to the Org. This will take few mins."
  sfdx force:source:deploy -p $utilDir --apiversion=$apiversion

  echo_attention "Pushing sm-cancel-asset to the Org. This will take few mins."
  sfdx force:source:deploy -p $cancelDir --apiversion=$apiversion

  echo_attention "Pushing sm-refund-credit to the Org. This will take few mins."
  sfdx force:source:deploy -p $refundDir --apiversion=$apiversion

  echo_attention "Pushing sm-renewals to the Org. This will take few mins."
  sfdx force:source:deploy -p $renewDir --apiversion=$apiversion
fi

assign_permset "SM_Base"

echo ""

# Get Standard Pricebooks for Store and replace in json files
echo_attention "Getting Standard Pricebook for Pricebook Entries and replacing in data files"
pricebook1=$(sfdx force:data:soql:query -q "SELECT Id FROM Pricebook2 WHERE Name='Standard Price Book' AND IsStandard=true LIMIT 1" -r csv | tail -n +2)
sed -e "s/\"Pricebook2Id\": \"PutStandardPricebookHere\"/\"Pricebook2Id\": \"${pricebook1}\"/g" ../data/PricebookEntry-template.json >../data/PricebookEntry.json
sleep 2

# Activate Standard Pricebook
echo_attention "Activating Standard Pricebook"
sfdx force:data:record:update -s Pricebook2 -i $pricebook1 -v "IsActive=true"
sleep 2

if [ $insertData -eq 1 ]; then
  # Pushing initial tax & biling data to the org
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
sleep 2

if [ -z "$apexClassId" ]; then
  error_and_exit "No Payment Gateway Adapter Class"
else
  # Creating Payment Gateway
  echo_attention "Getting Payment Gateway Provider $paymentGatewayProviderName"
  paymentGatewayProviderId=$(sfdx force:data:soql:query -q "SELECT Id FROM PaymentGatewayProvider WHERE DeveloperName='$paymentGatewayProviderName' LIMIT 1" -r csv | tail -n +2)
  echo_attention paymentGatewayProviderId=$paymentGatewayProviderId
  sleep 2
fi

echo_attention "Getting Named Credential $namedCredentialMasterLabel"
namedCredentialId=$(sfdx force:data:soql:query -q "SELECT Id FROM NamedCredential WHERE MasterLabel='$namedCredentialMasterLabel' LIMIT 1" -r csv | tail -n +2)
echo_attention namedCredentialId=$namedCredentialId
sleep 2
echo ""

if [ $createGateway -eq 1 ]; then
  echo_attention "Creating PaymentGateway record using MerchantCredentialId=$namedCredentialId, PaymentGatewayProviderId=$paymentGatewayProviderId."
  sfdx force:data:record:create -s PaymentGateway -v "MerchantCredentialId=$namedCredentialId PaymentGatewayName=$paymentGatewayName PaymentGatewayProviderId=$paymentGatewayProviderId Status=Active"
  sleep 2
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
  sleep 2
  newRoleID=$(sfdx force:data:soql:query --query \ "SELECT Id FROM UserRole WHERE Name = 'CEO'" -r csv | tail -n +2)
else
  echo_attention "CEO Role already exists - proceeding without creating it."
fi

echo_attention $newRoleID
sleep 2

sfdx force:data:record:update -s User -v "UserRoleId='$newRoleID'" -w "Username='$username'"
sleep 2

if [ $orgType -eq 1 ]; then
  defaultAccountId=$(sfdx force:data:soql:query -q "SELECT Id FROM Account WHERE Name='Apple Inc' LIMIT 1" -r csv | tail -n +2)
  echo_attention $defaultAccountId
  sleep 2

  defaultContactId=$(sfdx force:data:soql:query -q "SELECT Id FROM Contact WHERE AccountId='$defaultAccountId' LIMIT 1" -r csv | tail -n +2)
  echo_attention $defaultContactId
  sleep 2

  defaultContactFirstName=$(sfdx force:data:soql:query -q "SELECT FirstName FROM Contact WHERE AccountId='$defaultAccountId' LIMIT 1" -r csv | tail -n +2)
  echo_attention $defaultContactFirstName
  sleep 2

  defaultContactLastName=$(sfdx force:data:soql:query -q "SELECT LastName FROM Contact WHERE AccountId='$defaultAccountId' LIMIT 1" -r csv | tail -n +2)
  echo_attention $defaultContactLastName
  sleep 2

  sed -e "s/buyer@scratch.org/buyer@$mySubDomain.sm.sd/g;s/InsertFirstName/$defaultContactFirstName/g;s/InsertLastName/$defaultContactLastName/g;s/InsertContactId/$defaultContactId/g" ../quickstart-config/buyer-user-def.json >../quickstart-config/buyer-user-def-new.json
fi

echo_attention "Pricebook1 value before query: $pricebook1"
if [ -z "$pricebook1" ]; then
  pricebook1=$(sfdx force:data:soql:query -q "SELECT Id FROM Pricebook2 WHERE Name='Standard Price Book' AND IsStandard=true LIMIT 1" -r csv | tail -n +2)
  sleep 2
fi

paymentGatewayId=$(sfdx force:data:soql:query -q "Select Id from PaymentGateway Where PaymentGatewayName='MockPaymentGateway' and Status='Active'" -r csv | tail -n +2)
sleep 2

if [ -n "$pricebook1" ] && [ -n "$paymentGatewayId" ]; then
  tmpfile=$(mktemp)
  sed -e "s/INSERT_GATEWAY/$paymentGatewayId/g;s/INSERT_PRICEBOOK/$pricebook1/g" ../quickstart-config/home.json >$tmpfile
  mv -f $tmpfile ../sm/sm-community-template/main/default/experiences/customers1/views/home.json
fi

#./setup-community.sh "customers" || error_and_exit "Community Setup Failed"
sfdx force:source:deploy -p $communityTemplateDir --apiversion=$apiversion -g

echo_attention "Assigning SM QuickStart Permsets"

assign_permset "SM_Cancel_Asset"
assign_permset "SM_Community"
assign_permset "SM_Renew_Asset"
assign_permset "SM_Account_Tables"
assign_permset "SM_Asset_Tables"
assign_permset "SM_Cart_Items"
assign_permset "SM_Rev_Error_Log_Table"

sfdx force:community:publish -n "customers"
echo_attention "All operations completed"
