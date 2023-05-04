#!/bin/bash
# shellcheck shell=bash

# default api version to run sfdx commands - updates to latest version during setup
export API_VERSION="57.0"
export SFDX_RC_VERSION=7.195

export SDO_ID="aa74d1a8-5884-1c5f-082f-8bfbee691add"
export CDO_ID="aa74d1a8-5884-1c5f-082f-8bfbee691add"
export MFGIDO_ID="f1862ad0-58f1-dddf-b1a8-08e4f67db4a5"
export RCIDO_ID="3cf4e7fa-6b41-a4a0-727e-d3f6bd9d7333"

# module directories
export DEFAULT_DIR="sm"
# base metadata for all other modules
export BASE_DIR="$DEFAULT_DIR/sm-base"
# forked from https://github.com/SalesforceLabs/RevenueCloudCodeSamples
export ASSET_MANAGEMENT_DIR="$DEFAULT_DIR/sm-asset-management/main"
# forked from https://github.com/samcheck/sm-my-community
export COMMUNITY_DIR="$DEFAULT_DIR/sm-my-community/main"
# forked from https://github.com/samcheck/sm-utility-tables
export UTIL_DIR="$DEFAULT_DIR/sm-utility-tables/main"
# forked from https://github.com/samcheck/sm-cancel-asset
export CANCEL_DIR="$DEFAULT_DIR/sm-cancel-asset/main"
# forked from https://github.com/samcheck/sm-refund-credit
export REFUND_DIR="$DEFAULT_DIR/sm-refund-credit/main"
# forked from https://github.com/samcheck/sm-renewals
export RENEW_DIR="$DEFAULT_DIR/sm-renewals/main"
# temp directory to be merged into one or more new modules - mainly layouts, pages, etc
export SM_TEMP_DIR="$DEFAULT_DIR/sm-temp/main"
# connected apps only - to be packaged separately
export SM_CONNECTED_APPS_DIR="$DEFAULT_DIR/sm-connected-apps/main"

export QS_CONFIG_B2B_DIR="quickstart-config/sm-b2b-connector"
export QS_CONFIG_SM_DIR="quickstart-config/sm-community-template"

export DEFAULT_ACCOUNT_NAME="SFDC"
export STANDARD_PRICEBOOK_NAME="Standard Price Book"
export CANDIDATE_PRICEBOOK_NAME="Quickstart Subscription Management Price Book"
export COMMERCE_PRICEBOOK_NAME="Quickstart B2B Commerce Price Book"

export DEFAULT_ONE_TIME_PRODUCT_NAME="One-Time Product"
export DEFAULT_MONTHLY_EVERGREEN_PRODUCT_NAME="Monthly Evergreen"
export DEFAULT_MONTHLY_TERMED_PRODUCT_NAME="Monthly Term"
export DEFAULT_ANNUAL_EVERGREEN_PRODUCT_NAME="Annual Evergreen"
export DEFAULT_ANNUAL_TERMED_PRODUCT_NAME="Annual Term"
export DEFAULT_MULTIPLE_PSM_PRODUCT_NAME="Monthly Subscription"
export DEFAULT_PRORATION_POLICY_NAME="Quickstart Default Proration Policy"

# Sample Experience Cloud Customer Community Storefront Name
export COMMUNITY_NAME="sm"
export COMMUNITY_TEMPLATE_NAME="Customer Account Portal"
# forked from https://github.com/samcheck/sm-community-template
export COMMUNITY_TEMPLATE_DIR="$DEFAULT_DIR/sm-community-template/main"

# named credential for example customer community storefront to access SM APIs
export NAMED_CREDENTIAL_MASTER_LABEL="Salesforce"
export NAMED_CREDENTIAL_SM="RC_SubscriptionManagement"
export NAMED_CREDENTIAL_SMB2B="RC_SMB2B"

# connected app for example customer community storefront to access SM APIs
export CONNECTED_APP_NAME_POSTMAN="RC_Postman"
export CONNECTED_APP_NAME_SALESFORCE="RC_Salesforce"

# mock payment gateway
export PAYMENT_GATEWAY_ADAPTER_NAME="SalesforceGatewayAdapter"
export PAYMENT_GATEWAY_PROVIDER_NAME="SalesforceGatewayProvider"
export PAYMENT_GATEWAY_NAME="MockPaymentGateway"



# mock tax provider
export TAX_PROVIDER_CLASS_NAME="MockAdapter"

#Default Tax & Billing Policies
export DEFAULT_MOCK_TAX_ENGINE_NAME="MockAdapter"
export DEFAULT_MOCK_TAX_POLICY_NAME="Quickstart Default Tax Policy"
export DEFAULT_MOCK_TAX_TREATMENT_NAME="Quickstart Default Tax Treatment"
export DEFAULT_NO_TAX_POLICY_NAME="Quickstart No Tax Policy"
export DEFAULT_NO_TAX_TREATMENT_NAME="Quickstart No Tax Treatment"
export DEFAULT_BILLING_POLICY_NAME="Quickstart Default Billing Policy"
export DEFAULT_BILLING_TREATMENT_NAME="Quickstart Default Billing Treatment"
export DEFAULT_BILLING_TREATMENT_ITEM_NAME="Quickstart Default Billing Treatment Item"
export DEFAULT_PAYMENT_TERM_NAME="Quickstart Default Payment Term"

# Sample B2B Commerce Storefront Name"
export B2B_STORE_NAME="b2bsm"
export B2B_CATEGORY_NAME="Software"
export BUYER_GROUP_NAME="Quickstart Buyer Group"

# forked from https://github.com/bgaldino/sm-b2b-connector
export COMMERCE_CONNECTOR_DIR="$DEFAULT_DIR/sm-b2b-connector"
export COMMERCE_CONNECTOR_LIBS_DIR="$COMMERCE_CONNECTOR_DIR/libs"
export COMMERCE_CONNECTOR_MAIN_DIR="$COMMERCE_CONNECTOR_DIR/main"
export COMMERCE_CONNECTOR_TEMPLATE_DIR="$DEFAULT_DIR/sm-b2b-connector-community-template/main"
export COMMERCE_CONNECTOR_TEMP_DIR="$DEFAULT_DIR/sm-b2b-connector-temp/main"
export B2B_TEMPLATE_NAME="B2B Commerce"
export B2B_LWR_TEMPLATE_NAME="B2B Commerce (LWR)"
export B2B_AURA_TEMPLATE_NAME="B2B Commerce (Aura)"
export B2B_STATICRESOURCES_PATH="$COMMERCE_CONNECTOR_MAIN_DIR/default/staticresources"

# stripe payment gateway
export STRIPE_GATEWAY_ADAPTER_NAME="B2BStripeAdapter"
export STRIPE_GATEWAY_PROVIDER_NAME="Stripe_Adapter"
export STRIPE_PAYMENT_GATEWAY_NAME="Stripe"
export STRIPE_NAMED_CREDENTIAL="StripeAdapter_NC"

# commerce interfaces
export INVENTORY_INTERFACE="B2BInventoryConnector"
export INVENTORY_EXTERNAL_SERVICE="COMPUTE_INVENTORY_B2BSmConnector"
export PRICE_INTERFACE="B2BPriceConnector"
export PRICE_EXTERNAL_SERVICE="COMPUTE_PRICE_B2BSmConnector"
export SHIPMENT_INTERFACE="B2BShipmentConnector"
export SHIPMENT_EXTERNAL_SERVICE="COMPUTE_SHIPMENT_B2BSmConnector"
export TAX_INTERFACE="B2BTaxConnector"
export TAX_EXTERNAL_SERVICE="COMPUTE_TAX_B2BSmConnector"

# managed package IDs
# Salesforce Labs Managed Packages
# Streaming API monitor - currently v3.9.0 - Winter 23
export STREAMING_API_MONITOR_PACKAGE="04t1t000003Y9dCAAS"
# CMS Content Type Manager - currently v 1.3.0 - summer 21
export CMS_CONTENT_TYPE_MANAGER_PACKAGE="04t3h000004KnZfAAK"
# B2B Video Player for commerce connector
export B2B_VIDEO_PLAYER_PACKAGE="04t6g0000083hTPAAY"
# Salesforce CPQ Managed Package - currently 242.2 - Spring 23
export SBQQ_PACKAGE="04t4N000000N6FFQA0"
# Salesforce Billing Managed Package - currently 242.0 - Spring 23
export BLNG_PACKAGE="04t0K000001VLn7QAG"
# CPQ Connector for Subscription Management Managed Package - currently 1.7.0
export CPQSM_PACKAGE="04t8c000001IvB8AAK"

# change to 0 for items that should be skipped - the script will soon start to get/set these values as part of an error handling process
#export INSERT_DATA=true
#export DEPLOY_CODE=true
#export CREATE_GATEWAY=true
#export CREATE_TAX_ENGINE=true
#export CREATE_COMMUNITY=true
#export INSTALL_PACKAGES=true
#export INCLUDE_COMMUNITY=true
#export INCLUDE_COMMERCE_CONNECTOR=true
#export CREATE_CONNECTOR_STORE=true
#export INCLUDE_CONNECTOR_STORE_TEMPLATE=true
#export REGISTER_COMMERCE_SERVICES=true
#export CREATE_STRIPE_GATEWAY=true

export SFDX_NPM_REGISTRY="http://platform-cli-registry.eng.sfdc.net:4880/"
export SFDX_S3_HOST="http://platform-cli-s3.eng.sfdc.net:9000/sfdx/media/salesforce-cli"

# ----------------------------------
# Colors
# ----------------------------------

export NOCOLOR='\033[0m'
export BLACK='\033[0;30m'
export DARKGRAY='\033[1;30m'
export RED='\033[0;31m'
export LIGHTRED='\033[1;31m'
export GREEN='\033[0;32m'
export LIGHTGREEN='\033[1;32m'
export BROWN='\033[0;33m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export LIGHTBLUE='\033[1;34m'
export PURPLE='\033[0;35m'
export LIGHTPURPLE='\033[1;35m'
export CYAN='\033[0;36m'
export LIGHTCYAN='\033[1;36m'
export LIGHTGRAY='\033[0;37m'
export WHITE='\033[1;37m'
export ORANGE='\033[38;5;208m'
export PINK='\033[38;5;205m'
export DARKRED='\033[38;5;88m'
export DARKGREEN='\033[38;5;22m'
export DARKBLUE='\033[38;5;19m'
export DARKPURPLE='\033[38;5;55m'
export DARKCYAN='\033[38;5;30m'
export DARKYELLOW='\033[38;5;136m'
export DARKORANGE='\033[38;5;166m'
export LIGHTGRAY='\033[38;5;250m'
export LIGHTYELLOW='\033[38;5;226m'
export LIGHTGREEN='\033[38;5;46m'
export LIGHTBLUE='\033[38;5;39m'
export LIGHTPURPLE='\033[38;5;99m'
export LIGHTCYAN='\033[38;5;14m'
export LIGHTRED='\033[38;5;203m'
export LIGHTORANGE='\033[38;5;215m'
export LIGHTPINK='\033[38;5;218m'
export LIGHTBROWN='\033[38;5;130m'
export GRAY='\033[38;5;246m'
export DARKGRAY='\033[38;5;240m'
export BLUEGRAY='\033[38;5;67m'
export TEAL='\033[38;5;37m'
export LIME='\033[38;5;118m'
export OLIVE='\033[38;5;100m'
export GOLD='\033[38;5;178m'
export SKYBLUE='\033[38;5;111m'
export ROSE='\033[38;5;197m'
export INDIGO='\033[38;5;99m'
export VIOLET='\033[38;5;93m'
export MAROON='\033[38;5;124m'
export NAVY='\033[38;5;17m'
export TURQUOISE='\033[38;5;45m'
export MAGENTA='\033[38;5;201m'
export LAVENDER='\033[38;5;183m'
export RASPBERRY='\033[38;5;161m'
export TAN='\033[38;5;180m'
export BEIGE='\033[38;5;230m'
export SALMON='\033[38;5;209m'
export APRICOT='\033[38;5;221m'
export MAUVE='\033[38;5;175m'
export SLATE='\033[38;5;60m'
export STEEL='\033[38;5;66m'
export MINT='\033[38;5;121m'
export OLIVEGREEN='\033[38;5;58m'
export FORESTGREEN='\033[38;5;28m'
export SEAFOAM='\033[38;5;84m'
export CORAL='\033[38;5;209m'
export SAND='\033[38;5;180m'
export KHAKI='\033[38;5;227m'
export PLUM='\033[38;5;96m'
export BRONZE='\033[38;5;136m'
export COPPER='\033[38;5;166m'
export BRICK='\033[38;5;124m'
export COBALT='\033[38;5;32m'
export CHARCOAL='\033[38;5;238m'
export IVORY='\033[38;5;231m'
export BEET='\033[38;5;89m'
export MANGO='\033[38;5;208m'
export CREAM='\033[38;5;254m'
export LEMON='\033[38;5;190m'
export MINTGREEN='\033[38;5;121m'
export LILAC='\033[38;5;183m'
export TANGERINE='\033[38;5;214m'
export RUBY='\033[38;5;161m'
export JADE='\033[38;5;35m'
export LIPSTICK='\033[38;5;203m'
export EGGPLANT='\033[38;5;54m'
export BURGUNDY='\033[38;5;88m'
export SAGE='\033[38;5;114m'
export PEACH='\033[38;5;221m'
export TAUPE='\033[38;5;139m'
export HONEY='\033[38;5;214m'
export LAVENDERGRAY='\033[38;5;188m'
export LILACBLUE='\033[38;5;183m'
export PERIWINKLE='\033[38;5;111m'
export MUSTARD='\033[38;5;190m'
export OLIVEGRAY='\033[38;5;155m'
export GRAPE='\033[38;5;96m'
export RUST='\033[38;5;166m'
export TEALBLUE='\033[38;5;37m'
export MOSS='\033[38;5;64m'
export CINNAMON='\033[38;5;166m'
export BISQUE='\033[38;5;230m'
export WHEAT='\033[38;5;223m'
export CAMEL='\033[38;5;180m'
export LIGHTSALMON='\033[38;5;216m'
export LIGHTPINK='\033[38;5;218m'
export LIGHTGOLD='\033[38;5;220m'
export LIGHTLAVENDER='\033[38;5;183m'
export LIGHTSAGE='\033[38;5;152m'
export LIGHTTAUPE='\033[38;5;138m'
export LIGHTMINT='\033[38;5;121m'
export LIGHTOLIVE='\033[38;5;155m'
export LIGHTMOSS='\033[38;5;105m'
export LIGHTGRAPE='\033[38;5;96m'
export LIGHTRUST='\033[38;5;166m'
export LIGHTTEALBLUE='\033[38;5;37m'
export LIGHTCINNAMON='\033[38;5;166m'
export LIGHTBISQUE='\033[38;5;230m'
export LIGHTWHEAT='\033[38;5;223m'
export LIGHTCAMEL='\033[38;5;180m'
