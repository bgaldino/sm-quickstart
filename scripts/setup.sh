#!/bin/sh

namedCredentialMasterLabel="Salesforce"
paymentGatewayAdapterName="SalesforceAdapter"
paymentGatewayProviderName="SalesforceGatewayProvider"
paymentGatewayName="MockPaymentGateway"
defaultDir="sm"

baseDir="../sm/sm-base/main"
communityDir="../sm/sm-my-community/main"
utilDir="../sm/sm-utility-tables/main"
cancelDir="../sm/sm-cancel-asset/main"
refundDir="../sm/sm-refund-credit/main"
renewDir="../sm/sm-renewals/main"
tempDir="../sm/sm-renewals/main"

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

echo_attention "Setting Org Settings"
./set-org-settings.sh || error_and_exit "Setting Org Settings Failed."

echo ""

echo_attention "Pushing Permission Sets"
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
echo_attention "Pushing sm-temp to the Org. This will take few mins."
sfdx force:source:deploy -p $tempDir --apiversion=$apiVersion

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

echo_attention "Creating Customer Account Portal Digital Experience"

sfdx force:community:create --name "customers" --templatename "Customer Account Portal" --urlpathprefix "customers" --description "Customer Portal created by Subscription Management Quickstart"

echo_attention "All operations completed"