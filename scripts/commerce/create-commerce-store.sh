#!/bin/sh
apiVersion="57.0"

function echo_attention() {
  local green='\033[0;32m'
  local no_color='\033[0m'
  echo "${green}$1${no_color}"
}

sfdx force:community:create --name "B2BSmConnector" --templatename "B2B Commerce (LWR)" --urlpathprefix "B2BSmConnector" --description "B2B Commerce (LWR) created by Subscription Management Quickstart"

#sfdx force:data:record:create -s RegisteredExternalService -v "DeveloperName=COMPUTE_INVENTORY_B2BSmConnector ExternalServiceProviderId=01pB0000006fe2R ExternalServiceProviderType=Inventory MasterLabel=COMPUTE_INVENTORY_B2BSmConnector"
#sfdx force:data:record:create -s StoreIntegratedService -v "integration=1uuB0000000TNxmIAG StoreId=0ZEB0000000U4VqOAK ServiceProviderType=Inventory"

#sfdx force:data:record:create -s RegisteredExternalService -v "DeveloperName=COMPUTE_PRICE_B2BSmConnector ExternalServiceProviderId=01pB0000006fe2f ExternalServiceProviderType=Price MasterLabel=COMPUTE_PRICE_B2BSmConnector"
#sfdx force:data:record:create -s StoreIntegratedService -v "integration=1uuB0000000TNxrIAG StoreId=0ZEB0000000U4VqOAK ServiceProviderType=Price"

#sfdx force:data:record:create -s RegisteredExternalService -v "DeveloperName=COMPUTE_SHIPMENT_B2BSmConnector ExternalServiceProviderId=01pB0000006fe2r ExternalServiceProviderType=Shipment MasterLabel=COMPUTE_SHIPMENT_B2BSmConnector"
#sfdx force:data:record:create -s StoreIntegratedService -v "integration=1uuB0000000TNxwIAG StoreId=0ZEB0000000U4VqOAK ServiceProviderType=Shipment"

#sfdx force:data:record:create -s RegisteredExternalService -v "DeveloperName=COMPUTE_TAX_B2BSmConnector ExternalServiceProviderId=01pB0000006fe3F ExternalServiceProviderType=Tax MasterLabel=COMPUTE_TAX_B2BSmConnector"
#sfdx force:data:record:create -s StoreIntegratedService -v "integration=1uuB0000000TNy1IAG StoreId=0ZEB0000000U4VqOAK ServiceProviderType=Tax"
