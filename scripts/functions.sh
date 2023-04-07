#!/bin/sh
function echo_color() {
  case $1 in
  red)
    echo "${RED}$2${NOCOLOR}"
    ;;
  green)
    echo "${GREEN}$2${NOCOLOR}"
    ;;
  orange)
    echo "${ORANGE}$2${NOCOLOR}"
    ;;
  blue)
    echo "${BLUE}$2${NOCOLOR}"
    ;;
  purple)
    echo "${PURPLE}$2${NOCOLOR}"
    ;;
  cyan)
    echo "${CYAN}$2${NOCOLOR}"
    ;;
  gray)
    echo "${LIGHTGRAY}$2${NOCOLOR}"
    ;;
  lightred)
    echo "${LIGHTRED}$2${NOCOLOR}"
    ;;
  lightgreen)
    echo "${LIGHTGREEN}$2${NOCOLOR}"
    ;;
  lightblue)
    echo "${LIGHTBLUE}$2${NOCOLOR}"
    ;;
  lightpurple)
    echo "${LIGHTPURPLE}$2${NOCOLOR}"
    ;;
  yellow)
    echo "${YELLOW}$2${NOCOLOR}"
    ;;
  *)
    echo "${NOCOLOR}$2"
    ;;
  esac
}

function echo_keypair() {
  echo "${CYAN}$1${NOCOLOR}:${ORANGE}$2${NOCOLOR}"
}

function sfdx_version() {
  sfdx --version | grep "sfdx-cli" | awk '{print $1}' | cut -d "/" -f 2 | cut -d "." -f 1,2 | bc
}

function error_and_exit() {
  echo "$1"
  exit 1
}

function prompt_to_accept_disclaimer() {
  echo_color green "This setup can create an example storefront that is built using Experience Cloud to faciliate development with and understanding of Subscription Management."
  echo_color green "Because Subscription Management isn't yet licensed for use with Experience Cloud, the Customer Account Portal that is created as part of this setup will execute some operations to access the Subscription Management APIs as a privleged internal user for developmet purposes."
  echo_color red "This may not be used in a licensed and active production org - doing so may violate your license agreement and create a security risk."
  echo_color cyan "[0] No, proceed with setup without Experience Cloud"
  echo_color cyan "[1] Yes, proceed with setup including Experience Cloud"
  echo_color cyan "[2] No, do not proceed and exit setup"
  echo_color red "Do you agree to these conditions?"
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
    # TODO - this overwrites any explicit overrides from above.
    # This needs to be refactored to retain any overrides such as createCommunity if script is being run after a failure but the community was created.
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
  echo_color green "Would you like to create a scratch org?"
  echo_color cyan "[0] No"
  echo_color cyan "[1] Yes"
  read -p "Please enter a value > " createScratch
  if [ $createScratch -eq 1 ]; then
    orgType=1
  fi
}

function prompt_for_scratch_edition() {
  echo_color green "What type of scratch org would you like to create?"
  echo_color cyan "[0] Developer"
  echo_color cyan "[1] Enterprise"
  echo_color cyan "[2] Enterprise with Rebate Management"
  read -p "Please enter the scratch org type you would like to create > " scratchEdition
}

function prompt_for_scratch_alias() {
  read -p "Please enter an alias for your scratch org > " scratchAlias
}

function prompt_for_org_type() {
  echo_color green "What type of org are you deploying to?"
  echo_color cyan "[0] Production"
  echo_color cyan "[1] Scratch"
  echo_color cyan "[2] Sandbox"
  echo_color cyan "[3] Falcon (test1 - Internal SFDC only)"
  echo_color cyan "[4] Developer (Beta)"
  read -p "Please enter the org type you would like to set up > " orgType
}

function prompt_for_falcon_instance() {
  echo_color green "Which falcon instance are you using?"
  echo_color cyan "[0] NA46 (main branch)"
  echo_color cyan "[1] NA45 (main-2 branch)"
  read -p "Please enter the falcon instance you would like to target > " falconInstance
}

function prompt_to_install_connector() {
  echo_color green "Would you like to install the Subscription Management/B2B Commerce connector?"
  echo_color red "NOTICE:  This feature is currently under development and requires additional configuration after the quickstart process completes"
  echo_color cyan "[0] No"
  echo_color cyan "[1] Yes"
  read -p "Please enter a value > " includeCommerceConnector
}

function prompt_to_create_commerce_community() {
  echo_color green "Would you like to create a B2B Commerce Digital Experience (Community)?"
  echo_color cyan "[0] No"
  echo_color cyan "[1] Yes"
  read -p "Please enter a value > " createConnectorStore
}

function prompt_to_install_commerce_store() {
  echo_color green "Would you like to include and publish the Subscription Management/B2B Commerce connector configured store template?"
  echo_color red "NOTICE:  This feature is currently under development and requires additional configuration after the quickstart process completes"
  echo_color red "NOTICE:  In 242 The B2B Commerce Aura template is no longer available by default and needs to be toggled in Black Tab.  Unless you know what you're doing, you should answer No here until further notice.  The template will be updated for LWR soon."
  echo_color cyan "[0] No"
  echo_color cyan "[1] Yes"
  read -p "Please enter a value > " includeConnectorStoreTemplate
}

function get_user_email {
  local un=$1
  userEmail=$(sf data query -q "SELECT Email from User WHERE Username='$un' LIMIT 1" -r csv | tail -n +2)
  if [[ -z {$userEmail} ]]; then
    echo_color green "Email lookup failed for username $un"
  else
    echo_color green "Email: "
    echo_color cyan "$userEmail"
  fi
}

function get_sfdx_user_info() {
  tmpfile=$(mktemp)
  sfdx org display user --json >$tmpfile

  username=$(cat $tmpfile | grep -o '"username": *"[^"]*' | grep -o '[^"]*$')
  userId=$(cat $tmpfile | grep -o '"id": *"[^"]*' | grep -o '[^"]*$')
  orgId=$(cat $tmpfile | grep -o '"orgId": *"[^"]*' | grep -o '[^"]*$')
  instanceUrl=$(cat $tmpfile | grep -o '"instanceUrl": *"[^"]*' | grep -o '[^"]*$')
  myDomain=$(echo $instanceUrl | sed 's/^........//')
  mySubDomain=$(echo $myDomain | cut -d "." -f 1)

  echo_color green "Current Username: "
  echo_keypair username $username
  echo_color green "Current User Id: "
  echo_keypair userId $userId
  echo_color green "Current Org Id: "
  echo_keypair orgId $orgId
  echo_color green "Current Instance URL: "
  echo_keypair instanceUrl $instanceUrl
  echo_color green "Current myDomain: "
  echo_keypair myDomain $myDomain
  echo_color green "Current mySubDomain: "
  echo_keypair mySubDomain $mySubDomain
  rm $tmpfile
  echo ""
  if [ -z $userEmail ]; then
    get_user_email $username
  fi
}

function get_record_id() {
    sfdx data query -q "SELECT Id FROM $1 WHERE $2='$3' LIMIT 1" -r csv | tail -n +2
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
  2)
    defFile="config/enterprise-rebates-scratch-def.json"
    ;;
  esac

  sfdx org create scratch -f $defFile -a $alias -d -y 30
}

function deploy() {
  if [ "$(echo "$local_sfdx == $SFDX_RC_VERSION" | bc)" -ge 1 ]; then
    sfdx project deploy start -g -c -r -d $1 -a $API_VERSION -l NoTestRun 
  else
    sf deploy metadata -g -c -r -d $1 -a $API_VERSION -l NoTestRun
  fi
}

function install_package() {
  sfdx package install -p $1
}

function check_b2b_videoplayer() {
  if [ "$b2bvp" -eq 0 ]; then
    echo_color green "Checking for B2B LE Video Player"
    if sfdx package installed list --json | grep -q '"SubscriberPackageNamespace": *"b2bvp"'; then
      echo_color cyan "B2B LE Video Player Found"
      b2bvp=1
    fi
  fi
}

function check_SBQQ() {
  if [ "$sbqq" -eq 0 ]; then
    echo_color green "Checking for Salesforce CPQ (SBQQ)"
    if sfdx package installed list --json | grep -q '"SubscriberPackageNamespace": *"SBQQ"'; then
      echo_color cyan "Salesforce CPQ Found"
      sbqq=1
    fi
  fi
}

function check_blng() {
  if [ "$blng" -eq 0 ]; then
    echo_color green "Checking for Salesforce Billing (blng)"
    if sfdx package installed list --json | grep -q '"SubscriberPackageNamespace": *"blng"'; then
      echo_color cyan "Salesforce Billing Found"
      blng=1
    fi
  fi
}

function get_store_url() {
  case $orgType in
    1)
      storeBaseUrl="$mySubDomain.scratch.my.site.com"
      ;;
    2)
      storeBaseUrl="$mySubDomain.sandbox.my.site.com"
      ;;
    3)
      storeBaseUrl="$mySubDomain.test1.my.pc-rnd.site.com"
      ;;
    4)
      storeBaseUrl="$mySubDomain.develop.my.site.com"
      ;;
    *)
      storeBaseUrl="$mySubDomain.my.site.com"
      ;;
  esac
  echo_keypair storeBaseUrl $storeBaseUrl
}

function get_org_base_url() {
  case $orgType in
  0)
    orgBaseUrl="$mySubDomain.lightning.force.com"
    oauthUrl="login.salesforce.com"
    ;;
  1)
    orgBaseUrl="$mySubDomain.scratch.lightning.force.com"
    oauthUrl="test.salesforce.com"
    ;;
  2)
    orgBaseUrl="$mySubDomain.sandbox.lightning.force.com"
    oauthUrl="test.salesforce.com"
    ;;
  3)
    orgBaseUrl="$mySubDomain.test1.lightning.pc-rnd.force.com"
    oauthUrl="login.test1.pc-rnd.salesforce.com"
    ;;
  4)
    orgBaseUrl="$mySubDomain.develop.lightning.force.com"
    oauthUrl="login.salesforce.com"
    ;;
  esac

  echo_keypair orgBaseUrl $orgBaseUrl
  echo_keypair oauthUrl $oauthUrl
}

function count_permset_license() {
  permsetCount=$(sfdx data query -q "Select COUNT(Id) from PermissionSetLicenseAssign Where AssigneeId='$userId' and PermissionSetLicenseId IN (SELECT Id FROM PermissionSetLicense WHERE DeveloperName = '$1')" -r csv | tail -n +2)
}

function count_permset() {
  local q="SELECT COUNT(Id) FROM PermissionSetAssignment WHERE AssigneeID='$userId' AND PermissionSetId IN (SELECT Id FROM PermissionSet WHERE Name IN ($1))"
  sfdx data query -q "$q" -r csv | tail -n +2
}

function assign_permset_license() {
  local ps=("$@")
  for i in "${ps[@]}"; do
    count_permset_license "$i"
    if [ "$permsetCount" == "0" ]; then
      echo_color green "Assiging Permission Set License: $i"
      sfdx org assign permsetlicense -n $i
    else
      echo_color green "Permission Set License Assignment for Permset $i exists for $username"
    fi
  done
}

function assign_permset() {
  local ps=("$@")
  for i in "${ps[@]}"; do
    count_permset "$i"
    if [ "$permsetCount" == "0" ]; then
      echo_color green "Assiging Permset: $i"
      sfdx org assign permset -n $i
    else
      echo_color green "Permset Assignment for Permset $i exists for $username"
    fi
  done
}

function assign_all_permsets() {
  local ps=("$@")
  local delim=","
  local joined=""
  local permsets=""
  local len=${#ps[@]}
  for i in "${ps[@]}"; do
    joined+="'$i'$delim"
  done
  joined=${joined%$delim}
  local permsetCount=$(count_permset $joined)
  permsets="${ps[*]}"
  if [[ $permsetCount -ne $len ]]; then
    echo_color green "Permsets Missing - Attempting to Assign All Permsets"
    sfdx org assign permset -n $permsets
  else
    echo_color green "All Permsets Assigned"
  fi
}

function check_qbranch() {
  if (( orgType == 0 )); then
    echo_color green "Checking for QBranch Utils"
    if sfdx package installed list --json | grep -q '"SubscriberPackageNamespace": *"qbranch"'; then
      echo_color cyan "QBranch Utils Found - Querying for CDO/RCIDO"
      local qbranchId=$(sfdx data query -q "SELECT Identifier__c FROM QLabs__mdt LIMIT 1" -r csv | tail -n +2)
      case $qbranchId in
        $CDO_ID)
          echo_color cyan "QBranch CDO/SDO Found"
          cdo=1
          ;;
        $MFGIDO_ID)
          echo_color cyan "QBranch MFG IDO Found"
          cdo=1
          ;;
        $RCIDO_ID)
          echo_color cyan "QBranch Revenue Cloud IDO Found"
          rcido=1
          ;;
      esac
    fi
  fi
}

function populate_b2b_connector_custom_metadata() {
    echo_color green "Populating variables for B2B Connector Custom Metadata"
    get_store_url
    get_org_base_url
    echo_color green "Getting Id for WebStore $B2B_STORE_NAME"
    commerceStoreId=$(get_record_id WebStore Name $B2B_STORE_NAME)
    echo_keypair commerceStoreId $commerceStoreId
    defaultCategoryId=$(sfdx data query -q "SELECT Id FROM ProductCategory WHERE Name='$B2B_CATEGORY_NAME' LIMIT 1" -r csv | tail -n +2)
    echo_keypair defaultCategoryId $defaultCategoryId

    sed -e "s/INSERT_INTERNAL_ACCOUNT_ID/$userId/g" quickstart-config/sm-b2b-connector/customMetadata/B2B_Store_Configuration.InternalAccountId.md-meta.xml >temp_b2b_store_configuration_internalaccountid.xml
    sed -e "s/INSERT_EFFECTIVE_ACCOUNT_ID/$defaultAccountId/g" quickstart-config/sm-b2b-connector/customMetadata/RSM_Connector_Configuration.Effective_Account_Id.md-meta.xml >temp_b2b_store_configuration_accountid.xml
    sed -e "s/INSERT_ORG_DOMAIN_URL/https:\/\/$oauthUrl/g" quickstart-config/sm-b2b-connector/customMetadata/RSM_Connector_Configuration.Org_Domain_Url.md-meta.xml >temp_b2b_store_configuration_orgdomainurl.xml
    sed -e "s/INSERT_STORE_BASE_URL/https:\/\/$storeBaseUrl/g" quickstart-config/sm-b2b-connector/customMetadata/RSM_Connector_Configuration.Store_Base_Url.md-meta.xml >temp_b2b_store_configuration_storebaseurl.xml
    sed -e "s/INSERT_STORE_URL/https:\/\/$storeBaseUrl\/$b2bStoreName/g" quickstart-config/sm-b2b-connector/customMetadata/RSM_Connector_Configuration.StoreUrl.md-meta.xml >temp_b2b_store_configuration_storeurl.xml
    sed -e "s/INSERT_TAX_ENGINE_ID/$taxEngineId/g" quickstart-config/sm-b2b-connector/customMetadata/RSM_Connector_Configuration.Tax_Engine_Id.md-meta.xml >temp_b2b_store_configuration_taxengineid.xml
    sed -e "s/INSERT_USERNAME/$username/g" quickstart-config/sm-b2b-connector/customMetadata/RSM_Connector_Configuration.Username.md-meta.xml >temp_b2b_store_configuration_username.xml
    sed -e "s/INSERT_WEBSTORE_ID/$commerceStoreId/g" quickstart-config/sm-b2b-connector/customMetadata/RSM_Connector_Configuration.WebStoreID.md-meta.xml >temp_b2b_store_configuration_webstoreid.xml
    sed -e "s/INSERT_SALESFORCE_BASE_URL/https:\/\/$oauthUrl/g" quickstart-config/sm-b2b-connector/customMetadata/RSM_Connector_Configuration.Salesforce_Base_URL.md-meta.xml >temp_b2b_store_configuration_salesforce_base_url.xml
    sed -e "s/INSERT_ORG_BASE_URL/https:\/\/$orgBaseUrl/g" quickstart-config/sm-b2b-connector/remoteSiteSettings/SFLabs.remoteSite-meta.xml >temp_SFLabs.remoteSite-meta.xml
    sed -e "s/INSERT_MYDOMAIN_URL/https:\/\/$myDomain/g" quickstart-config/sm-b2b-connector/remoteSiteSettings/MyDomain.remoteSite-meta.xml >temp_MyDomain.remoteSite-meta.xml

    mv temp_b2b_store_configuration_internalaccountid.xml $COMMERCE_CONNECTOR_MAIN_DIR/default/customMetadata/B2B_Store_Configuration.InternalAccountId.md-meta.xml
    mv temp_b2b_store_configuration_accountid.xml $COMMERCE_CONNECTOR_MAIN_DIR/default/customMetadata/RSM_Connector_Configuration.Effective_Account_Id.md-meta.xml
    mv temp_b2b_store_configuration_orgdomainurl.xml $COMMERCE_CONNECTOR_MAIN_DIR/default/customMetadata/RSM_Connector_Configuration.Org_Domain_Url.md-meta.xml
    mv temp_b2b_store_configuration_storebaseurl.xml $COMMERCE_CONNECTOR_MAIN_DIR/default/customMetadata/RSM_Connector_Configuration.Store_Base_Url.md-meta.xml
    mv temp_b2b_store_configuration_storeurl.xml $COMMERCE_CONNECTOR_MAIN_DIR/default/customMetadata/RSM_Connector_Configuration.StoreUrl.md-meta.xml
    mv temp_b2b_store_configuration_taxengineid.xml $COMMERCE_CONNECTOR_MAIN_DIR/default/customMetadata/RSM_Connector_Configuration.Tax_Engine_Id.md-meta.xml
    mv temp_b2b_store_configuration_username.xml $COMMERCE_CONNECTOR_MAIN_DIR/default/customMetadata/RSM_Connector_Configuration.Username.md-meta.xml
    mv temp_b2b_store_configuration_webstoreid.xml $COMMERCE_CONNECTOR_MAIN_DIR/default/customMetadata/RSM_Connector_Configuration.WebStoreID.md-meta.xml
    mv temp_b2b_store_configuration_salesforce_base_url.xml $COMMERCE_CONNECTOR_MAIN_DIR/default/customMetadata/RSM_Connector_Configuration.Salesforce_Base_URL.md-meta.xml
    mv temp_SFLabs.remoteSite-meta.xml $COMMERCE_CONNECTOR_TEMP_DIR/default/remoteSiteSettings/SFLabs.remoteSite-meta.xml
    mv temp_MyDomain.remoteSite-meta.xml $COMMERCE_CONNECTOR_TEMP_DIR/default/remoteSiteSettings/MyDomain.remoteSite-meta.xml

}

function insert_data() {
  if [ $insertData -eq 1 ]; then
    if [ -n "$taxEngineId" ]; then
      echo_color green "Copying Mock Tax Engine to TaxTreatment.json"
      sed -e "s/\"TaxEngineId\": \"INSERT_TAX_ENGINE_ID\"/\"TaxEngineId\": \"${taxEngineId}\"/g" data/TaxTreatment-template.json >data/TaxTreatment.json
      sleep 2
    else
      echo_color red "Tax Engine Id not found. Exiting"
      exit 1
    fi
    #TODO: Add a check to see if the default tax and billing policies already exist
    echo_color green "Pushing Tax & Billing Policy Data to the Org"
    sfdx data import tree -p data/data-plan-1.json
    echo ""

    echo_color green "Activating Tax & Billing Policies and Updating Product2 data records with Activated Policy Ids"
    activate_tax_and_billing_policies || error_and_exit "Tax & Billing Policy Activation Failed"
    echo ""
    #TODO: refactor to be more modular and do checks for existing data
    echo_color green "Pushing Product & Pricing Data to the Org"
    # Choose to seed data with all SM Product setup completed or choose the base option to not add PSMO and PBE for use in workshops
    if [ $includeCommerceConnector -eq 1 ]; then
      echo_color green "Getting Standard and Commerce Pricebooks for Pricebook Entries and replacing in data files"
      commerceStoreId=$(get_record_id WebStore Name $B2B_STORE_NAME)
      sleep 2
      echo_keypair commerceStoreId $commerceStoreId
      standardPricebook2Id=$(sfdx data query -q "SELECT Id FROM Pricebook2 WHERE Name='$STANDARD_PRICEBOOK_NAME' AND IsStandard=true LIMIT 1" -r csv | tail -n +2)
      sleep 2
      echo_keypair standardPricebook2Id $standardPricebook2Id
      #smPricebook2Id=$(get_record_id Pricebook2 Name $CANDIDATE_PRICEBOOK_NAME)
      smPricebook2Id=$(sfdx data query -q "SELECT Id FROM Pricebook2 WHERE Name='$CANDIDATE_PRICEBOOK_NAME' LIMIT 1" -r csv | tail -n +2)
      sleep 2
      echo_keypair smPricebook2Id $smPricebook2Id
      #commercePricebook2Id=$(get_record_id Pricebook2 Name $COMMERCE_PRICEBOOK_NAME)
      commercePricebook2Id=$(sfdx data query -q "SELECT Id FROM Pricebook2 WHERE Name='$COMMERCE_PRICEBOOK_NAME' LIMIT 1" -r csv | tail -n +2)
      sleep 2
      echo_keypair commercePricebook2Id $commercePricebook2Id
      if [ -z "$standardPricebook2Id" ] || [ -z "$smPricebook2Id" ] || [ -z "$commercePricebook2Id" ]; then
        echo_color red "Pricebook Ids not found. Exiting"
        exit 1
      fi
      sed -e "s/\"Pricebook2Id\": \"STANDARD_PRICEBOOK\"/\"Pricebook2Id\": \"${standardPricebook2Id}\"/g" -e "s/\"Pricebook2Id\": \"SM_PRICEBOOK\"/\"Pricebook2Id\": \"${smPricebook2Id}\"/g" -e "s/\"Pricebook2Id\": \"COMMERCE_PRICEBOOK\"/\"Pricebook2Id\": \"${commercePricebook2Id}\"/g" data/PricebookEntry-template.json >data/PricebookEntry.json
      sed -e "s/\"Pricebook2Id\": \"COMMERCE_PRICEBOOK_ID\"/\"Pricebook2Id\": \"${commercePricebook2Id}\"/g" -e "s/\"Pricebook2Id\": \"SM_PRICEBOOK_ID\"/\"Pricebook2Id\": \"${smPricebook2Id}\"/g" data/BuyerGroupPricebooks-template.json >data/BuyerGroupPricebooks.json
      sed -e "s/\"WebStoreId\": \"PutWebStoreIdHere\"/\"WebStoreId\": \"${commerceStoreId}\"/g" data/WebStoreBuyerGroups-template.json >data/WebStoreBuyerGroups.json
      sed -e "s/\"SalesStoreId\": \"PutWebStoreIdHere\"/\"SalesStoreId\": \"${commerceStoreId}\"/g" data/WebStoreCatalogs-template.json >data/WebStoreCatalogs.json
      sed -e "s/\"WebStoreId\": \"PutWebStoreIdHere\"/\"WebStoreId\": \"${commerceStoreId}\"/g" -e "s/\"Pricebook2Id\": \"COMMERCE_PRICEBOOK_ID\"/\"Pricebook2Id\": \"${commercePricebook2Id}\"/g" -e "s/\"Pricebook2Id\": \"SM_PRICEBOOK_ID\"/\"Pricebook2Id\": \"${smPricebook2Id}\"/g" data/WebStorePricebooks-template.json >data/WebStorePricebooks.json
      #TODO: Add a check to see if the product data already exists, and if so obtain IDs and update the data files or just error and exit
      sfdx data import tree -p data/data-plan-commerce.json
      echo_color green "Updating Webstore $B2B_STORE_NAME StrikethroughPricebookId to $commercePricebook2Id"
      sfdx data update record -s WebStore -i $commerceStoreId -v "StrikethroughPricebookId='$commercePricebook2Id'"
    else
      sfdx data import tree -p data/data-plan-2.json
    fi
    #sfdx data import tree -p data/data-plan-2-base.json
    echo_color green "Pushing Default Account & Contact"
    sfdx data import tree -p data/data-plan-3.json
    sleep 3
    echo_color purple "All Data Successfully Inserted.  Setup can now be safely restarted in case of failure once insertData is manually set to 0."
  fi
}

function create_tax_engine() {
  echo_color green "Getting Id for ApexClass $TAX_PROVIDER_CLASS_NAME"
  taxProviderClassId=$(get_record_id ApexClass Name $TAX_PROVIDER_CLASS_NAME)
  echo_keypair taxProviderClassId $taxProviderClassId
  echo_color green "Checking for existing TaxEngineProvider $TAX_PROVIDER_CLASS_NAME"
  taxEngineProviderId=$(get_record_id TaxEngineProvider DeveloperName $TAX_PROVIDER_CLASS_NAME)
  if [ -z "$taxEngineProviderId" ]; then
    echo_color green "Creating TaxEngineProvider $TAX_PROVIDER_CLASS_NAME"
    sfdx data create record -s TaxEngineProvider -v "DeveloperName='$TAX_PROVIDER_CLASS_NAME' MasterLabel='$TAX_PROVIDER_CLASS_NAME' ApexAdapterId=$taxProviderClassId"
    echo_color green "Getting Id for TaxEngineProvider $TAX_PROVIDER_CLASS_NAME"
    taxEngineProviderId=$(get_record_id TaxEngineProvider DeveloperName $TAX_PROVIDER_CLASS_NAME)
  fi
  echo_keypair taxEngineProviderId $taxEngineProviderId

  echo_color green "Getting Id for NamedCredential $NAMED_CREDENTIAL_MASTER_LABEL"
  taxMerchantCredentialId=$(get_record_id NamedCredential DeveloperName $NAMED_CREDENTIAL_MASTER_LABEL)
  echo_keypair taxMerchantCredentialId $taxMerchantCredentialId
  echo_color green "Checking for existing TaxEngine $TAX_PROVIDER_CLASS_NAME"
  taxEngineId=$(get_record_id TaxEngine TaxEngineName $TAX_PROVIDER_CLASS_NAME)
  if [ -z "$taxEngineId" ]; then
    echo_color green "Creating TaxEngine $TAX_PROVIDER_CLASS_NAME"
    sfdx data create record -s TaxEngine -v "TaxEngineName='$TAX_PROVIDER_CLASS_NAME' MerchantCredentialId=$taxMerchantCredentialId TaxEngineProviderId=$taxEngineProviderId Status='Active' SellerCode='Billing2' TaxEngineCity='San Francisco' TaxEngineCountry='United States' TaxEnginePostalCode='94105' TaxEngineState='California'"
    echo_color green "Getting Id for TaxEngine $TAX_PROVIDER_CLASS_NAME"
    taxEngineId=$(get_record_id TaxEngine TaxEngineName $TAX_PROVIDER_CLASS_NAME)
  fi
  echo_color green "$TAX_PROVIDER_CLASS_NAME Tax Engine Id:"
  echo_keypair taxEngineId $taxEngineId
}

function register_commerce_services() {
  echo_color green "Registering Commerce Services"
  commerceStoreId=$(get_record_id WebStore Name $B2B_STORE_NAME)
  echo_keypair "Commerce Store Id" $commerceStoreId
  stripeApexClassId=$(get_record_id ApexClass Name $STRIPE_GATEWAY_ADAPTER_NAME)
  echo_keypair "Stripe Apex Class Id" $stripeApexClassId
  stripePaymentGatewayProviderId=$(get_record_id PaymentGatewayProvider DeveloperName $STRIPE_GATEWAY_PROVIDER_NAME)
  echo_keypair "Stripe Payment Gateway Provider Id" $stripePaymentGatewayProviderId
  stripeNamedCredentialId=$(get_record_id NamedCredential MasterLabel $STRIPE_NAMED_CREDENTIAL)
  echo_keypair "Stripe Named Credential Id" $stripeNamedCredentialId

  if [ $createStripeGateway -eq 1 ]; then
    echo_color green "Creating Stripe Payment Gateway"
    sfdx data create record -s PaymentGateway -v "MerchantCredentialId=$stripeNamedCredentialId PaymentGatewayName=$STRIPE_PAYMENT_GATEWAY_NAME PaymentGatewayProviderId=$stripePaymentGatewayProviderId Status=Active"
  fi

  declare -a apex_class_ids
  for class_name in $INVENTORY_INTERFACE $PRICE_INTERFACE $SHIPMENT_INTERFACE $TAX_INTERFACE; do
    apex_class_ids["$class_name"]=$(get_record_id ApexClass Name $class_name)
    echo_keypair "$class_name Apex Class Id" ${apex_class_ids["$class_name"]}
  done

  #for service in inventory price shipment tax; do
  for service in INVENTORY SHIPMENT TAX; do

    service_name=$(eval echo \$"${service}_EXTERNAL_SERVICE")
    echo_keypair "$service_name Service Name" $service_name
    service_type="$(tr '[:lower:]' '[:upper:]' <<<${service:0:1})${service:1}"
    echo_keypair "$service_name Service Type" $service_type
    service_class=$(get_record_id ApexClass Name $(eval echo \$"${service}_INTERFACE"))
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

  paymentGatewayId=$(get_record_id PaymentGateway PaymentGatewayName $PAYMENT_GATEWAY_NAME)
  echo_keypair "Payment Gateway Id" $paymentGatewayId
  sfdx data create record -s StoreIntegratedService -v "Integration=$paymentGatewayId StoreId=$commerceStoreId ServiceProviderType=Payment"
}

function activate_tax_and_billing_policies() {
  echo_color green "Activating Tax and Billing Policies"
  #TODO: refactor to query for records regardless of status and only activate if not already active
  defaultTaxTreatmentId=$(sfdx data query -q "SELECT Id from TaxTreatment WHERE Name='$DEFAULT_NO_TAX_TREATMENT_NAME' AND (Status='Draft' OR Status='Inactive') LIMIT 1" -r csv | tail -n +2)
  echo_keypair defaultTaxTreatmentId $defaultTaxTreatmentId
  sleep 2
  defaultTaxPolicyId=$(sfdx data query -q "SELECT Id from TaxPolicy WHERE Name='$DEFAULT_NO_TAX_POLICY_NAME' AND (Status='Draft' OR Status='Inactive') LIMIT 1" -r csv | tail -n +2)
  echo_keypair defaultTaxPolicyId $defaultTaxPolicyId
  sleep 2
  mockTaxTreatmentId=$(sfdx data query -q "SELECT Id from TaxTreatment WHERE Name='$DEFAULT_MOCK_TAX_TREATMENT_NAME' AND (Status='Draft' OR Status='Inactive') LIMIT 1" -r csv | tail -n +2)
  echo_keypair mockTaxTreatmentId $mockTaxTreatmentId
  sleep 2
  mockTaxPolicyId=$(sfdx data query -q "SELECT Id from TaxPolicy WHERE Name='$DEFAULT_MOCK_TAX_POLICY_NAME' AND (Status='Draft' OR Status='Inactive') LIMIT 1" -r csv | tail -n +2)
  echo_keypair mockTaxPolicyId $mockTaxPolicyId
  sleep 2
  echo_color green "Activating $DEFAULT_MOCK_TAX_TREATMENT_NAME"
  sfdx data update record -s TaxTreatment -i $mockTaxTreatmentId -v "TaxPolicyId='$mockTaxPolicyId' Status=Active"
  sleep 2
  echo_color green "Activating $DEFAULT_MOCK_TAX_POLICY_NAME"
  sfdx data update record -s TaxPolicy -i $mockTaxPolicyId -v "DefaultTaxTreatmentId='$mockTaxTreatmentId' Status=Active"
  sleep 2
  defaultBillingTreatmentItemId=$(sfdx data query -q "SELECT Id from BillingTreatmentItem WHERE Name='$DEFAULT_BILLING_TREATMENT_ITEM_NAME' AND (Status='Active' OR Status='Inactive') LIMIT 1" -r csv | tail -n +2)
  echo_keypair defaultBillingTreatmentItemId $defaultBillingTreatmentItemId
  sleep 2
  defaultBillingTreatmentId=$(sfdx data query -q "SELECT Id from BillingTreatment WHERE Name='$DEFAULT_BILLING_TREATMENT_NAME' AND (Status='Draft' OR Status='Inactive') LIMIT 1" -r csv | tail -n +2)
  echo_keypair defaultBillingTreatmentId $defaultBillingTreatmentId
  sleep 2
  defaultBillingPolicyId=$(sfdx data query -q "SELECT Id from BillingPolicy WHERE Name='$DEFAULT_BILLING_POLICY_NAME' AND (Status='Draft' OR Status='Inactive') LIMIT 1" -r csv | tail -n +2)
  echo_keypair defaultBillingPolicyId $defaultBillingPolicyId
  sleep 2
  defaultPaymentTermId=$(sfdx data query -q "SELECT Id from PaymentTerm WHERE Name='$DEFAULT_PAYMENT_TERM_NAME' AND (Status='Draft' OR Status='Inactive') LIMIT 1" -r csv | tail -n +2)
  echo_keypair defaultPaymentTermId $defaultPaymentTermId
  sleep 2
  echo_color green "Activating $DEFAULT_PAYMENT_TERM_NAME"
  sfdx data update record -s PaymentTerm -i $defaultPaymentTermId -v "IsDefault=TRUE Status=Active"
  sleep 2
  echo_color green "Activating $DEFAULT_BILLING_TREATMENT_NAME"
  sfdx data update record -s BillingTreatment -i $defaultBillingTreatmentId -v "BillingPolicyId='$defaultBillingPolicyId' Status=Active"
  sleep 2
  echo_color green "Activating $DEFAULT_BILLING_POLICY_NAME"
  sfdx data update record -s BillingPolicy -i $defaultBillingPolicyId -v "DefaultBillingTreatmentId='$defaultBillingTreatmentId' Status=Active"
  sleep 2
  echo_color green "Copying Default Billing Policy Id and Default Tax Policy Id to Product2.json"
  sed -e "s/\"BillingPolicyId\": \"PutBillingPolicyHere\"/\"BillingPolicyId\": \"${defaultBillingPolicyId}\"/g;s/\"TaxPolicyId\": \"PutTaxPolicyHere\"/\"TaxPolicyId\": \"${mockTaxPolicyId}\"/g" data/Product2-template.json >data/Product2.json
}

function deploy_org_settings() {
  echo_color green "Deploying Org Settings"
  deploy "${BASE_DIR}/main/default/settings"
}

function create_commerce_store() {
  echo_color green "Creating Commerce Store"
  sfdx community create -n "$B2B_STORE_NAME" -t "B2B Commerce" -p "$B2B_STORE_NAME" -d "B2B Commerce (Aura) created by Subscription Management Quickstart"
}