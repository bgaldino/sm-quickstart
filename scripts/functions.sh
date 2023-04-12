#!/bin/sh
function echo_color() {
  typeset color=$1
  shift
  case $color in
  red)
    printf "%b%s%b\n" "${RED}" "$*" "${NOCOLOR}"
    ;;
  green)
    printf "%b%s%b\n" "${GREEN}" "$*" "${NOCOLOR}"
    ;;
  orange)
    printf "%b%s%b\n" "${ORANGE}" "$*" "${NOCOLOR}"
    ;;
  blue)
    printf "%b%s%b\n" "${BLUE}" "$*" "${NOCOLOR}"
    ;;
  purple)
    printf "%b%s%b\n" "${PURPLE}" "$*" "${NOCOLOR}"
    ;;
  cyan)
    printf "%b%s%b\n" "${CYAN}" "$*" "${NOCOLOR}"
    ;;
  gray)
    printf "%b%s%b\n" "${LIGHTGRAY}" "$*" "${NOCOLOR}"
    ;;
  lightred)
    printf "%b%s%b\n" "${LIGHTRED}" "$*" "${NOCOLOR}"
    ;;
  lightgreen)
    printf "%b%s%b\n" "${LIGHTGREEN}" "$*" "${NOCOLOR}"
    ;;
  lightblue)
    printf "%b%s%b\n" "${LIGHTBLUE}" "$*" "${NOCOLOR}"
    ;;
  lightpurple)
    printf "%b%s%b\n" "${LIGHTPURPLE}" "$*" "${NOCOLOR}"
    ;;
  yellow)
    printf "%b%s%b\n" "${YELLOW}" "$*" "${NOCOLOR}"
    ;;
  *)
    printf "%b%s%b\n" "${NOCOLOR}" "$*" "${NOCOLOR}"
    ;;
  esac
}

function echo_keypair() {
  printf "${CYAN}%s${NOCOLOR}:${ORANGE}%s${NOCOLOR}\n" "$1" "$2"
}

function sfdx_version() {
  sfdx --version | awk '/sfdx-cli/{print $2}' FS=/ | cut -d . -f1,2 | bc
}

function error_and_exit() {
  echo "$1"
  exit 1
}

function prompt_to_accept_disclaimer() {
  typeset disclaimer_msg=(
    "This setup can create an example storefront that is built using Experience Cloud to faciliate development with and understanding of Subscription Management."
    "Because Subscription Management isn't yet licensed for use with Experience Cloud, the Customer Account Portal that is created as part of this setup will execute some operations to access the Subscription Management APIs as a privleged internal user for development purposes."
    "This may not be used in a licensed and active production org - doing so may violate your license agreement and create a security risk."
  )

  echo_color green "${disclaimer_msg[0]}"
  echo_color green "${disclaimer_msg[1]}"
  echo_color red "${disclaimer_msg[2]}"
  
  PS3=$(echo_color red "Do you agree to these conditions? (use numbers): ")
  typeset option1=$(echo_color cyan "Yes, proceed with setup including Experience Cloud")
  typeset option2=$(echo_color cyan "No, proceed with setup without Experience Cloud")
  typeset option3=$(echo_color cyan "No, do not proceed and exit setup")
  select acceptDisclaimer in "$option1" "$option2" "$option3"; do
    case $REPLY in
      1)
        createCommunity=1
        includeCommunity=1
        sed -i '' '/^sm\/sm-my-community$/d' .forceignore
        sed -i '' '/^sm\/sm-community-template$/d' .forceignore
        if ! grep -q "sm/sm-nocommunity" .forceignore; then
          echo "sm/sm-nocommunity" >> .forceignore
        fi
        break;;
      2)
        createCommunity=0
        includeCommunity=0
        if ! grep -q "sm/sm-my-community" .forceignore; then
          echo "sm/sm-my-community" >> .forceignore
        fi
        if ! grep -q "sm/sm-community-template" .forceignore; then
          echo "sm/sm-community-template" >> .forceignore
        fi
        sed -i '' '/^sm\/sm-nocommunity$/d' .forceignore
        break;;
      3)
        error_and_exit "Disclaimer conditions not accepted - exiting"
        ;;
      *)
        echo_color red "Invalid input. Please enter a value between 1 and 3."
        ;;
    esac
  done
}


function prompt_to_create_scratch() {
  echo_color green "Would you like to create a scratch org?"
  typeset y=$(echo_color cyan "Yes")
  typeset n=$(echo_color cyan "No")
  options=("$n" "$y")
  PS3=$(echo_color red "Please select an option (use numbers): ")
  select yn in "${options[@]}"; do
    case $REPLY in
      1) orgType=0; createScratch=0; break;;
      2) orgType=1; createScratch=1; break;;
      * ) echo_color red "Invalid option. Please select 1 or 2.";;
    esac
  done
}



function prompt_for_scratch_edition() {
  echo_color green "What type of scratch org would you like to create?"
  typeset option1=$(echo_color cyan "Developer")
  typeset option2=$(echo_color cyan "Enterprise")
  typeset option3=$(echo_color cyan "Enterprise with Rebate Management")
  options=("$option1" "$option2" "$option3")
  PS3=$(echo_color red "Please enter the scratch org type you would like to create (use numbers): ")
  select scratchEdition in "${options[@]}"; do
    case $REPLY in
      1) scratchEdition=0; break;;
      2) scratchEdition=1; break;;
      3) scratchEdition=2; break;;
      * ) echo_color red "Invalid option. Please select 1, 2, or 3.";;
    esac
  done
}

function prompt_for_scratch_alias() {
  while true; do
    read -p "$(echo_color green 'Please enter an alias for your scratch org (e.g. my_project_dev) > ')" scratchAlias
    # Set default value if $scratchAlias is empty
    scratchAlias="${scratchAlias:-myScratchOrg}"
    
    # Check that $scratchAlias contains only alphanumeric characters and underscores
    if [[ ! "$scratchAlias" =~ ^[a-zA-Z0-9_]+$ ]]; then
      echo $'\e[31mError: Alias must contain only letters, numbers, and underscores.\e[0m'
      continue
    fi
    
    break
  done
}


function prompt_for_org_type() {
  echo_color green "What type of org are you deploying to?"
  echo_color cyan "[0] Production"
  echo_color cyan "[1] Scratch"
  echo_color cyan "[2] Sandbox"
  echo_color cyan "[3] Falcon (test1 - Internal SFDC only)"
  echo_color cyan "[4] Developer"
  read -p "Please enter the org type you would like to set up > " orgType
}

function prompt_for_falcon_instance() {
  local options=("NA46 (main branch)" "NA45 (main-2 branch)")
  echo_color green "Which falcon instance are you using?"
  for i in "${!options[@]}"; do 
    echo_color cyan "[$i] ${options[$i]}"
  done
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

function set_user_email {
  typeset un=$1
  SFDX_USER_EMAIL=$(sf data query -q "SELECT Email from User WHERE Username='$un' LIMIT 1" -r csv | tail -n +2)
  export SFDX_USER_EMAIL
}

function get_user_email {
  typeset un=$1
  if [[ -z $SFDX_USER_EMAIL ]]; then
    echo_color green "Email unknown for username $un"
  else
    echo_color green "Email: "
    echo_color cyan "$SFDX_USER_EMAIL"
  fi
}

function set_sfdx_user_info() {
  typeset tmpfile
  tmpfile=$(mktemp || exit 1)
  if ! sfdx org display user --json > "$tmpfile"; then
    echo "Failed to retrieve SFDX user info"
    rm "$tmpfile"
    return 1
  fi

  SFDX_USERNAME=$(grep -o '"username": *"[^"]*' "$tmpfile" | grep -o '[^"]*$')
  SFDX_USERID=$(grep -o '"id": *"[^"]*' "$tmpfile" | grep -o '[^"]*$')
  SFDX_ORGID=$(grep -o '"orgId": *"[^"]*' "$tmpfile" | grep -o '[^"]*$')
  SFDX_INSTANCEURL=$(grep -o '"instanceUrl": *"[^"]*' "$tmpfile" | grep -o '[^"]*$')
  SFDX_MYDOMAIN=$(echo "$SFDX_INSTANCEURL" | sed 's/^........//')
  SFDX_MYSUBDOMAIN=$(echo "$SFDX_MYDOMAIN" | cut -d "." -f 1)

  rm "$tmpfile"
  export SFDX_USERNAME SFDX_USERID SFDX_ORGID SFDX_INSTANCEURL SFDX_MYDOMAIN SFDX_MYSUBDOMAIN
}

function get_sfdx_user_info() {
  echo_color green "Current Username: "
  echo_keypair username "$SFDX_USERNAME"
  echo_color green "Current User Id: "
  echo_keypair userId "$SFDX_USERID"
  echo_color green "Current Org Id: "
  echo_keypair orgId "$SFDX_ORGID"
  echo_color green "Current Instance URL: "
  echo_keypair instanceUrl "$SFDX_INSTANCEURL"
  echo_color green "Current myDomain: "
  echo_keypair myDomain "$SFDX_MYDOMAIN"
  echo_color green "Current mySubDomain: "
  echo_keypair mySubDomain "$SFDX_MYSUBDOMAIN"

  echo ""
  if [ -z "$SFDX_USER_EMAIL" ]; then
    set_user_email "$SFDX_USERNAME"
    get_user_email
  fi
}

function get_record_id() {
    sfdx data query -q "SELECT Id FROM $1 WHERE $2='$3' LIMIT 1" -r csv | tail -n +2
}

function create_scratch_org() {
  typeset alias=$1
  typeset defFile="config/project-scratch-def.json"

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
  if [[ $(echo "$local_sfdx >= $SFDX_RC_VERSION" | bc) -eq 1 ]]; then
    sfdx project deploy start -g -c -r -d "$1" -a "$API_VERSION" -l NoTestRun
  else
    sf deploy metadata -g -c -r -d "$1" -a "$API_VERSION" -l NoTestRun
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
      storeBaseUrl="$SFDX_MYSUBDOMAIN.scratch.my.site.com"
      ;;
    2)
      storeBaseUrl="$SFDX_MYSUBDOMAIN.sandbox.my.site.com"
      ;;
    3)
      storeBaseUrl="$SFDX_MYSUBDOMAIN.test1.my.pc-rnd.site.com"
      ;;
    4)
      storeBaseUrl="$SFDX_MYSUBDOMAIN.develop.my.site.com"
      ;;
    *)
      storeBaseUrl="$SFDX_MYSUBDOMAIN.my.site.com"
      ;;
  esac
  echo_keypair storeBaseUrl $storeBaseUrl
}

function get_org_base_url() {
  case $orgType in
  0)
    orgBaseUrl="$SFDX_MYSUBDOMAIN.lightning.force.com"
    oauthUrl="login.salesforce.com"
    ;;
  1)
    orgBaseUrl="$SFDX_MYSUBDOMAIN.scratch.lightning.force.com"
    oauthUrl="test.salesforce.com"
    ;;
  2)
    orgBaseUrl="$SFDX_MYSUBDOMAIN.sandbox.lightning.force.com"
    oauthUrl="test.salesforce.com"
    ;;
  3)
    orgBaseUrl="$SFDX_MYSUBDOMAIN.test1.lightning.pc-rnd.force.com"
    oauthUrl="login.test1.pc-rnd.salesforce.com"
    ;;
  4)
    orgBaseUrl="$SFDX_MYSUBDOMAIN.develop.lightning.force.com"
    oauthUrl="login.salesforce.com"
    ;;
  esac

  echo_keypair orgBaseUrl $orgBaseUrl
  echo_keypair oauthUrl $oauthUrl
}

function count_permset_license() {
  permsetCount=$(sfdx data query -q "Select COUNT(Id) from PermissionSetLicenseAssign Where AssigneeId='$SFDX_USERID' and PermissionSetLicenseId IN (SELECT Id FROM PermissionSetLicense WHERE DeveloperName = '$1')" -r csv | tail -n +2)
}

function count_permset() {
  typeset q="SELECT COUNT(Id) FROM PermissionSetAssignment WHERE AssigneeID='$SFDX_USERID' AND PermissionSetId IN (SELECT Id FROM PermissionSet WHERE Name IN ($1))"
  sfdx data query -q "$q" -r csv | tail -n +2
}

function assign_permset_license() {
  typeset ps=("$@")
  for i in "${ps[@]}"; do
    count_permset_license "$i"
    if [ "$permsetCount" == "0" ]; then
      echo_color green "Assiging Permission Set License: $i"
      sfdx org assign permsetlicense -n $i
    else
      echo_color green "Permission Set License Assignment for Permset $i exists for $SFDX_USERNAME"
    fi
  done
}

function assign_permset() {
  typeset ps=("$@")
  for i in "${ps[@]}"; do
    count_permset "$i"
    if [ "$permsetCount" == "0" ]; then
      echo_color green "Assiging Permset: $i"
      sfdx org assign permset -n $i
    else
      echo_color green "Permset Assignment for Permset $i exists for $SFDX_USERNAME"
    fi
  done
}

function assign_all_permsets() {
  typeset ps=("$@")
  typeset delim=","
  typeset joined=""
  typeset permsets=""
  typeset len=${#ps[@]}
  for i in "${ps[@]}"; do
    joined+="'$i'$delim"
  done
  joined=${joined%$delim}
  typeset permsetCount=$(count_permset $joined)
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
      typeset qbranchId=$(sfdx data query -q "SELECT Identifier__c FROM QLabs__mdt LIMIT 1" -r csv | tail -n +2)
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
    commerceStoreId=$(get_record_id WebStore Name "$B2B_STORE_NAME")
    echo_keypair commerceStoreId "$commerceStoreId"
    defaultCategoryId=$(sfdx data query -q "SELECT Id FROM ProductCategory WHERE Name='$B2B_CATEGORY_NAME' LIMIT 1" -r csv | tail -n +2)
    echo_keypair defaultCategoryId "$defaultCategoryId"

    files_to_process=(
        "$QS_CONFIG_B2B_DIR/customMetadata/B2B_Store_Configuration.InternalAccountId.md-meta.xml"
        "$QS_CONFIG_B2B_DIR/customMetadata/RSM_Connector_Configuration.Effective_Account_Id.md-meta.xml"
        "$QS_CONFIG_B2B_DIR/customMetadata/RSM_Connector_Configuration.Org_Domain_Url.md-meta.xml"
        "$QS_CONFIG_B2B_DIR/customMetadata/RSM_Connector_Configuration.Store_Base_Url.md-meta.xml"
        "$QS_CONFIG_B2B_DIR/customMetadata/RSM_Connector_Configuration.StoreUrl.md-meta.xml"
        "$QS_CONFIG_B2B_DIR/customMetadata/RSM_Connector_Configuration.Tax_Engine_Id.md-meta.xml"
        "$QS_CONFIG_B2B_DIR/customMetadata/RSM_Connector_Configuration.Username.md-meta.xml"
        "$QS_CONFIG_B2B_DIR/customMetadata/RSM_Connector_Configuration.WebStoreID.md-meta.xml"
        "$QS_CONFIG_B2B_DIR/customMetadata/RSM_Connector_Configuration.Salesforce_Base_URL.md-meta.xml"
        "$QS_CONFIG_B2B_DIR/remoteSiteSettings/$NAMED_CREDENTIAL_SMB2B.remoteSite-meta.xml"
        "$QS_CONFIG_B2B_DIR/remoteSiteSettings/MyDomain.remoteSite-meta.xml"
    )

    for file in "${files_to_process[@]}"; do
        base_file=$(basename "$file")
        temp_file="${base_file%.*}_temp.xml"
        awk -v userId="$SFDX_USERID" -v defaultAccountId="$defaultAccountId" -v oauthUrl="$oauthUrl" -v storeBaseUrl="$storeBaseUrl" \
            -v b2bStoreName="$B2B_STORE_NAME" -v taxEngineId="$taxEngineId" -v username="$SFDX_USERNAME" -v commerceStoreId="$commerceStoreId" \
            -v orgBaseUrl="$orgBaseUrl" -v myDomain="$SFDX_MYDOMAIN" \
            '{gsub(/INSERT_INTERNAL_ACCOUNT_ID/, userId); gsub(/INSERT_EFFECTIVE_ACCOUNT_ID/, defaultAccountId); gsub(/INSERT_ORG_DOMAIN_URL/, "https://" oauthUrl); \
            gsub(/INSERT_STORE_BASE_URL/, "https://" storeBaseUrl); gsub(/INSERT_STORE_URL/, "https://" storeBaseUrl "/" b2bStoreName); gsub(/INSERT_TAX_ENGINE_ID/, taxEngineId); \
            gsub(/INSERT_USERNAME/, username); gsub(/INSERT_WEBSTORE_ID/, commerceStoreId); gsub(/INSERT_SALESFORCE_BASE_URL/, "https://" oauthUrl); \
            gsub(/INSERT_ORG_BASE_URL/, "https://" orgBaseUrl); gsub(/INSERT_MYDOMAIN_URL/, "https://" myDomain); print}' "$file" > "$temp_file"
        if [[ $base_file == *".remoteSite-meta.xml" ]]; then
            mv "$temp_file" "$COMMERCE_CONNECTOR_TEMP_DIR/default/remoteSiteSettings/$base_file"
        else
            mv "$temp_file" "$COMMERCE_CONNECTOR_MAIN_DIR/default/customMetadata/$base_file"
        fi
    done
}

function populate_b2b_connector_custom_metadata_smartbytes() {
    echo_color green "Populating variables for B2B Connector Custom Metadata"
    get_store_url
    get_org_base_url
    echo_color green "Getting Id for WebStore $B2B_STORE_NAME"
    commerceStoreId=$(get_record_id WebStore Name "$B2B_STORE_NAME")
    echo_keypair commerceStoreId "$commerceStoreId"
    defaultCategoryId=$(sfdx data query -q "SELECT Id FROM ProductCategory WHERE Name='$B2B_CATEGORY_NAME' LIMIT 1" -r csv | tail -n +2)
    echo_keypair defaultCategoryId "$defaultCategoryId"

    files_to_process=(
        "$QS_CONFIG_B2B_DIR/customMetadata/B2B_Store_Configuration.InternalAccountId.md-meta.xml"
        "$QS_CONFIG_B2B_DIR/customMetadata/RSM_Connector_Configuration.Effective_Account_Id.md-meta.xml"
        "$QS_CONFIG_B2B_DIR/customMetadata/RSM_Connector_Configuration.Org_Domain_Url.md-meta.xml"
        "$QS_CONFIG_B2B_DIR/customMetadata/RSM_Connector_Configuration.Store_Base_Url.md-meta.xml"
        "$QS_CONFIG_B2B_DIR/customMetadata/RSM_Connector_Configuration.StoreUrl.md-meta.xml"
        "$QS_CONFIG_B2B_DIR/customMetadata/RSM_Connector_Configuration.Tax_Engine_Id.md-meta.xml"
        "$QS_CONFIG_B2B_DIR/customMetadata/RSM_Connector_Configuration.Username.md-meta.xml"
        "$QS_CONFIG_B2B_DIR/customMetadata/RSM_Connector_Configuration.WebStoreID.md-meta.xml"
        "$QS_CONFIG_B2B_DIR/customMetadata/RSM_Connector_Configuration.Salesforce_Base_URL.md-meta.xml"
        "$QS_CONFIG_B2B_DIR/remoteSiteSettings/$NAMED_CREDENTIAL_SMB2B.remoteSite-meta.xml"
        "$QS_CONFIG_B2B_DIR/remoteSiteSettings/MyDomain.remoteSite-meta.xml"
    )

    for file in "${files_to_process[@]}"; do
        base_file=$(basename "$file")
        temp_file="${base_file%.*}_temp.xml"
        awk -v userId="$SFDX_USERID" -v defaultAccountId="$defaultAccountId" -v oauthUrl="$oauthUrl" -v storeBaseUrl="$storeBaseUrl" \
            -v b2bStoreName="$B2B_STORE_NAME" -v taxEngineId="$taxEngineId" -v username="$SFDX_USERNAME" -v commerceStoreId="$commerceStoreId" \
            -v orgBaseUrl="$orgBaseUrl" -v myDomain="$SFDX_MYDOMAIN" \
            '{gsub(/INSERT_INTERNAL_ACCOUNT_ID/, userId); gsub(/INSERT_EFFECTIVE_ACCOUNT_ID/, defaultAccountId); gsub(/INSERT_ORG_DOMAIN_URL/, "https://" oauthUrl); \
            gsub(/INSERT_STORE_BASE_URL/, "https://" storeBaseUrl); gsub(/INSERT_STORE_URL/, "https://" storeBaseUrl "/" b2bStoreName); gsub(/INSERT_TAX_ENGINE_ID/, taxEngineId); \
            gsub(/INSERT_USERNAME/, username); gsub(/INSERT_WEBSTORE_ID/, commerceStoreId); gsub(/INSERT_SALESFORCE_BASE_URL/, "https://" oauthUrl); \
            gsub(/INSERT_ORG_BASE_URL/, "https://" orgBaseUrl); gsub(/INSERT_MYDOMAIN_URL/, "https://" myDomain); print}' "$file" > "$temp_file"
        if [[ $base_file == *".remoteSite-meta.xml" ]]; then
            mv "$temp_file" "$SM_CONNECTED_APPS_DIR/default/remoteSiteSettings/$base_file"
        else
            mv "$temp_file" "$SM_CONNECTED_APPS_DIR/default/customMetadata/$base_file"
        fi
    done
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
      echo_keypair commerceStoreId $commerceStoreId
      standardPricebook2Id=$(sfdx data query -q "SELECT Id FROM Pricebook2 WHERE Name='$STANDARD_PRICEBOOK_NAME' AND IsStandard=true LIMIT 1" -r csv | tail -n +2)
      echo_keypair standardPricebook2Id $standardPricebook2Id
      smPricebook2Id=$(sfdx data query -q "SELECT Id FROM Pricebook2 WHERE Name='$CANDIDATE_PRICEBOOK_NAME' LIMIT 1" -r csv | tail -n +2)
      echo_keypair smPricebook2Id $smPricebook2Id
      commercePricebook2Id=$(sfdx data query -q "SELECT Id FROM Pricebook2 WHERE Name='$COMMERCE_PRICEBOOK_NAME' LIMIT 1" -r csv | tail -n +2)
      echo_keypair commercePricebook2Id $commercePricebook2Id
      if [ -z "$standardPricebook2Id" ] || [ -z "$smPricebook2Id" ] || [ -z "$commercePricebook2Id" ]; then
        echo_color red "Pricebook Ids not found. Exiting"
        exit 1
      fi
      for file in "PricebookEntry" "BuyerGroupPricebooks" "WebStoreBuyerGroups" "WebStoreCatalogs" "WebStorePricebooks"; do
        sed -e "s/\"Pricebook2Id\": \"STANDARD_PRICEBOOK_ID\"/\"Pricebook2Id\": \"${standardPricebook2Id}\"/g" \
            -e "s/\"Pricebook2Id\": \"SM_PRICEBOOK_ID\"/\"Pricebook2Id\": \"${smPricebook2Id}\"/g" \
            -e "s/\"Pricebook2Id\": \"COMMERCE_PRICEBOOK_ID\"/\"Pricebook2Id\": \"${commercePricebook2Id}\"/g" \
            -e "s/\"WebStoreId\": \"WEBSTORE_ID\"/\"WebStoreId\": \"${commerceStoreId}\"/g" \
            -e "s/\"SalesStoreId\": \"WEBSTORE_ID\"/\"SalesStoreId\": \"${commerceStoreId}\"/g" \
            data/${file}-template.json > data/${file}.json
      done
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
    sleep 2
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

  query() {
    sfdx data query -q "SELECT Id FROM $1 WHERE Name='$2' AND (Status='Draft' OR Status='Inactive') LIMIT 1" -r csv | tail -n +2
  }

  update_record() {
    sfdx data update record -s $1 -i $2 -v "$3 Status=Active"
  }

  keys=(
    defaultTaxTreatmentId
    defaultTaxPolicyId
    mockTaxTreatmentId
    mockTaxPolicyId
    defaultBillingTreatmentItemId
    defaultBillingTreatmentId
    defaultBillingPolicyId
    defaultPaymentTermId
  )

  values=(
    "$(query TaxTreatment "$DEFAULT_NO_TAX_TREATMENT_NAME")"
    "$(query TaxPolicy "$DEFAULT_NO_TAX_POLICY_NAME")"
    "$(query TaxTreatment "$DEFAULT_MOCK_TAX_TREATMENT_NAME")"
    "$(query TaxPolicy "$DEFAULT_MOCK_TAX_POLICY_NAME")"
    "$(query BillingTreatmentItem "$DEFAULT_BILLING_TREATMENT_ITEM_NAME")"
    "$(query BillingTreatment "$DEFAULT_BILLING_TREATMENT_NAME")"
    "$(query BillingPolicy "$DEFAULT_BILLING_POLICY_NAME")"
    "$(query PaymentTerm "$DEFAULT_PAYMENT_TERM_NAME")"
  )

  for i in "${!keys[@]}"; do
    echo_keypair ${keys[$i]} ${values[$i]}
  done

  echo_color green "Activating $DEFAULT_MOCK_TAX_TREATMENT_NAME"
  update_record TaxTreatment ${values[2]} "TaxPolicyId='${values[3]}'"

  echo_color green "Activating $DEFAULT_MOCK_TAX_POLICY_NAME"
  update_record TaxPolicy ${values[3]} "DefaultTaxTreatmentId='${values[2]}'"

  echo_color green "Activating $DEFAULT_PAYMENT_TERM_NAME"
  sfdx data update record -s PaymentTerm -i ${values[7]} -v "IsDefault=TRUE Status=Active"

  echo_color green "Activating $DEFAULT_BILLING_TREATMENT_NAME"
  update_record BillingTreatment ${values[5]} "BillingPolicyId='${values[6]}'"

  echo_color green "Activating $DEFAULT_BILLING_POLICY_NAME"
  update_record BillingPolicy ${values[6]} "DefaultBillingTreatmentId='${values[5]}'"

  echo_color green "Copying Default Billing Policy Id and Default Tax Policy Id to Product2.json"
  sed -e "s/\"BillingPolicyId\": \"PutBillingPolicyHere\"/\"BillingPolicyId\": \"${values[6]}\"/g;s/\"TaxPolicyId\": \"PutTaxPolicyHere\"/\"TaxPolicyId\": \"${values[3]}\"/g" data/Product2-template.json >data/Product2.json
}

function deploy_org_settings() {
  echo_color green "Deploying Org Settings"
  deploy "${BASE_DIR}/main/default/settings"
}

function create_commerce_store() {
  echo_color green "Creating Commerce Store"
  sfdx community create -n "$B2B_STORE_NAME" -t "B2B Commerce" -p "$B2B_STORE_NAME" -d "B2B Commerce (Aura) created by Subscription Management Quickstart"
}

# Function to build SOQL SELECT query
# USAGE EXAMPLE
# SELECT array
# select_fields=("Field1" "Field2" "Field3")
#
# WHERE array (supports AND, OR, NOT logical operators, and NOT IN subquery)
# where_conditions=("Field1 = 'value1'" "AND" "Field2 = 'value2'" "OR" "NOT Field3 = 'value3'" "AND" "Field4 NOT IN (SELECT Id FROM SubObject WHERE FieldX = 'valueX')")
#
# Build the SOQL query
# soql_query=$(build_soql_query "select_fields" "Opportunity" "where_conditions")
#
# Print the SOQL query
# echo "Generated SOQL query:"
# echo "$soql_query"
#
# EXPECTED OUTPUT
# SELECT Field1, Field2, Field3 FROM Opportunity WHERE Field1 = 'value1' AND Field2 = 'value2' OR NOT Field3 = 'value3' AND Field4 NOT IN (SELECT Id FROM SubObject WHERE FieldX = 'valueX')
#
# Execute the query using sfdx CLI (Salesforce CLI) if needed
# sfdx force:data:soql:query --query "$soql_query"
#

function build_soql_query() {
    select_fields_name="$1"
    select_object_name="$2"
    where_conditions_name="$3"

    soql_query="SELECT "

    select_fields_length="$(eval "echo \${#${select_fields_name}[@]}")"
    for i in $(seq 0 $(($select_fields_length - 1))); do
        field_value="$(eval "echo \${${select_fields_name}[$i]}")"
        soql_query="$soql_query$field_value"
        if [ $i -lt $(($select_fields_length - 1)) ]; then
            soql_query="$soql_query, "
        fi
    done

    soql_query="$soql_query FROM $select_object_name"

    where_conditions_length="$(eval "echo \${#${where_conditions_name}[@]}")"
    if [ $where_conditions_length -gt 0 ]; then
        soql_query="$soql_query WHERE "
        for i in $(seq 0 $(($where_conditions_length - 1))); do
            condition_value="$(eval "echo \${${where_conditions_name}[$i]}")"
            soql_query="$soql_query$condition_value"
            if [ $i -lt $(($where_conditions_length - 1)) ]; then
                soql_query="$soql_query "
            fi
        done
    fi

    echo "$soql_query"
}