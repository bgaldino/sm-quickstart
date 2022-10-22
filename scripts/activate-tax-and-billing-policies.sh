#!/bin/sh
# This script will initialize the subscription management developer preview environment
#
defaultTaxTreatmentName="No Tax Treatment"
defaultTaxPolicyName="No Tax Policy"
defaultBillingTreatmentItemName="Default Billing Treatment Item"
defaultBillingTreatmentName="Default Billing Treatment"
defaultBillingPolicyName="Default Billing Policy"
defaultPaymentTermName="Default Payment Term"

function echo_attention() {
  local green='\033[0;32m'
  local no_color='\033[0m'
  echo "${green}$1${no_color}"
}

function error_and_exit() {
  echo "$1"
  exit 1
}

defaultTaxTreatmentId=$(sfdx force:data:soql:query -q "SELECT Id from TaxTreatment WHERE Name='$defaultTaxTreatmentName' AND Status='Draft' LIMIT 1" -r csv | tail -n +2)
echo_attention defaultTaxTreatmentId=$defaultTaxTreatmentId
sleep 2

defaultTaxPolicyId=$(sfdx force:data:soql:query -q "SELECT Id from TaxPolicy WHERE Name='$defaultTaxPolicyName' AND Status='Draft' LIMIT 1" -r csv | tail -n +2)
echo_attention defaultTaxPolicyId=$defaultTaxPolicyId
sleep 2

echo_attention "Activating $defaultTaxTreatmentName"
sfdx force:data:record:update -s TaxTreatment -i $defaultTaxTreatmentId -v "TaxPolicyId='$defaultTaxPolicyId' Status=Active"
sleep 2

echo_attention "Activating $defaultTaxPolicyName"
sfdx force:data:record:update -s TaxPolicy -i $defaultTaxPolicyId -v "DefaultTaxTreatmentId='$defaultTaxTreatmentId' Status=Active"
sleep 2

defaultBillingTreatmentItemId=$(sfdx force:data:soql:query -q "SELECT Id from BillingTreatmentItem WHERE Name='$defaultBillingTreatmentItemName' AND Status='Active' LIMIT 1" -r csv | tail -n +2)
echo_attention defaultBillingTreatmentItemId=$defaultBillingTreatmentItemId
sleep 2

defaultBillingTreatmentId=$(sfdx force:data:soql:query -q "SELECT Id from BillingTreatment WHERE Name='$defaultBillingTreatmentName' AND Status='Draft' LIMIT 1" -r csv | tail -n +2)
echo_attention defaultBillingTreatmentId=$defaultBillingTreatmentId
sleep 2

defaultBillingPolicyId=$(sfdx force:data:soql:query -q "SELECT Id from BillingPolicy WHERE Name='$defaultBillingPolicyName' AND Status='Draft' LIMIT 1" -r csv | tail -n +2)
echo_attention defaultBillingPolicyId=$defaultBillingPolicyId
sleep 2

defaultPaymentTermId=$(sfdx force:data:soql:query -q "SELECT Id from PaymentTerm WHERE Name='$defaultPaymentTermName' AND Status='Draft' LIMIT 1" -r csv | tail -n +2)
echo_attention defaultPaymentTermId=$defaultPaymentTermId
sleep 2

echo_attention "Activating $defaultPaymentTermName"
sfdx force:data:record:update -s PaymentTerm -i $defaultPaymentTermId -v "IsDefault=TRUE Status=Active"
sleep 2

echo_attention "Activating $defaultBillingTreatmentName"
sfdx force:data:record:update -s BillingTreatment -i $defaultBillingTreatmentId -v "BillingPolicyId='$defaultBillingPolicyId' Status=Active"
sleep 2

echo_attention "Activating $defaultBillingPolicyName"
sfdx force:data:record:update -s BillingPolicy -i $defaultBillingPolicyId -v "DefaultBillingTreatmentId='$defaultBillingTreatmentId' Status=Active"
sleep 2

echo_attention "Copying Default Billing Policy Id and Default Tax Policy Id to Product1.json"
sed -e "s/\"BillingPolicyId\": \"PutBillingPolicyHere\"/\"BillingPolicyId\": \"${defaultBillingPolicyId}\"/g;s/\"TaxPolicyId\": \"PutTaxPolicyHere\"/\"TaxPolicyId\": \"${defaultTaxPolicyId}\"/g" data/Product2-template.json > data/Product2.json
