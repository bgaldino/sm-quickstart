#!/bin/sh
# This script will initialize the subscription management developer preview environment
#
defaultTaxTreatmentName="No Tax Treatment"
defaultTaxPolicyName="No Tax Policy"
defaultBillingTreatmentItemName="Default Billing Treatment Item"
defaultBillingTreatmentName="Default Billing Treatment"
defaultBillingPolicyName="Default Billing Policy"
defaultPaymentTermName="Default Payment Term"
mockTaxTreatmentName="Default Tax Treatment"
mockTaxPolicyName="Default Tax Policy"
mockTaxEngineName="MockAdapter"

function echo_attention() {
  local green='\033[0;32m'
  local no_color='\033[0m'
  echo "${green}$1${no_color}"
}

function error_and_exit() {
  echo "$1"
  exit 1
}

defaultTaxTreatmentId=$(sf data query -q "SELECT Id from TaxTreatment WHERE Name='$defaultTaxTreatmentName' AND Status='Draft' LIMIT 1" -r csv | tail -n +2)
echo_attention defaultTaxTreatmentId=$defaultTaxTreatmentId
sleep 2

defaultTaxPolicyId=$(sf data query -q "SELECT Id from TaxPolicy WHERE Name='$defaultTaxPolicyName' AND Status='Draft' LIMIT 1" -r csv | tail -n +2)
echo_attention defaultTaxPolicyId=$defaultTaxPolicyId
sleep 2

mockTaxTreatmentId=$(sf data query -q "SELECT Id from TaxTreatment WHERE Name='$mockTaxTreatmentName' AND Status='Draft' LIMIT 1" -r csv | tail -n +2)
echo_attention mockTaxTreatmentId=$mockTaxTreatmentId
sleep 2

mockTaxPolicyId=$(sf data query -q "SELECT Id from TaxPolicy WHERE Name='$mockTaxPolicyName' AND Status='Draft' LIMIT 1" -r csv | tail -n +2)
echo_attention mockTaxPolicyId=$mockTaxPolicyId
sleep 2

echo_attention "Activating $mockTaxTreatmentName"
sf data update record -s TaxTreatment -i $mockTaxTreatmentId -v "TaxPolicyId='$mockTaxPolicyId' Status=Active"
sleep 2

echo_attention "Activating $mockTaxPolicyName"
sf data update record -s TaxPolicy -i $mockTaxPolicyId -v "DefaultTaxTreatmentId='$mockTaxTreatmentId' Status=Active"
sleep 2

#echo_attention "Activating $defaultTaxTreatmentName"
#sf data update record-s TaxTreatment -i $defaultTaxTreatmentId -v "TaxPolicyId='$defaultTaxPolicyId' Status=Active"
#sleep 2

#echo_attention "Activating $defaultTaxPolicyName"
#sf data update record-s TaxPolicy -i $defaultTaxPolicyId -v "DefaultTaxTreatmentId='$defaultTaxTreatmentId' Status=Active"
#sleep 2

defaultBillingTreatmentItemId=$(sf data query -q "SELECT Id from BillingTreatmentItem WHERE Name='$defaultBillingTreatmentItemName' AND Status='Active' LIMIT 1" -r csv | tail -n +2)
echo_attention defaultBillingTreatmentItemId=$defaultBillingTreatmentItemId
sleep 2

defaultBillingTreatmentId=$(sf data query -q "SELECT Id from BillingTreatment WHERE Name='$defaultBillingTreatmentName' AND Status='Draft' LIMIT 1" -r csv | tail -n +2)
echo_attention defaultBillingTreatmentId=$defaultBillingTreatmentId
sleep 2

defaultBillingPolicyId=$(sf data query -q "SELECT Id from BillingPolicy WHERE Name='$defaultBillingPolicyName' AND Status='Draft' LIMIT 1" -r csv | tail -n +2)
echo_attention defaultBillingPolicyId=$defaultBillingPolicyId
sleep 2

defaultPaymentTermId=$(sf data query -q "SELECT Id from PaymentTerm WHERE Name='$defaultPaymentTermName' AND Status='Draft' LIMIT 1" -r csv | tail -n +2)
echo_attention defaultPaymentTermId=$defaultPaymentTermId
sleep 2

echo_attention "Activating $defaultPaymentTermName"
sf data update record -s PaymentTerm -i $defaultPaymentTermId -v "IsDefault=TRUE Status=Active"
sleep 2

echo_attention "Activating $defaultBillingTreatmentName"
sf data update record -s BillingTreatment -i $defaultBillingTreatmentId -v "BillingPolicyId='$defaultBillingPolicyId' Status=Active"
sleep 2

echo_attention "Activating $defaultBillingPolicyName"
sf data update record -s BillingPolicy -i $defaultBillingPolicyId -v "DefaultBillingTreatmentId='$defaultBillingTreatmentId' Status=Active"
sleep 2

echo_attention "Copying Default Billing Policy Id and Default Tax Policy Id to Product2.json"
sed -e "s/\"BillingPolicyId\": \"PutBillingPolicyHere\"/\"BillingPolicyId\": \"${defaultBillingPolicyId}\"/g;s/\"TaxPolicyId\": \"PutTaxPolicyHere\"/\"TaxPolicyId\": \"${mockTaxPolicyId}\"/g" data/Product2-template.json >data/Product2.json
