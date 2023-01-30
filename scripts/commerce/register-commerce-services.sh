#!/bin/sh

#Sample B2B Commerce Storefront Name"
b2bStoreName="B2BSmConnector"
b2bStoreName1="B2BSmConnector1"

#mock tax provider
taxProviderClassName="MockAdapter"

#stripe payment gateway
stripeGatewayAdapterName="StripeAdapter"
stripeGatewayProviderName="StripePaymentGatewayProvider"
stripePaymentGatewayName="Stripe"

#named credential for example customer community storefront to access SM APIs
stripeNamedCredential="StripeAdapter"

#commerce interfaces
inventoryInterface="B2BInventoryConnector"
inventoryExternalService="COMPUTE_INVENTORY_B2BSmConnector"
priceInterface="B2BPriceConnector"
priceExternalService="COMPUTE_PRICE_B2BSmConnector"
shipmentInterface="B2BShipmentConnector"
shipmentExternalService="COMPUTE_SHIPMENT_B2BSmConnector"
taxInterface="B2BTaxConnector"
taxExternalService="COMPUTE_TAX_B2BSmConnector"

function echo_attention() {
    local green='\033[0;32m'
    local no_color='\033[0m'
    echo "${green}$1${no_color}"
}

function echo_blue() {
    local blue='\033[0;34m'
    local no_color='\033[0m'
    echo "${blue}$1${no_color}"
}

function error_and_exit() {
    echo "$1"
    exit 1
}

commerceStoreId=$(sf data query -q "SELECT Id FROM WebStore WHERE Name='$b2bStoreName' LIMIT 1" -r csv | tail -n +2)

if [ -n $commerceStoreId ]; then
    stripeApexClassId=$(sf data query -q "SELECT Id FROM ApexClass WHERE Name='$stripeGatewayAdapterName' LIMIT 1" -r csv | tail -n +2)
    sleep 1

    if [ -z "$stripeApexClassId" ]; then
        error_and_exit "No Stripe Payment Gateway Adapter Class"
    else
        # Creating Payment Gateway
        echo_attention "Getting Stripe Payment Gateway Provider $stripeGatewayProviderName"
        stripePaymentGatewayProviderId=$(sf data query -q "SELECT Id FROM PaymentGatewayProvider WHERE DeveloperName='$stripeGatewayProviderName' LIMIT 1" -r csv | tail -n +2)
        echo_attention stripePaymentGatewayProviderId=$stripePaymentGatewayProviderId
        sleep 1
    fi

    echo_attention "Getting Stripe Named Credential $stripeNamedCredential"
    stripeNamedCredentialId=$(sf data query -q "SELECT Id FROM NamedCredential WHERE MasterLabel='$stripeNamedCredential' LIMIT 1" -r csv | tail -n +2)
    echo_attention stripeNamedCredentialId=$stripeNamedCredentialId
    sleep 1
    echo ""

    if [ $createStripeGateway -eq 1 ]; then
        echo_attention "Creating PaymentGateway record using MerchantCredentialId=$stripeNamedCredentialId, PaymentGatewayProviderId=$stripePaymentGatewayProviderId."
        sf data create record -s PaymentGateway -v "MerchantCredentialId=$stripeNamedCredentialId PaymentGatewayName=$stripeGatewayName PaymentGatewayProviderId=$stripePaymentGatewayProviderId Status=Active"
        sleep 1
    fi
    echo_attention "Getting Id for ApexClass $inventoryInterface"
    inventoryInterfaceId=$(sf data query -q "SELECT Id FROM ApexClass WHERE Name='$inventoryInterface' LIMIT 1" -r csv | tail -n +2)
    echo_attention "Getting Id for ApexClass $priceInterface"
    priceInterfaceId=$(sf data query -q "SELECT Id FROM ApexClass WHERE Name='$priceInterface' LIMIT 1" -r csv | tail -n +2)
    echo_attention "Getting Id for ApexClass $shipmentInterface"
    shipmentInterfaceId=$(sf data query -q "SELECT Id FROM ApexClass WHERE Name='$shipmentInterface' LIMIT 1" -r csv | tail -n +2)
    echo_attention "Getting Id for ApexClass $taxInterface"
    taxInterfaceId=$(sf data query -q "SELECT Id FROM ApexClass WHERE Name='$taxInterface' LIMIT 1" -r csv | tail -n +2)

    echo_attention "Registering External Service $inventoryExternalService"
    sf data create record -s RegisteredExternalService -v "DeveloperName=$inventoryExternalService ExternalServiceProviderId=$inventoryInterfaceId ExternalServiceProviderType=Inventory MasterLabel=$inventoryExternalService"
    echo_attention "Registering External Service $priceExternalService"
    sf data create record -s RegisteredExternalService -v "DeveloperName=$priceExternalService ExternalServiceProviderId=$priceInterfaceId ExternalServiceProviderType=Price MasterLabel=$priceExternalService"
    echo_attention "Registering External Service $shipmentExternalService"
    sf data create record -s RegisteredExternalService -v "DeveloperName=$shipmentExternalService ExternalServiceProviderId=$shipmentInterfaceId ExternalServiceProviderType=Shipment MasterLabel=$shipmentExternalService"
    echo_attention "Registering External Service $taxExternalService"
    sf data create record -s RegisteredExternalService -v "DeveloperName=$taxExternalService ExternalServiceProviderId=$taxInterfaceId ExternalServiceProviderType=Tax MasterLabel=$taxExternalService"

    inventoryRegisteredService=$(sf data query -q "SELECT Id FROM RegisteredExternalService WHERE DeveloperName='$inventoryExternalService' LIMIT 1" -r csv | tail -n +2)
    priceRegisteredService=$(sf data query -q "SELECT Id FROM RegisteredExternalService WHERE DeveloperName='$priceExternalService' LIMIT 1" -r csv | tail -n +2)
    shipmentRegisteredService=$(sf data query -q "SELECT Id FROM RegisteredExternalService WHERE DeveloperName='$shipmentExternalService' LIMIT 1" -r csv | tail -n +2)
    taxRegisteredService=$(sf data query -q "SELECT Id FROM RegisteredExternalService WHERE DeveloperName='$taxExternalService' LIMIT 1" -r csv | tail -n +2)

    echo_attention "Creating StoreIntegratedService $inventoryExternalService"
    sf data create record -s StoreIntegratedService -v "integration=$inventoryRegisteredService StoreId=$commerceStoreId ServiceProviderType=Inventory"
    echo_attention "Creating StoreIntegratedService $priceExternalService"
    sf data create record -s StoreIntegratedService -v "integration=$priceRegisteredService StoreId=$commerceStoreId ServiceProviderType=Price"
    echo_attention "Creating StoreIntegratedService $shipmentExternalService"
    sf data create record -s StoreIntegratedService -v "integration=$shipmentRegisteredService StoreId=$commerceStoreId ServiceProviderType=Shipment"
    echo_attention "Creating StoreIntegratedService $taxExternalService"
    sf data create record -s StoreIntegratedService -v "integration=$taxRegisteredService StoreId=$commerceStoreId ServiceProviderType=Tax"

    serviceMappingId=$(sf data query -q "SELECT Id FROM StoreIntegratedService WHERE StoreId='$commerceStoreId' AND ServiceProviderType='Payment' LIMIT 1" -r csv | tail -n +2)
    if [ ! -z $serviceMappingId ]; then
        echo "StoreMapping already exists.  Deleting old mapping."
        sf data delete record -s StoreIntegratedService -i $serviceMappingId
    fi
    stripePaymentGatewayId=$(sf data query -q "SELECT Id FROM PaymentGateway WHERE PaymentGatewayName='$stripePaymentGatewayName' LIMIT 1" -r csv | tail -n +2)
    echo_attention "Creating StoreIntegratedService using the $b2bStoreName store and Integration=$stripePaymentGatewayId (PaymentGatewayId)"
    sf data create record -s StoreIntegratedService -v "Integration=$stripePaymentGatewayId StoreId=$commerceStoreId ServiceProviderType=Payment"
fi
