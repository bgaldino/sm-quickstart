#!/bin/sh

namedCredentialMasterLabel="Salesforce"
paymentGatewayAdapterName="SalesforceAdapter"
paymentGatewayProviderName="SalesforceGatewayProvider"
paymentGatewayName="MockPaymentGateway"
defaultDir="../sm"

baseDir="../sm/sm-base/main"
communityDir="../sm/sm-my-community/main"
utilDir="../sm/sm-utility-tables/main"
cancelDir="../sm/sm-cancel-asset/main"
refundDir="../sm/sm-refund-credit/main"
renewDir="../sm/sm-renewals/main"
tempDir="../sm/sm-temp/main"
communityTemplateDir="../sm/sm-community-template/main"

apiVersion="55.0";

function echo_attention() {
  local green='\033[0;32m'
  local no_color='\033[0m'
  echo "${green}$1${no_color}"
}

function error_and_exit() {
   echo "$1"
   exit 1
}

username=`sfdx force:user:display | grep "Username" | sed 's/Username//g;s/^[[:space:]]*//g'`
echo_attention "Current user=$username"

instanceUrl=`sfdx force:user:display | grep "Instance Url" | sed 's/Instance Url//g;s/^[[:space:]]*//g'`
echo_attention "Current instance URL=$instanceUrl"

myDomain=`sfdx force:user:display | grep "Instance Url" | sed 's/Instance Url//g;s/^[[:space:]]*//g' | sed 's/^........//'`
echo_attention "Current myDomain=$myDomain"

mySubDomain=`sfdx force:user:display | grep "Instance Url" | sed 's/Instance Url//g;s/^[[:space:]]*//g' | sed 's/^........//' | cut -d "." -f 1`
echo_attention "Current mySubDomain=$mySubDomain"

#cat $baseDir/default/connectedApps/Postman.connectedApp-meta.xml > postman.xml
#cat $baseDir/default/connectedApps/Salesforce.connectedApp-meta.xml > salesforce.xml

sed -e "s/<callbackUrl>https:\/\/login.salesforce.com\/services\/oauth2\/callback<\/callbackUrl>/<callbackUrl>https:\/\/login.salesforce.com\/services\/oauth2\/callback\nhttps:\/\/$myDomain\/services\/oauth2\/callback<\/callbackUrl>/g" ../quickstart-config/Postman.connectedApp-meta-template.xml > postmannew.xml
sed -e "s/<callbackUrl>https:\/\/login.salesforce.com\/services\/oauth2\/callback<\/callbackUrl>/<callbackUrl>https:\/\/login.salesforce.com\/services\/oauth2\/callback\nhttps:\/\/$myDomain\/services\/oauth2\/callback\nhttps:\/\/$myDomain\/services\/authcallback\/SF<\/callbackUrl>/g" ../quickstart-config/Salesforce.connectedApp-meta-template.xml > salesforcenew.xml
sed -e "s/www.salesforce.com/$myDomain/g" ../quickstart-config/MySalesforce.namedCredential-meta-template.xml > mysalesforce.xml
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

echo_attention "Pushing sm-base to the Org. This will take few mins."
sfdx force:source:deploy -p $baseDir --apiversion=$apiVersion
echo_attention "Pushing sm-my-community to the Org. This will take few mins."
sfdx force:source:deploy -p $communityDir --apiversion=$apiVersion
echo_attention "Pushing sm-utility-tables to the Org. This will take few mins."
sfdx force:source:deploy -p $utilDir --apiversion=$apiVersion
echo_attention "Pushing sm-cancel-asset to the Org. This will take few mins."
sfdx force:source:deploy -p $cancelDir --apiversion=$apiVersion
echo_attention "Pushing sm-refund-credit to the Org. This will take few mins."
sfdx force:source:deploy -p $refundDir --apiversion=$apiVersion
echo_attention "Pushing sm-renewals to the Org. This will take few mins."
sfdx force:source:deploy -p $renewDir --apiversion=$apiVersion

echo ""

# Get Standard Pricebooks for Store and replace in json files
echo_attention "Getting Standard Pricebook for Pricebook Entries and replacing in data files"
pricebook1=`sfdx force:data:soql:query -q "SELECT Id FROM Pricebook2 WHERE Name='Standard Price Book' AND IsStandard=true LIMIT 1" -r csv |tail -n +2`
sed -e "s/\"Pricebook2Id\": \"PutStandardPricebookHere\"/\"Pricebook2Id\": \"${pricebook1}\"/g" ../data/PricebookEntry-template.json > ../data/PricebookEntry.json

# Pushing initial tax & biling data to the org
echo_attention "Pushing Tax & Billing Policy Data to the Org"
sfdx force:data:tree:import -p ../data/data-plan-1.json 

echo ""

echo_attention "Activating Tax & Billing Policies and Updating Product2 data records with Activated Policy Ids"
./pilot-activate-tax-and-billing-policies.sh || error_and_exit "Tax & Billing Policy Activation Failed"

echo ""

echo_attention "Pushing Product & Pricing Data to the Org"
sfdx force:data:tree:import -p ../data/data-plan-2.json 

echo ""

echo_attention "Pushing Default Account & Contact"
sfdx force:data:tree:import -p ../data/data-plan-3.json 

echo ""

apexClassId=`sfdx force:data:soql:query -q "SELECT Id FROM ApexClass WHERE Name='$paymentGatewayAdapterName' LIMIT 1" -r csv |tail -n +2`

# Creating Payment Gateway
echo_attention "Creating Payment Gateway"
paymentGatewayProviderId=`sfdx force:data:soql:query -q "SELECT Id FROM PaymentGatewayProvider WHERE DeveloperName='$paymentGatewayProviderName' LIMIT 1" -r csv | tail -n +2`
echo_attention paymentGatewayProviderId=$paymentGatewayProviderId
namedCredentialId=`sfdx force:data:soql:query -q "SELECT Id FROM NamedCredential WHERE MasterLabel='$namedCredentialMasterLabel' LIMIT 1" -r csv | tail -n +2`
echo_attention namedCredentialId=$namedCredentialId

echo ""

echo_attention "Creating PaymentGateway record using MerchantCredentialId=$namedCredentialId, PaymentGatewayProviderId=$paymentGatewayProviderId."

echo ""

sfdx force:data:record:create -s PaymentGateway -v "MerchantCredentialId=$namedCredentialId PaymentGatewayName=$paymentGatewayName PaymentGatewayProviderId=$paymentGatewayProviderId Status=Active"

echo_attention "Pushing sm-temp to the Org. This will take few mins."
sfdx force:source:deploy -p $tempDir --apiversion=$apiVersion

echo_attention "Creating Customer Account Portal Digital Experience"

sfdx force:community:create --name "customers" --templatename "Customer Account Portal" --urlpathprefix "customers" --description "Customer Portal created by Subscription Management Quickstart"

storeId=""

while [ -z "${storeId}" ];
do
    echo_attention "Customer Community not yet created, waiting 10 seconds..."
    storeId=$(sfdx force:data:soql:query -q "SELECT Id FROM Network WHERE Name='customers' LIMIT 1" -r csv |tail -n +2)
    sleep 10
done

echo_attention "Customer Community found with id ${storeId}"
echo ""

defaultAccountId=$(sfdx force:data:soql:query -q "SELECT Id FROM Account WHERE Name='salesforce.com' LIMIT 1" -r csv | tail -n +2)
echo $defaultAccountId
defaultContactId=$(sfdx force:data:soql:query -q "SELECT Id FROM Contact WHERE AccountId='$defaultAccountId' LIMIT 1" -r csv | tail -n +2)
echo $defaultContactId
defaultContactFirstName=$(sfdx force:data:soql:query -q "SELECT FirstName FROM Contact WHERE AccountId='$defaultAccountId' LIMIT 1" -r csv | tail -n +2)
echo $defaultContactFirstName
defaultContactLastName=$(sfdx force:data:soql:query -q "SELECT LastName FROM Contact WHERE AccountId='$defaultAccountId' LIMIT 1" -r csv | tail -n +2)
echo $defaultContactLastName

sfdx force:data:record:create -s UserRole -v "Name='CEO' DeveloperName='CEO' RollupDescription='CEO'" 
newRoleID=`sfdx force:data:soql:query --query \ "SELECT Id FROM UserRole WHERE Name = 'CEO'" -r csv |tail -n +2`
echo $newRoleID

sfdx force:data:record:update -s User -v "UserRoleId='$newRoleID'" -w "Username='$username'"

sed -e "s/buyer@scratch.org/buyer@$mySubDomain.sm.sd/g;s/InsertFirstName/$defaultContactFirstName/g;s/InsertLastName/$defaultContactLastName/g;s/InsertContactId/$defaultContactId/g" ../quickstart-config/buyer-user-def.json > ../quickstart-config/buyer-user-def-new.json


#tmpfile=$(mktemp)

pricebook1=`sfdx force:data:soql:query -q "SELECT Id FROM Pricebook2 WHERE Name='Standard Price Book' AND IsStandard=true LIMIT 1" -r csv |tail -n +2`
paymentGatewayId=`sfdx force:data:soql:query -q "Select Id from PaymentGateway Where PaymentGatewayName='MockPaymentGateway' and Status='Active'" -r csv |tail -n +2`

tmpfile=$(mktemp)
#tmpfile="test1.json"

#cat ../sm/sm-community-template/main/default/experiences/customers1/views/home.json > test.json

sed -e "s/INSERT_GATEWAY/$paymentGatewayId/g;s/INSERT_PRICEBOOK/$pricebook1/g" ../quickstart-config/home.json > $tmpfile
mv -f $tmpfile ../sm/sm-community-template/main/default/experiences/customers1/views/home.json
#rm test.json

#./setup-community.sh "customers" || error_and_exit "Community Setup Failed"
sfdx force:source:deploy -p $communityTemplateDir --apiversion=$apiVersion -g

echo_attention "Assigning SM QuickStart Permsets"
sfdx force:user:permset:assign -n SM_Cancel_Asset
sfdx force:user:permset:assign -n SM_Community
sfdx force:user:permset:assign -n SM_Renew_Asset
sfdx force:user:permset:assign -n SM_Account_Tables
sfdx force:user:permset:assign -n SM_Asset_Tables
sfdx force:user:permset:assign -n SM_Cart_Items
sfdx force:user:permset:assign -n SM_Rev_Error_Log_Table

sfdx force:community:publish -n "customers"
echo_attention "All operations completed"