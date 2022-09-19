#!/bin/sh
export SFDX_NPM_REGISTRY="http://platform-cli-registry.eng.sfdc.net:4880/"
export SFDX_S3_HOST="http://platform-cli-s3.eng.sfdc.net:9000/sfdx/media/salesforce-cli"

#change to 0 for items that should be skipped - the script will soon start to get/set these values as part of an error handling process
insertData=1
deployCode=1
createGateway=1
createCommunity=1
installPackages=1
includeCommunity=1

#api version to run sfdx commands
apiversion="55.0"

#module directories
defaultDir="sm"

#base metadata for all other modules
baseDir="$defaultDir/sm-base/main"

#forked from https://github.com/SalesforceLabs/RevenueCloudCodeSamples
assetManagementDir="$defaultDir/sm-asset-management/main"

#forked from https://github.com/samcheck/sm-my-community
communityDir="$defaultDir/sm-my-community/main"

#forked from https://github.com/samcheck/sm-utility-tables
utilDir="$defaultDir/sm-utility-tables/main"

#forked from https://github.com/samcheck/sm-cancel-asset
cancelDir="$defaultDir/sm-cancel-asset/main"

#forked from https://github.com/samcheck/sm-refund-credit
refundDir="$defaultDir/sm-refund-credit/main"

#forked from https://github.com/samcheck/sm-renewals
renewDir="$defaultDir/sm-renewals/main"

#forked from https://github.com/samcheck/sm-community-template
communityTemplateDir="$defaultDir/sm-community-template/main"

# temp directory to be merged into one or more new modules - mainly layouts, pages, etc
tempDir="$defaultDir/sm-temp/main"

#named credential for example customer community storefront to access SM APIs
namedCredentialMasterLabel="Salesforce"

#Sample Experience Cloud Customer Community Storefront Name
communityName="sm"
communityName1="sm1"

#mock payment gateway
paymentGatewayAdapterName="SalesforceGatewayAdapter"
paymentGatewayProviderName="SalesforceGatewayProvider"
paymentGatewayName="MockPaymentGateway"

#qbranch org - CDO, SDO, xDO
cdo=0
sdo=0
xdo=0

#package IDs
# Salesforce Labs Streaming API monitor - currently v3.7.0 - summer 22
streamingAPIMonitor="04t1t000003Y9d7AAC"
# Salesforce CPQ Managed Package - currently 238.2 - summer 22
cpq="04t4N000000xBcT"
billing="04t0K000000wUsV"

declare -a smPermissionSetGroups=(
  "SubscriptionManagementBillingAdmin"
  "SubscriptionManagementBillingOperations"
  "SubscriptionManagementBuyerIntegrationUser"
  "SubscriptionManagementCollections"
  "SubscriptionManagementCreditMemoAdjustmentsOperations"
  "SubscriptionManagementPaymentAdministrator"
  "SubscriptionManagementPaymentOperations"
  "SubscriptionManagementProductAndPricingAdmin"
  "SubscriptionManagementSalesOperationsRep"
  "SubscriptionManagementTaxAdmin"
)

declare -a smPermissionSets=(
  "SubscriptionManagementApplyCreditToInvoiceApi"
  "SubscriptionManagementBillingSetup"
  "SubscriptionManagementCalculateInvoiceLatePaymentRiskFeature"
  "SubscriptionManagementCalculatePricesApi"
  "SubscriptionManagementCalculateTaxesApi"
  "SubscriptionManagementCreateBillingScheduleFromOrderItemApi"
  "SubscriptionManagementCreateInvoiceFromBillingScheduleApi"
  "SubscriptionManagementCreateInvoiceFromOrderApi"
  "SubscriptionManagementCreditAnInvoiceApi"
  "SubscriptionManagementCreditMemoRecoveryApi"
  "SubscriptionManagementInitiateCancellationApi"
  "SubscriptionManagementInitiateRenewalApi"
  "SubscriptionManagementInvoiceErrorRecoveryApi"
  "SubscriptionManagementIssueStandaloneCreditApi"
  "SubscriptionManagementOrderToAssetApi"
  "SubscriptionManagementPaymentsConfiguration"
  "SubscriptionManagementPaymentsRuntimeApi"
  "SubscriptionManagementPlaceOrderApi"
  "SubscriptionManagementProductAndPriceConfigurationApi"
  "SubscriptionManagementProductImportApi"
  "SubscriptionManagementScheduledBatchInvoicingApi"
  "SubscriptionManagementScheduledBatchPaymentsApi"
  "SubscriptionManagementTaxConfiguration"
  "SubscriptionManagementUnapplyCreditToInvoiceApi"
  "SubscriptionManagementVoidPostedInvoiceApi"
)

declare -a smQuickStartPermissionSets=(
  "SM_Cancel_Asset"
  "SM_Community"
  "SM_Renew_Asset"
  "SM_Account_Tables"
  "SM_Asset_Tables"
  "SM_Cart_Items"
  "SM_Rev_Error_Log_Table"
)

declare -a smQuickStartPermissionSetsNoCommunity=(
  "SM_Cancel_Asset"
  "SM_Renew_Asset"
  "SM_Account_Tables"
  "SM_Asset_Tables"
  "SM_Rev_Error_Log_Table"
  "SM_Temp"
)

function echo_attention() {
  local green='\033[0;32m'
  local no_color='\033[0m'
  echo "${green}$1${no_color}"
}

function echo_red() {
  local red='\033[0;34m'
  local no_color='\033[0m'
  echo "${red}$1${no_color}"
}

function error_and_exit() {
  echo "$1"
  exit 1
}

function prompt_to_accept_disclaimer() {
  echo_attention "This setup can create an example storefront that is built using Experience Cloud to faciliate development with and understanding of Subscription Management."
  echo_attention "Because Subscription Management isn't yet licensed for use wit Experience Cloud, the Customer Account Portal that is created as part of this setup will execute some operations to access the Subscription Management APIs as a privleged internal user for developmet purposes."
  echo_red "This may not be used in a licensed and active production org - doing so may violate your license agreement and create a security risk."
  echo "[0] No, proceed with setup without Experience Cloud"
  echo "[1] Yes, proceed with setup including Experience Cloud"
  echo "[2] No, do not proceed and exit setup"
  echo_red "Do you agree to these conditions?"
  read -p "Please enter a value > " acceptDisclaimer
  local t1=$(grep -x "sm/sm-my-community" .forceignore)
  local t2=$(grep -x "sm/sm-community-template" .forceignore)
  local t3=$(grep -x "sm/sm-nocommunity" .forceignore)
  case $acceptDisclaimer in
  0)
    createCommunity=0
    includeCommunity=0
    if [ -z $t1 ]; then
      echo "sm/sm-my-community" >>.forceignore
    fi
    if [ -z $t2 ]; then
      echo "sm/sm-community-template" >>.forceignore
    fi
    if [ -n $t3 ]; then
      sed -i '' '/^sm\/sm-nocommunity$/d' .forceignore
    fi
    ;;
  1)
    #TODO - this overwrites any explicit overrides from above.
    #This needs to be refactored to retain any overrides such as createCommunity if script is being run after a failure but the community was created.
    createCommunity=1
    includeCommunity=1
    if [ -n $t1 ]; then
      sed -i '' '/^sm\/sm-my-community$/d' .forceignore
    fi
    if [ -n $t2 ]; then
      sed -i '' '/^sm\/sm-community-template$/d' .forceignore
    fi
    if [ -z $t3 ]; then
      echo "sm/sm-nocommunity" >>.forceignore
    fi
    ;;
  2)
    error_and_exit "Disclaimer conditions not accepted - exiting"
    ;;
  esac
}

function prompt_to_create_scratch() {
  echo_attention "Would you like to create a scratch org?"
  echo "[0] No"
  echo "[1] Yes"
  read -p "Please enter a value > " createScratch
  if [ $createScratch -eq 1 ]; then
    orgType=1
  fi
}

function prompt_for_scratch_edition() {
  echo_attention "What type of scratch org would you like to create?"
  echo "[0] Developer"
  echo "[1] Enterprise"
  read -p "Please enter the scratch org type you would like to create > " scratchEdition
}

function prompt_for_scratch_alias() {
  read -p "Please enter an alias for your scratch org > " scratchAlias
}

function prompt_for_org_type() {
  echo_attention "What type of org are you deploying to?"
  echo "[0] Production/Developer"
  echo "[1] Scratch"
  echo "[2] Sandbox"
  echo "[3] Falcon (test1 - Internal SFDC only)"
  read -p "Please enter the org type you would like to set up > " orgType
}

function prompt_for_falcon_instance() {
  echo_attention "Which falcon instance are you using?"
  echo "[0] NA46 (main branch)"
  echo "[1] NA45 (main-2 branch)"
  read -p "Please enter the falcon instance you would like to target > " falconInstance
}

function get_user_email {
  local un=$1
  userEmail=$(sfdx force:data:soql:query -q "SELECT Email from User WHERE Username='$un' LIMIT 1" -r csv | tail -n +2)
  if [ -z $userEmail ]; then
    echo_attention "Email lookup failed for username $un"
  else
    echo_attention "Email: "
    echo_red "$userEmail"
  fi
}

function get_sfdx_user_info() {
  tmpfile=$(mktemp)
  sfdx force:user:display --json >$tmpfile

  username=$(cat $tmpfile | grep -o '"username": *"[^"]*' | grep -o '[^"]*$')
  userId=$(cat $tmpfile | grep -o '"id": *"[^"]*' | grep -o '[^"]*$')
  orgId=$(cat $tmpfile | grep -o '"orgId": *"[^"]*' | grep -o '[^"]*$')
  instanceUrl=$(cat $tmpfile | grep -o '"instanceUrl": *"[^"]*' | grep -o '[^"]*$')
  myDomain=$(echo $instanceUrl | sed 's/^........//')
  mySubDomain=$(echo $myDomain | cut -d "." -f 1)

  echo_attention "Current Username: "
  echo_red $username
  echo_attention "Current User Id: "
  echo_red $userId
  echo_attention "Current Org Id: "
  echo_red $orgId
  echo_attention "Current Instance URL: "
  echo_red $instanceUrl
  echo_attention "Current myDomain: "
  echo_red $myDomain
  echo_attention "Current mySubDomain: "
  echo_red $mySubDomain
  rm $tmpfile
  echo ""
  if [ -z $userEmail ]; then
    get_user_email $username
  fi
}

function create_scratch_org() {
  local alias=$1
  local defFile="config/project-scratch-def.json"

  case $scratchEdition in
  0)
    defFile="config/dev-scratch-def.json"
    ;;
  1)
    defFile="config/enterprise-scratch-def.json"
    ;;
  esac

  sfdx force:org:create -f $defFile -a $alias -s -d 30
}

function deploy() {
  sfdx force:source:deploy -p $1 -g --apiversion=$apiversion
}

function install_package() {
  sfdx force:package:install -p $1 --apiversion=$apiversion
}

function count_permset_license() {
  permsetCount=$(sfdx force:data:soql:query -q "Select COUNT(Id) from PermissionSetLicenseAssign Where AssigneeId='$userId' and PermissionSetLicenseId IN (SELECT Id FROM PermissionSetLicense WHERE DeveloperName = '$1')" -r csv | tail -n +2)
}

function count_permset() {
  local ps=("$@")
  local q="SELECT COUNT(Id) FROM PermissionSetAssignment WHERE AssigneeID='$userId' AND PermissionSetId IN (SELECT Id FROM PermissionSet WHERE Name IN ($1))"
  permsetCount=$(sfdx force:data:soql:query -q "$q" -r csv | tail -n +2)
}

function assign_permset_license() {
  local ps=("$@")
  for i in "${ps[@]}"; do
    count_permset_license "$i"
    if [ $permsetCount = "0" ]; then
      echo_attention "Assiging Permission Set License: $i"
      sfdx force:user:permsetlicense:assign -n $i
    else
      echo_attention "Permission Set License Assignment for Permset $i exists for $username"
    fi
  done
}

function assign_permset() {
  local ps=("$@")
  for i in "${ps[@]}"; do
    count_permset "$i"
    if [ $permsetCount = "0" ]; then
      echo_attention "Assiging Permset: $i"
      sfdx force:user:permset:assign -n $i
    else
      echo_attention "Permset Assignment for Permset $i exists for $username"
    fi
  done
}

function assign_all_permsets() {
  local ps=("$@")
  local delim="'"
  local joined=""
  local sq="'"
  local len=${#ps[@]}
  local lenstr=$lenstr$len
  #echo_red "ps array length: $len"
  #echo_red "ps array length string: $lenstr"
  for i in "${ps[@]}"; do
    joined="$joined$delim$i"
    delim="','"
  done
  joined=$joined$sq
  #echo_red $joined
  count_permset $joined
  if [ $permsetCount != $lenstr ]; then
    echo_attention "Permsets Missing - Attempting to Assign All Permsets"
    sfdx force:user:permset:assign -n $joined
  else
    echo_attention "All Permsets Assigned"
  fi
}

function check_qbranch() {
  if [ $orgType -eq 0 ]; then
    tmpfile=$(mktemp)
    echo_attention "Checking for QBranch Utils"
    sfdx force:package:installed:list --json >$tmpfile
    qbranch=$(cat $tmpfile | grep -o '"SubscriberPackageNamespace": *"[^"]*' | grep -o 'qbranch')
    if [ -n "$qbranch" ]; then
      echo_attention "QBranch Utils Found - CDO/SDO"
      cdo=1
    fi
  fi
}

while [[ ! $acceptDisclaimer =~ 0|1 ]]; do
  prompt_to_accept_disclaimer
done

while [[ ! $createScratch =~ 0|1 ]]; do
  prompt_to_create_scratch
done

if [ $createScratch -eq 1 ]; then
  while [[ ! $scratchEdition =~ 0|1 ]]; do
    prompt_for_scratch_edition
  done
  while [[ -z "$scratchAlias" ]]; do
    prompt_for_scratch_alias
  done
  if [ -n "$scratchEdition" ] && [ -n "$scratchAlias" ]; then
    case $scratchEdition in
    0)
      type="Developer"
      ;;
    1)
      type="Enterprise"
      ;;
    esac
    echo_attention "Creating $type scratch org with alias $scratchAlias"
    create_scratch_org $scratchAlias
  else
    error_and_exit "Cannot create scratch org - exiting"
  fi
fi

while [[ ! $orgType =~ 0|1|2|3 ]]; do
  prompt_for_org_type
done

case $orgType in
0)
  orgTypeStr="Production"
  echo_attention "You are deploying to a production/developer instance type - https://login.salesforce.com"
  check_qbranch
  ;;
1)
  orgTypeStr="Scratch"
  echo_attention "You are deploying to a Scratch org - https://test.salesforce.com"
  ;;
2)
  orgTypeStr="Sandbox"
  echo_attention "You are deploying to a Sandbox org type - https://test.salesforce.com"
  ;;
3)
  orgTypeStr="Falcon"
  echo_attention "You are requesting deployment to a falcon instance - https://login.test1.pc-rnd.salesforce.com"
  while [[ ! $falconInstance =~ 0|1 ]]; do
    prompt_for_falcon_instance
  done
  ;;
esac

get_sfdx_user_info

sed -e "s/<callbackUrl>https:\/\/login.salesforce.com\/services\/oauth2\/callback<\/callbackUrl>/<callbackUrl>https:\/\/login.salesforce.com\/services\/oauth2\/callback\nhttps:\/\/$myDomain\/services\/oauth2\/callback<\/callbackUrl>/g" quickstart-config/Postman.connectedApp-meta-template.xml >postmannew.xml
sed -e "s/<callbackUrl>https:\/\/login.salesforce.com\/services\/oauth2\/callback<\/callbackUrl>/<callbackUrl>https:\/\/login.salesforce.com\/services\/oauth2\/callback\nhttps:\/\/$myDomain\/services\/oauth2\/callback\nhttps:\/\/$myDomain\/services\/authcallback\/SF<\/callbackUrl>/g" quickstart-config/Salesforce.connectedApp-meta-template.xml >salesforcenew.xml
sed -e "s/www.salesforce.com/$myDomain/g" quickstart-config/MySalesforce.namedCredential-meta-template.xml >mysalesforce.xml
mv postmannew.xml $baseDir/default/connectedApps/Postman.connectedApp-meta.xml
mv salesforcenew.xml $baseDir/default/connectedApps/Salesforce.connectedApp-meta.xml
mv mysalesforce.xml $tempDir/default/namedCredentials/MySalesforce.namedCredential-meta.xml

if [ $deployCode -eq 1 ]; then
  echo_attention "Setting Default Org Settings"
  scripts/set-org-settings.sh || error_and_exit "Setting Org Settings Failed."
  echo ""
fi

echo_attention "Assigning Permission Sets & Permission Set Groups"
assign_permset_license "RevSubscriptionManagementPsl"
assign_all_permsets "${smPermissionSets[@]}"
#./assign-permsets.sh || error_and_exit "Permset Assignments Failed."
echo ""

if [ $deployCode -eq 1 ]; then
  echo_attention "Pushing sm-base to the Org. This will take few mins."
  deploy $baseDir
fi

assign_permset "'SM_Base'"
echo ""

# Get Standard Pricebooks for Store and replace in json files
echo_attention "Getting Standard Pricebook for Pricebook Entries and replacing in data files"
pricebook1=$(sfdx force:data:soql:query -q "SELECT Id FROM Pricebook2 WHERE Name='Standard Price Book' AND IsStandard=true LIMIT 1" -r csv | tail -n +2)
sleep 1
if [ -n "$pricebook1" ]; then
  sed -e "s/\"Pricebook2Id\": \"PutStandardPricebookHere\"/\"Pricebook2Id\": \"${pricebook1}\"/g" data/PricebookEntry-template.json >data/PricebookEntry.json
else
  error_and_exit "Could not determine Standard Pricebook.  Exiting."
fi

# Activate Standard Pricebook
echo_attention "Activating Standard Pricebook"
if [ -n "$pricebook1" ]; then
  sfdx force:data:record:update -s Pricebook2 -i $pricebook1 -v "IsActive=true"
  sleep 1
else
  error_and_exit "Could not determine Standard Pricebook.  Exiting."
fi

if [ $insertData -eq 1 ]; then
  echo_attention "Pushing Tax & Billing Policy Data to the Org"
  sfdx force:data:tree:import -p data/data-plan-1.json
  echo ""

  echo_attention "Activating Tax & Billing Policies and Updating Product2 data records with Activated Policy Ids"
  scripts/pilot-activate-tax-and-billing-policies.sh || error_and_exit "Tax & Billing Policy Activation Failed"
  echo ""

  echo_attention "Pushing Product & Pricing Data to the Org"
  # Choose to seed data with all SM Product setup completed or choose the base option to not add PSMO and PBE for use in workshops
  sfdx force:data:tree:import -p data/data-plan-2.json
  #sfdx force:data:tree:import -p data/data-plan-2-base.json
  echo ""

  echo_attention "Pushing Default Account & Contact"
  sfdx force:data:tree:import -p data/data-plan-3.json
  echo ""
fi

apexClassId=$(sfdx force:data:soql:query -q "SELECT Id FROM ApexClass WHERE Name='$paymentGatewayAdapterName' LIMIT 1" -r csv | tail -n +2)
sleep 1

if [ -z "$apexClassId" ]; then
  error_and_exit "No Payment Gateway Adapter Class"
else
  # Creating Payment Gateway
  echo_attention "Getting Payment Gateway Provider $paymentGatewayProviderName"
  paymentGatewayProviderId=$(sfdx force:data:soql:query -q "SELECT Id FROM PaymentGatewayProvider WHERE DeveloperName='$paymentGatewayProviderName' LIMIT 1" -r csv | tail -n +2)
  echo_attention paymentGatewayProviderId=$paymentGatewayProviderId
  sleep 1
fi

echo_attention "Getting Named Credential $namedCredentialMasterLabel"
namedCredentialId=$(sfdx force:data:soql:query -q "SELECT Id FROM NamedCredential WHERE MasterLabel='$namedCredentialMasterLabel' LIMIT 1" -r csv | tail -n +2)
echo_attention namedCredentialId=$namedCredentialId
sleep 1
echo ""

if [ $createGateway -eq 1 ]; then
  echo_attention "Creating PaymentGateway record using MerchantCredentialId=$namedCredentialId, PaymentGatewayProviderId=$paymentGatewayProviderId."
  sfdx force:data:record:create -s PaymentGateway -v "MerchantCredentialId=$namedCredentialId PaymentGatewayName=$paymentGatewayName PaymentGatewayProviderId=$paymentGatewayProviderId Status=Active"
  sleep 1
fi

if [ $createCommunity -eq 1 ]; then
  echo_attention "Creating Subscription Management Customer Account Portal Digital Experience"
  sfdx force:community:create --name "$communityName" --templatename "Customer Account Portal" --urlpathprefix "$communityName" --description "Customer Portal created by Subscription Management Quickstart"
fi

if [ $includeCommunity -eq 1 ]; then
  while [ -z "${storeId}" ]; do
    echo_attention "Subscription Management Customer Community not yet created, waiting 10 seconds..."
    storeId=$(sfdx force:data:soql:query -q "SELECT Id FROM Network WHERE Name='$communityName' LIMIT 1" -r csv | tail -n +2)
    sleep 10
  done

  echo_attention "Subscription Management Customer Community found with id ${storeId}"
  echo ""

  roles=$(sfdx force:data:soql:query --query \ "SELECT COUNT(Id) FROM UserRole WHERE Name = 'CEO'" -r csv | tail -n +2)

  if [ "$roles" = "0" ]; then
    sfdx force:data:record:create -s UserRole -v "Name='CEO' DeveloperName='CEO' RollupDescription='CEO'"
    sleep 1
  else
    echo_attention "CEO Role already exists - proceeding without creating it."
  fi

  ceoRoleID=$(sfdx force:data:soql:query --query \ "SELECT Id FROM UserRole WHERE Name = 'CEO'" -r csv | tail -n +2)

  echo_attention "CEO role ID: "
  echo_red $ceoRoleID
  sleep 1

  sfdx force:data:record:update -s User -v "UserRoleId='$ceoRoleID'" -w "Username='$username'"
  sleep 1
fi

if [ $orgType -eq 1 ]; then
  defaultAccountId=$(sfdx force:data:soql:query -q "SELECT Id FROM Account WHERE Name='Apple Inc' LIMIT 1" -r csv | tail -n +2)
  echo_attention "Default Customer Account ID: "
  echo_red $defaultAccountId
  sleep 1

  defaultContact=$(sfdx force:data:soql:query -q "SELECT Id, FirstName, LastName FROM Contact WHERE AccountId='$defaultAccountId' LIMIT 1" -r csv | tail -n +2)
  defaultContactArray=($(echo $defaultContact | tr "," "\n"))
  defaultContactId=${defaultContactArray[0]}
  defaultContactFirstName=${defaultContactArray[1]}
  defaultContactLastName=${defaultContactArray[2]}

  echo_attention "Default Customer Contact ID: "
  echo_red $defaultContactId
  echo_attention "Default Customer Contact First Name: "
  echo_red $defaultContactFirstName
  echo_attention "Default Customer Contact Last Name: "
  echo_red $defaultContactLastName

  sed -e "s/buyer@scratch.org/buyer@$mySubDomain.sm.sd/g;s/InsertFirstName/$defaultContactFirstName/g;s/InsertLastName/$defaultContactLastName/g;s/InsertContactId/$defaultContactId/g" quickstart-config/buyer-user-def.json >quickstart-config/buyer-user-def-new.json
  #echo_attention "Creating Default Community Buyer Account"
  #sfdx force:user:create -f quickstart-config/buyer-user-def-new.json
fi

if [ -z "$pricebook1" ]; then
  pricebook1=$(sfdx force:data:soql:query -q "SELECT Id FROM Pricebook2 WHERE Name='Standard Price Book' AND IsStandard=true LIMIT 1" -r csv | tail -n +2)
  sleep 1
fi

paymentGatewayId=$(sfdx force:data:soql:query -q "Select Id from PaymentGateway Where PaymentGatewayName='MockPaymentGateway' and Status='Active'" -r csv | tail -n +2)
sleep 1

if [ -n "$pricebook1" ] && [ -n "$paymentGatewayId" ]; then
  tmpfile=$(mktemp)
  sed -e "s/INSERT_GATEWAY/$paymentGatewayId/g;s/INSERT_PRICEBOOK/$pricebook1/g" quickstart-config/home.json >$tmpfile
  mv -f $tmpfile $communityTemplateDir/default/experiences/$communityName1/views/home.json
else
  error_and_exit "Could not retrieve Pricebook or Payment Gateway.  Exiting before pushing community template"
fi

#This is a quick fix for issue #3.  CDO/SDO has Action Plan feature enabled.
#TODO - Refactor to check for specific features and include/exclude specific routes and views accordingly.
if [ $cdo -eq 1 ]; then
  echo_attention "Copying CDO/SDO community components to $communityName1"
  cp -f quickstart-config/cdo/experiences/$communityName1/routes/actionPlan* $communityTemplateDir/default/experiences/$communityName1/routes/.
  cp -f quickstart-config/cdo/experiences/$communityName1/views/actionPlan* $communityTemplateDir/default/experiences/$communityName1/views/.
fi

if [ $deployCode -eq 1 ]; then
  if [ $orgType -eq 1 ]; then
    echo_attention "Pushing all project source to the scratch org"
    sfdx force:source:beta:push -f -g --apiversion $apiversion
  else
    if [ $includeCommunity -eq 1 ]; then
      echo_attention "Pushing sm-my-community to the org"
      deploy $communityDir
    fi

    echo_attention "Pushing sm-asset-management to the org"
    deploy $assetManagementDir

    echo_attention "Pushing sm-utility-tables to the org"
    deploy $utilDir

    echo_attention "Pushing sm-cancel-asset to the org"
    deploy $cancelDir

    echo_attention "Pushing sm-refund-credit to the org"
    deploy $refundDir

    echo_attention "Pushing sm-renewals to the org"
    deploy $renewDir

    echo_attention "Pushing sm-temp to the org"
    deploy $tempDir

    if [ $includeCommunity -eq 1 ]; then
      echo_attention "Pushing sm-community-template to the org"
      deploy $communityTemplateDir
    fi
  fi
fi

echo_attention "Assigning SM QuickStart Permsets"
if [ $includeCommunity -eq 1 ]; then
  assign_all_permsets "${smQuickStartPermissionSets[@]}"
else
  assign_all_permsets "${smQuickStartPermissionSetsNoCommunity[@]}"
fi

if [ $includeCommunity -eq 1 ]; then
  sfdx force:community:publish -n "$communityName"
fi

if [ $installPackages -eq 1 ]; then
  echo_attention "Installing Managed Packages"
  echo_red "Installing Streaming API Monitor"
  install_package $streamingAPIMonitor
fi

echo_attention "All operations completed - opening configured org in default browser"
sfdx force:org:open -p lightning/setup/SetupOneHome/home
