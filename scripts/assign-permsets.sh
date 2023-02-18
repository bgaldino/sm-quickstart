#!/bin/sh
apiVersion="57.0"

function echo_attention() {
  local green='\033[0;32m'
  local no_color='\033[0m'
  echo "${green}$1${no_color}"
}

declare -a permissionSetGroups=("SubscriptionManagementBillingAdmin"
  "SubscriptionManagementBillingOperations"
  "SubscriptionManagementBuyerIntegrationUser"
  "SubscriptionManagementCollections"
  "SubscriptionManagementCreditMemoAdjustmentsOperations"
  "SubscriptionManagementPaymentAdministrator"
  "SubscriptionManagementPaymentOperations"
  "SubscriptionManagementProductAndPricingAdmin"
  "SubscriptionManagementSalesOperationsRep"
  "SubscriptionManagementSalesRep"
  "SubscriptionManagementTaxAdmin")

declare -a permissionSets=(
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
  "SubscriptionManagementVoidPostedInvoiceApi")

# comment/uncomment for single/multiple usernames - executes as the current defaultusername in sfdx config (sfdx force:config:list)

sfdx org assign permsetlicense -n RevSubscriptionManagementPsl
#sfdx force user permsetlicense assign -n RevSubscriptionManagementPsl -o "user1@sm.rc.enable,user2@sm.rc.enable"

for i in "${permissionSets[@]}"; do

  sfdx org assign permset-n $i
  #sfdx force user permset assign -n "$i" -o "user1@sm.rc.enable,user2@sm.rc.enable"

done
