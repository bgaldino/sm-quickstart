#!/bin/sh

# api version to run sfdx commands
API_VERSION="57.0"
SFDX_RC_VERSION=7.195

SDO_ID="aa74d1a8-5884-1c5f-082f-8bfbee691add"
CDO_ID="aa74d1a8-5884-1c5f-082f-8bfbee691add"
MFGIDO_ID="f1862ad0-58f1-dddf-b1a8-08e4f67db4a5"
RCIDO_ID="3cf4e7fa-6b41-a4a0-727e-d3f6bd9d7333"

# module directories
DEFAULT_DIR="sm"
# base metadata for all other modules
BASE_DIR="$DEFAULT_DIR/sm-base"
# forked from https://github.com/SalesforceLabs/RevenueCloudCodeSamples
ASSET_MANAGEMENT_DIR="$DEFAULT_DIR/sm-asset-management/main"
# forked from https://github.com/samcheck/sm-my-community
COMMUNITY_DIR="$DEFAULT_DIR/sm-my-community/main"
# forked from https://github.com/samcheck/sm-utility-tables
UTIL_DIR="$DEFAULT_DIR/sm-utility-tables/main"
# forked from https://github.com/samcheck/sm-cancel-asset
CANCEL_DIR="$DEFAULT_DIR/sm-cancel-asset/main"
# forked from https://github.com/samcheck/sm-refund-credit
REFUND_DIR="$DEFAULT_DIR/sm-refund-credit/main"
# forked from https://github.com/samcheck/sm-renewals
RENEW_DIR="$DEFAULT_DIR/sm-renewals/main"
# temp directory to be merged into one or more new modules - mainly layouts, pages, etc
SM_TEMP_DIR="$DEFAULT_DIR/sm-temp/main"
# connected apps only - to be packaged separately
SM_CONNECTED_APPS_DIR="$DEFAULT_DIR/sm-connected-apps/main"

QS_CONFIG_B2B_DIR="quickstart-config/sm-b2b-connector"
QS_CONFIG_SM_DIR="quickstart-config/sm-community-template"

DEFAULT_ACCOUNT_NAME="SFDC"
STANDARD_PRICEBOOK_NAME="Standard Price Book"
CANDIDATE_PRICEBOOK_NAME="Quickstart Subscription Management Price Book"
COMMERCE_PRICEBOOK_NAME="Quickstart B2B Commerce Price Book"

# Sample Experience Cloud Customer Community Storefront Name
COMMUNITY_NAME="sm"
COMMUNITY_NAME_1="${COMMUNITY_NAME}1"
# forked from https://github.com/samcheck/sm-community-template
COMMUNITY_TEMPLATE_DIR="$DEFAULT_DIR/sm-community-template/main"

# named credential for example customer community storefront to access SM APIs
NAMED_CREDENTIAL_MASTER_LABEL="Salesforce"
NAMED_CREDENTIAL_SM="RC_SubscriptionManagement"
NAMED_CREDENTIAL_SMB2B="RC_SMB2B"

# mock payment gateway
PAYMENT_GATEWAY_ADAPTER_NAME="SalesforceGatewayAdapter"
PAYMENT_GATEWAY_PROVIDER_NAME="SalesforceGatewayProvider"
PAYMENT_GATEWAY_NAME="MockPaymentGateway"

# mock tax provider
TAX_PROVIDER_CLASS_NAME="MockAdapter"

#Default Tax & Billing Policies
DEFAULT_MOCK_TAX_ENGINE_NAME="MockAdapter"
DEFAULT_MOCK_TAX_POLICY_NAME="Quickstart Default Tax Policy"
DEFAULT_MOCK_TAX_TREATMENT_NAME="Quickstart Default Tax Treatment"
DEFAULT_NO_TAX_POLICY_NAME="Quickstart No Tax Policy"
DEFAULT_NO_TAX_TREATMENT_NAME="Quickstart No Tax Treatment"
DEFAULT_BILLING_POLICY_NAME="Quickstart Default Billing Policy"
DEFAULT_BILLING_TREATMENT_NAME="Quickstart Default Billing Treatment"
DEFAULT_BILLING_TREATMENT_ITEM_NAME="Quickstart Default Billing Treatment Item"
DEFAULT_PAYMENT_TERM_NAME="Quickstart Default Payment Term"

# Sample B2B Commerce Storefront Name"
B2B_STORE_NAME="b2bsm"
B2B_STORE_NAME_1="${B2B_STORE_NAME}1"
B2B_CATEGORY_NAME="Software"
BUYER_GROUP_NAME="Quickstart Buyer Group"

# forked from https://github.com/bgaldino/sm-b2b-connector
COMMERCE_CONNECTOR_DIR="$DEFAULT_DIR/sm-b2b-connector"
COMMERCE_CONNECTOR_LIBS_DIR="$COMMERCE_CONNECTOR_DIR/libs"
COMMERCE_CONNECTOR_MAIN_DIR="$COMMERCE_CONNECTOR_DIR/main"
COMMERCE_CONNECTOR_TEMPLATE_DIR="$DEFAULT_DIR/sm-b2b-connector-community-template/main"
COMMERCE_CONNECTOR_TEMP_DIR="$DEFAULT_DIR/sm-b2b-connector-temp/main"

# stripe payment gateway
STRIPE_GATEWAY_ADAPTER_NAME="B2BStripeAdapter"
STRIPE_GATEWAY_PROVIDER_NAME="Stripe_Adapter"
STRIPE_PAYMENT_GATEWAY_NAME="Stripe"
STRIPE_NAMED_CREDENTIAL="StripeAdapter_NC"

# commerce interfaces
INVENTORY_INTERFACE="B2BInventoryConnector"
INVENTORY_EXTERNAL_SERVICE="COMPUTE_INVENTORY_B2BSmConnector"
PRICE_INTERFACE="B2BPriceConnector"
PRICE_EXTERNAL_SERVICE="COMPUTE_PRICE_B2BSmConnector"
SHIPMENT_INTERFACE="B2BShipmentConnector"
SHIPMENT_EXTERNAL_SERVICE="COMPUTE_SHIPMENT_B2BSmConnector"
TAX_INTERFACE="B2BTaxConnector"
TAX_EXTERNAL_SERVICE="COMPUTE_TAX_B2BSmConnector"

# managed package IDs
# Salesforce Labs Managed Packages
# Streaming API monitor - currently v3.9.0 - Winter 23
STREAMING_API_MONITOR_PACKAGE="04t1t000003Y9dCAAS"
# CMS Content Type Manager - currently v 1.3.0 - summer 21
CMS_CONTENT_TYPE_MANAGER_PACKAGE="04t3h000004KnZfAAK"
# B2B Video Player for commerce connector
B2B_VIDEO_PLAYER_PACKAGE="04t6g0000083hTPAAY"
# Salesforce CPQ Managed Package - currently 242.2 - Spring 23
SBQQ_PACKAGE="04t4N000000N6FFQA0"
# Salesforce Billing Managed Package - currently 242.0 - Spring 23
BLNG_PACKAGE="04t0K000001VLn7QAG"
# CPQ Connector for Subscription Management Managed Package - currently 1.7.0
CPQSM_PACKAGE="04t8c000001IvB8AAK"

# change to 0 for items that should be skipped - the script will soon start to get/set these values as part of an error handling process
#INSERT_DATA=1
#DEPLOY_CODE=1
#CREATE_GATEWAY=1
#CREATE_TAX_ENGINE=1
#CREATE_COMMUNITY=1
#INSTALL_PACKAGES=1
#INCLUDE_COMMUNITY=1
#INCLUDE_COMMERCE_CONNECTOR=1
#CREATE_CONNECTOR_STORE=1
#INCLUDE_CONNECTOR_STORE_TEMPLATE=1
#REGISTER_COMMERCE_SERVICES=1
#CREATE_STRIPE_GATEWAY=1

# ----------------------------------
# Colors
# ----------------------------------
NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTCYAN='\033[1;36m'
WHITE='\033[1;37m'

BOLD=$(tput bold)
NORM=$(tput sgr0)