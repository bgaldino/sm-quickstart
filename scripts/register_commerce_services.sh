#!/bin/sh
source ./echo.sh
namedCredentialMasterLabel="Salesforce"
stripeNamedCredential="StripeAdapter"
stripeGatewayAdapterName="B2BStripeAdapter"
stripeGatewayProviderName="Stripe_Adapter"
stripePaymentGatewayName="Stripe"
inventoryInterface="B2BInventoryConnector"
inventoryExternalService="COMPUTE_INVENTORY_B2BSmConnector"
priceInterface="B2BPriceConnector"
priceExternalService="COMPUTE_PRICE_B2BSmConnector"
shipmentInterface="B2BShipmentConnector"
shipmentExternalService="COMPUTE_SHIPMENT_B2BSmConnector"
taxInterface="B2BTaxConnector"
taxExternalService="COMPUTE_TAX_B2BSmConnector"
paymentGatewayName="MockPaymentGateway"
createStripeGateway=1
b2bStoreName="b2bsm"

function register_commerce_services() {
    get_record_id() {
        sfdx data query -q "SELECT Id FROM $1 WHERE $2='$3' LIMIT 1" -r csv | tail -n +2
    }
    commerceStoreId=$(get_record_id WebStore Name $b2bStoreName)
    echo_keypair "Commerce Store Id" $commerceStoreId
    stripeApexClassId=$(get_record_id ApexClass Name $stripeGatewayAdapterName)
    echo_keypair "Stripe Apex Class Id" $stripeApexClassId
    stripePaymentGatewayProviderId=$(get_record_id PaymentGatewayProvider DeveloperName $stripeGatewayProviderName)
    echo_keypair "Stripe Payment Gateway Provider Id" $stripePaymentGatewayProviderId
    stripeNamedCredentialId=$(get_record_id NamedCredential MasterLabel $stripeNamedCredential)
    echo_keypair "Stripe Named Credential Id" $stripeNamedCredentialId

    if [ $createStripeGateway -eq 1 ]; then
        sfdx data create record -s PaymentGateway -v "MerchantCredentialId=$stripeNamedCredentialId PaymentGatewayName=$stripePaymentGatewayName PaymentGatewayProviderId=$stripePaymentGatewayProviderId Status=Active"
    fi

    declare -a apex_class_ids
    for class_name in $inventoryInterface $priceInterface $shipmentInterface $taxInterface; do
        apex_class_ids["$class_name"]=$(get_record_id ApexClass Name $class_name)
        echo_keypair "$class_name Apex Class Id" ${apex_class_ids["$class_name"]}
    done

    for service in inventory price shipment tax; do
        service_name=$(eval echo \$"${service}ExternalService")
        echo_keypair "$service_name Service Name" $service_name
        service_type="$(tr '[:lower:]' '[:upper:]' <<<${service:0:1})${service:1}"
        echo_keypair "$service_name Service Type" $service_type
        service_class=$(get_record_id ApexClass Name $(eval echo \$"${service}Interface"))
        echo_keypair "$service_name Service Class" $service_class
        service_id=$(get_record_id RegisteredExternalService DeveloperName $service_name)
        echo_keypair "$service_name Service Id" $service_id

        if [ -z "$service_id" ]; then
            #service_id=$(sfdx data create record -s RegisteredExternalService -v "DeveloperName=$service_name ExternalServiceProviderId=${apex_class_ids[$(echo ${service}Interface)]} ExternalServiceProviderType=$service_type MasterLabel=$service_name" --json | grep -Eo '"id": "([^"]*)"' | awk -F':' '{print $2}' | tr -d ' "')
            service_id=$(sfdx data create record -s RegisteredExternalService -v "DeveloperName=$service_name ExternalServiceProviderId=$service_class ExternalServiceProviderType=$service_type MasterLabel=$service_name" --json | grep -Eo '"id": "([^"]*)"' | awk -F':' '{print $2}' | tr -d ' "')
            echo_keypair "$service_name Service Id" $service_id
        fi

        sfdx data create record -s StoreIntegratedService -v "integration=$service_id StoreId=$commerceStoreId ServiceProviderType=$service_type"
    done

    serviceMappingId=$(sfdx data query -q "SELECT Id FROM StoreIntegratedService WHERE StoreId='$commerceStoreId' AND ServiceProviderType='Payment' LIMIT 1" -r csv | tail -n +2)
    echo_keypair "Payment Service Mapping Id" $serviceMappingId

    if [ ! -z $serviceMappingId ]; then
        sfdx data delete record -s StoreIntegratedService -i $serviceMappingId
    fi

    paymentGatewayId=$(get_record_id PaymentGateway PaymentGatewayName $paymentGatewayName)
    echo_keypair "Payment Gateway Id" $paymentGatewayId
    sfdx data create record -s StoreIntegratedService -v "Integration=$paymentGatewayId StoreId=$commerceStoreId ServiceProviderType=Payment"

}
register_commerce_services