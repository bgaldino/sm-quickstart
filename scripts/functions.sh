#!/bin/bash
# shellcheck shell=bash

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

function echo_color() {
  typeset color="$1"
  shift
  typeset color_code
  color_code=$(eval "echo \${$(echo "$color" | tr '[:lower:]' '[:upper:]'):-}")
  if [[ -z "$color_code" ]]; then
    color_code="${NOCOLOR}"
  fi
  printf "%b%s%b\n" "${color_code}" "$*" "${NOCOLOR}"
}

function reset_color() {
  typeset string="$1"
  printf "%b%s%b\n" "${NOCOLOR}" "${string}" "${NOCOLOR}"
}

function echo_keypair() {
  printf "${CYAN}%s${NOCOLOR}:${ORANGE}%s${NOCOLOR}\n" "$1" "$2"
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

  echo_color seafoam "${disclaimer_msg[0]}"
  echo_color seafoam "${disclaimer_msg[1]}"
  echo_color red "${disclaimer_msg[2]}"

  PS3=$(echo_color seafoam "Do you agree to these conditions? (use numbers): ")
  typeset option1
  typeset option2
  typeset option3
  option1=$(echo_color cyan "Yes, proceed with setup including Experience Cloud")
  option2=$(echo_color cyan "No, proceed with setup without Experience Cloud")
  option3=$(echo_color cyan "No, do not proceed and exit setup")

  select acceptDisclaimer in "$option1" "$option2" "$option3"; do
    case $REPLY in
    1)
      export createCommunity=true
      export includeCommunity=true
      sed -i '' '/^sm\/sm-my-community$/d' .forceignore
      sed -i '' '/^sm\/sm-community-template$/d' .forceignore
      if ! grep -q "sm/sm-nocommunity" .forceignore; then
        echo "sm/sm-nocommunity" >>.forceignore
      fi
      export acceptDisclaimer=1
      break
      ;;
    2)
      export createCommunity=false
      export includeCommunity=false
      if ! grep -q "sm/sm-my-community" .forceignore; then
        echo "sm/sm-my-community" >>.forceignore
      fi
      if ! grep -q "sm/sm-community-template" .forceignore; then
        echo "sm/sm-community-template" >>.forceignore
      fi
      sed -i '' '/^sm\/sm-nocommunity$/d' .forceignore
      export acceptDisclaimer=1
      break
      ;;
    3)
      export acceptDisclaimer=0
      error_and_exit "Disclaimer conditions not accepted - exiting"
      ;;
    *)
      echo_color red "Invalid input. Please enter a value between 1 and 3."
      ;;
    esac
  done
}

function prompt_to_create_scratch() {
  read -rp "$(echo_color seafoam 'Would you like to create a scratch org? (y/n) > ')" answer
  case ${answer:0:1} in
  y | Y)
    createScratch=1
    orgType=1
    ;;
  n | N)
    createScratch=0
    ;;
  *)
    echo_color red "Invalid input. Please enter y or n."
    prompt_to_create_scratch
    ;;
  esac
}

function prompt_for_scratch_edition() {
  echo_color seafoam "What type of scratch org would you like to create?"

  options=(
    "$(echo_color cyan "Developer")"
    "$(echo_color cyan "Enterprise")"
    "$(echo_color cyan "Enterprise with Rebate Management")"
  )

  PS3=$(echo_color seafoam "Please enter the number corresponding to the scratch org edition you would like to create: ")

  select scratchEdition in "${options[@]}"; do
    case $REPLY in
    1)
      edition="Developer"
      ;;
    2)
      edition="Enterprise"
      ;;
    3)
      edition="Enterprise with Rebate Management"
      ;;
    *)
      echo_color magenta "Invalid selection! Please enter a number between 1 and ${#options[@]}."
      continue
      ;;
    esac
    if [[ " ${options[*]} " == *" $scratchEdition "* ]]; then
      echo ""
      echo_color rose "You have selected as your scratch org edition: $scratchEdition"
      break
    fi
  done
}

function prompt_for_scratch_alias() {
  while true; do
    read -rp "$(echo_color seafoam 'Please enter an alias for your scratch org (e.g. my_project_dev) > ')" scratchAlias

    # Set default value if $scratchAlias is empty
    scratchAlias="${scratchAlias:-myScratchOrg}"

    # Check that $scratchAlias contains only alphanumeric characters and underscores
    if ! [[ "$scratchAlias" =~ ^[[:alnum:]_]+$ ]]; then
      echo_color red "Error: Alias must contain only letters, numbers, and underscores."
      continue
    fi

    break
  done
}

function prompt_for_scratch_org() {
  prompt_to_create_scratch

  while [ "$createScratch" = "1" ] && [[ ! $scratchEdition =~ [012] ]]; do
    if [[ ! $scratchEdition =~ [012] ]]; then
      prompt_for_scratch_edition
    fi

    if [ -z "$scratchAlias" ]; then
      prompt_for_scratch_alias
    fi
  done

  if [ "$createScratch" = "1" ]; then
    scratchAlias="${scratchAlias:-$scratchEdition}"
    echo_color rose "Creating ${edition} scratch org with alias ${scratchAlias}. This may take up to 10 minutes."
    create_scratch_org "$scratchAlias"
  fi
}

function prompt_for_org_type() {
  echo_color seafoam "What type of org are you deploying to?"
  echo_color cyan "[0] Production"
  echo_color cyan "[1] Scratch"
  echo_color cyan "[2] Sandbox"
  echo_color cyan "[3] Falcon (test1 - Internal SFDC only)"
  echo_color cyan "[4] Developer"
  read -rp "$(echo_color seafoam 'Please enter the org type you would like to set up > ')" orgType
}

function prompt_for_falcon_instance() {
  local options=("NA46 (main branch)" "NA45 (main-2 branch)")
  echo_color seafoam "Which falcon instance are you using?"
  for i in "${!options[@]}"; do
    echo_color cyan "[$i] ${options[$i]}"
  done
  read -rp "$(echo_color seafoam 'Please enter the falcon instance you would like to target > ')" falconInstance
  export falconInstance="$falconInstance"
}

function prompt_to_install_connector() {
  while true; do
    read -rp "$(echo_color seafoam 'Would you like to install the Subscription Management/B2B Commerce connector? (y/n) > ')" answer
    case ${answer:0:1} in
    y | Y)
      export includeCommerceConnector=true
      orgType=1
      break
      ;;
    n | N)
      export includeCommerceConnector=false
      break
      ;;
    *)
      echo_color red "Invalid input. Please enter y or n."
      ;;
    esac
  done
  #return "$includeCommerceConnector"
}

function prompt_to_create_commerce_community() {
  while true; do
    read -rp "$(echo_color seafoam 'Would you like to create a B2B Commerce Digital Experience (Community)? (y/n) > ')" answer
    case ${answer:0:1} in
    y | Y)
      export createConnectorStore=true
      orgType=1
      break
      ;;
    n | N)
      export createConnectorStore=false
      break
      ;;
    *)
      echo_color red "Invalid input. Please enter y or n."
      ;;
    esac
  done
}

function prompt_to_install_commerce_store() {
  while true; do
    read -rp "$(echo_color seafoam 'Would you like to include and publish the Subscription Management/B2B Commerce connector configured store template? (y/n) > ')" answer
    case ${answer:0:1} in
    y | Y)
      export includeConnectorStoreTemplate=true
      orgType=1
      break
      ;;
    n | N)
      export includeConnectorStoreTemplate=false
      break
      ;;
    *)
      echo_color red "Invalid input. Please enter y or n."
      ;;
    esac
  done
}

function set_user_email {
  SFDX_USER_EMAIL=$(sfdx data query -q "SELECT Email from User WHERE Username='$1' LIMIT 1" -r csv | tail -n +2)
  export SFDX_USER_EMAIL
  echo_color green "Email: ${SFDX_USER_EMAIL:-unknown} for username $1"
}

function set_sfdx_user_info() {
  typeset tmpfile
  tmpfile=$(mktemp || exit 1)
  if ! sfdx org display user --json >"$tmpfile"; then
    echo "Failed to retrieve SFDX user info"
    rm "$tmpfile"
    return 1
  fi

  SFDX_USERNAME=$(grep -o '"username": *"[^"]*' "$tmpfile" | grep -o '[^"]*$')
  SFDX_USERID=$(grep -o '"id": *"[^"]*' "$tmpfile" | grep -o '[^"]*$')
  SFDX_ORGID=$(grep -o '"orgId": *"[^"]*' "$tmpfile" | grep -o '[^"]*$')
  SFDX_INSTANCEURL=$(grep -o '"instanceUrl": *"[^"]*' "$tmpfile" | grep -o '[^"]*$')
  SFDX_MYDOMAIN=${SFDX_INSTANCEURL#*\/\/}
  SFDX_MYSUBDOMAIN=${SFDX_MYDOMAIN%%.*}

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
    defFile="config/project-scratch-def.json"
    ;;
  2)
    defFile="config/enterprise-rebates-scratch-def.json"
    ;;
  esac

  if ! sf org create scratch -f $defFile -a "$alias" -d -y 30 -w 15; then
    echo "Failed to create scratch org"
    exit 1
  fi
}

function deploy() {
  if [[ $(echo "$(sfdx_version) >= $SFDX_RC_VERSION" | bc) -eq 1 ]]; then
    sfdx project deploy start -g -c -r -d "$1" -a "$API_VERSION" -l NoTestRun
  else
    sf deploy metadata -g -c -r -d "$1" -a "$API_VERSION" -l NoTestRun
  fi
}

function install_package() {
  sfdx package install -p "$1"
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

function check_sfdx_commerce_plugin {
  if sfdx plugins | grep -q '@salesforce/commerce'; then
    echo "The @salesforce/commerce plugin is installed"
    export commerce_plugin=true
  else
    echo "The @salesforce/commerce plugin is not installed"
    echo "Installing the @salesforce/commerce plugin..."
    sfdx plugins install @salesforce/commerce
    echo "The @salesforce/commerce plugin has been installed"
    export commerce_plugin=true
  fi
}

function sfdx_version() {
  sfdx --version | awk '/sfdx-cli/{print $2}' FS=/ | cut -d . -f1,2 | bc
}

function set_org_api_version {
  if [[ $(echo "$(sfdx_version) >= $SFDX_RC_VERSION" | bc) -eq 1 ]]; then
    API_VERSION=$(sfdx org display --json | grep -o '"apiVersion": *"[^"]*' | grep -o '[^"]*$')
  else
    API_VERSION=$(sfdx force:org:display --json | grep -o '"apiVersion": *"[^"]*' | grep -o '[^"]*$')
  fi
  echo_keypair "API Version" "$API_VERSION"
}

function update_org_api_version {
  set_org_api_version
  local sfdx_project_file="./sfdx-project.json"
  if [ -f "$sfdx_project_file" ]; then
    local current_version
    current_version=$(cat "$sfdx_project_file" | sed -n 's/.*"sourceApiVersion":[[:space:]]*"\([0-9]*\)".*/\1/p')
    if [ "$API_VERSION" != "$current_version" ]; then
      echo_color green "Updating the sfdx-project.json file with the org API version..."
      sed -i '' "s/\"sourceApiVersion\":.*/\"sourceApiVersion\": \"$API_VERSION\",/" "$sfdx_project_file"
      echo_color green "The sfdx-project.json file has been updated with the org API version"
    else
      echo_color green "The sfdx-project.json file is already up to date with the org API version"
    fi
  else
    echo_color green "The sfdx-project.json file was not found"
  fi
}

function replace_api_version {
  find "$DEFAULT_DIR" -type f -name "*.xml" -not -path "$BASE_DIR/libs/*" -not -path "$COMMERCE_CONNECTOR_LIBS_DIR/*" -exec sh -c 'if grep -q "<apiVersion>$API_VERSION</apiVersion>" "$0"; then exit 1; else sed -i "" "s|<apiVersion>[^<]*</apiVersion>|<apiVersion>'"$API_VERSION"'</apiVersion>|g" "$0"; fi' {} \;
}

function list_permission_sets_for_api_version {
  local api_version=$1
  echo "Permission sets for API version $api_version:"
  for key in "${!smPermissionSetGroups[@]}"; do
    local value=${smPermissionSetGroups[$key]}
    if (($(echo "$value <= $api_version" | bc -l))); then
      echo "- $key"
    fi
  done
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
  echo_keypair storeBaseUrl "$storeBaseUrl"
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

  echo_keypair orgBaseUrl "$orgBaseUrl"
  echo_keypair oauthUrl "$oauthUrl"
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
      sfdx org assign permsetlicense -n "$i"
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
      sfdx org assign permset -n "$i"
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
  typeset permsetCount
  permsetCount=$(count_permset "$joined")
  permsets="${ps[*]}"
  if [[ $permsetCount -ne $len ]]; then
    echo_color green "Permsets Missing - Attempting to Assign All Permsets"
    sfdx org assign permset -n $permsets
  else
    echo_color green "All Permsets Assigned"
  fi
}

function check_qbranch() {
  if ((orgType == 0)); then
    echo_color green "Checking for QBranch Utils"
    local qbranch_ns
    qbranch_ns=$(sfdx package installed list --json | awk '/"SubscriberPackageNamespace": "qbranch"/{print $2}')
    if [[ -n $qbranch_ns ]]; then
      echo_color cyan "QBranch Utils Found - Querying for CDO/RCIDO"
      qbranchId=$(sfdx data query -q "SELECT Identifier__c FROM QLabs__mdt LIMIT 1" -r csv | tail -n +2)
      case $qbranchId in
      "$CDO_ID" | "$MFGIDO_ID")
        echo_color cyan "QBranch CDO/SDO Found"
        export cdo=1
        ;;
      "$RCIDO_ID")
        echo_color cyan "QBranch Revenue Cloud IDO Found"
        export rcido=1
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
            gsub(/INSERT_ORG_BASE_URL/, "https://" orgBaseUrl); gsub(/INSERT_MYDOMAIN_URL/, "https://" myDomain); print}' "$file" >"$temp_file"
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
            gsub(/INSERT_ORG_BASE_URL/, "https://" orgBaseUrl); gsub(/INSERT_MYDOMAIN_URL/, "https://" myDomain); print}' "$file" >"$temp_file"
    if [[ $base_file == *".remoteSite-meta.xml" ]]; then
      mv "$temp_file" "$SM_CONNECTED_APPS_DIR/default/remoteSiteSettings/$base_file"
    else
      mv "$temp_file" "$SM_CONNECTED_APPS_DIR/default/customMetadata/$base_file"
    fi
  done
}

function populate_price_data_commerce() {
  echo_color green "Getting Standard and Commerce Pricebooks for Pricebook Entries and replacing in data files"
  commerceStoreId=$(get_record_id WebStore Name "$B2B_STORE_NAME")
  echo_keypair commerceStoreId "$commerceStoreId"
  standardPricebook2Id=$(sfdx data query -q "SELECT Id FROM Pricebook2 WHERE Name='$STANDARD_PRICEBOOK_NAME' AND IsStandard=true LIMIT 1" -r csv | tail -n +2)
  echo_keypair standardPricebook2Id "$standardPricebook2Id"
  smPricebook2Id=$(sfdx data query -q "SELECT Id FROM Pricebook2 WHERE Name='$CANDIDATE_PRICEBOOK_NAME' LIMIT 1" -r csv | tail -n +2)
  echo_keypair smPricebook2Id "$smPricebook2Id"
  commercePricebook2Id=$(sfdx data query -q "SELECT Id FROM Pricebook2 WHERE Name='$COMMERCE_PRICEBOOK_NAME' LIMIT 1" -r csv | tail -n +2)
  echo_keypair commercePricebook2Id "$commercePricebook2Id"
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
      data/${file}-template.json >data/${file}.json
  done
}

function populate_price_data() {
  echo_color green "Getting Standard and Subscription Management Pricebooks for Pricebook Entries and replacing in data files"

  # Store both pricebook IDs in an associative array.
  pricebook_ids=(
    ["STANDARD_PRICEBOOK_NAME"]="$STANDARD_PRICEBOOK_NAME"
    ["CANDIDATE_PRICEBOOK_NAME"]="$CANDIDATE_PRICEBOOK_NAME"
  )
  # Get the IDs of the required pricebooks and store them in the array.
  for key in "${!pricebook_ids[@]}"; do
    value="${pricebook_ids[$key]}"
    id=$(sfdx data query -q "SELECT Id FROM Pricebook2 WHERE Name='$value' AND IsStandard=($key='STANDARD_PRICEBOOK_NAME')" -r csv -u "$TARGET_ORG_ALIAS" | tr -d '\r')
    if [ -z "$id" ]; then
      echo_color red "Pricebook $value not found. Exiting"
      exit 1
    fi
    pricebook_ids["$key"]="$id"
  done

  # Replace the Pricebook IDs in template files with real IDs.
  for file in data/*-template.json; do
    output_file="${file/-template/}"
    sed \
      -e "s/\"Pricebook2Id\": \"STANDARD_PRICEBOOK_ID\"/\"Pricebook2Id\": \"${pricebook_ids[STANDARD_PRICEBOOK_NAME]}\"/g" \
      -e "s/\"Pricebook2Id\": \"SM_PRICEBOOK_ID\"/\"Pricebook2Id\": \"${pricebook_ids[CANDIDATE_PRICEBOOK_NAME]}\"/g" \
      "$file" >"$output_file"
  done
}

function check_for_existing_tax_data() {
  defaultBillingTreatmentItemId=$(sfdx data query -q "SELECT Id FROM BillingTreatmentItem WHERE Name='$DEFAULT_BILLING_TREATMENT_ITEM_NAME' LIMIT 1" -r csv | tail -n +2)
  echo_keypair defaultBillingTreatmentItemId "$defaultBillingTreatmentItemId"
  if [ -z "$defaultBillingTreatmentItemId" ]; then
    echo_color yellow "Default Billing Treatment Item does not exist. Loading data"
    return 1 # Return false
  else
    echo_color yellow "Default Billing Treatment Item already exists. Skipping data load"
    return 0 # Return true
  fi
}

function check_for_existing_price_data() {
  defaultOneTimeProductPricebookEntryId=$(sfdx data query -q "SELECT Id from PricebookEntry WHERE Product2Id IN (SELECT Id FROM Product2 WHERE NAME = '$DEFAULT_ONE_TIME_PRODUCT')" -r csv | tail -n +2)
  echo_keypair defaultOneTimeProductPricebookEntryId "$defaultOneTimeProductPricebookEntryId"
  if [ -z "$defaultOneTimeProductId" ]; then
    echo_color yellow "Default One Time Product Pricebook Entry does not exist. Loading data"
    return 1
  else
    echo_color yellow "Default One Time Product Pricebook Entry already exists. Skipping data load"
    return 0
  fi
}

function check_for_existing_default_account_data() {
  defaultAccountId=$(get_record_id Account Name "$DEFAULT_ACCOUNT_NAME")
  echo_keypair defaultAccountId "$defaultAccountId"
  if [ -z "$defaultAccountId" ]; then
    echo_color yellow "Default Account does not exist. Loading data"
    return 1
  else
    echo_color yellow "Default Account already exists. Skipping data load"
    return 0
  fi
}

function insert_data() {
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
  if [ "$includeCommerceConnector" == true ]; then
    echo_color green "Getting Standard and Commerce Pricebooks for Pricebook Entries and replacing in data files"
    commerceStoreId=$(get_record_id WebStore Name "$B2B_STORE_NAME")
    echo_keypair commerceStoreId "$commerceStoreId"
    standardPricebook2Id=$(sfdx data query -q "SELECT Id FROM Pricebook2 WHERE Name='$STANDARD_PRICEBOOK_NAME' AND IsStandard=true LIMIT 1" -r csv | tail -n +2)
    echo_keypair standardPricebook2Id "$standardPricebook2Id"
    smPricebook2Id=$(sfdx data query -q "SELECT Id FROM Pricebook2 WHERE Name='$CANDIDATE_PRICEBOOK_NAME' LIMIT 1" -r csv | tail -n +2)
    echo_keypair smPricebook2Id "$smPricebook2Id"
    commercePricebook2Id=$(sfdx data query -q "SELECT Id FROM Pricebook2 WHERE Name='$COMMERCE_PRICEBOOK_NAME' LIMIT 1" -r csv | tail -n +2)
    echo_keypair commercePricebook2Id "$commercePricebook2Id"
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
        data/${file}-template.json >data/${file}.json
    done
    #TODO: Add a check to see if the product data already exists, and if so obtain IDs and update the data files or just error and exit
    sfdx data import tree -p data/data-plan-commerce.json
    echo_color green "Updating Webstore $B2B_STORE_NAME StrikethroughPricebookId to $commercePricebook2Id"
    sfdx data update record -s WebStore -i "$commerceStoreId" -v "StrikethroughPricebookId='$commercePricebook2Id'"
  else
    sfdx data import tree -p data/data-plan-2.json
  fi
  #sfdx data import tree -p data/data-plan-2-base.json
  echo_color green "Pushing Default Account & Contact"
  sfdx data import tree -p data/data-plan-3.json
  sleep 2
  echo_color purple "All Data Successfully Inserted.  Setup can now be safely restarted in case of failure once insertData is manually set to false."
}

function create_tax_engine() {
  echo_color green "Getting Id for ApexClass $TAX_PROVIDER_CLASS_NAME"
  taxProviderClassId=$(get_record_id ApexClass Name "$TAX_PROVIDER_CLASS_NAME")
  echo_keypair taxProviderClassId "$taxProviderClassId"
  echo_color green "Checking for existing TaxEngineProvider $TAX_PROVIDER_CLASS_NAME"
  taxEngineProviderId=$(get_record_id TaxEngineProvider DeveloperName "$TAX_PROVIDER_CLASS_NAME")
  if [ -z "$taxEngineProviderId" ]; then
    echo_color green "Creating TaxEngineProvider $TAX_PROVIDER_CLASS_NAME"
    sfdx data create record -s TaxEngineProvider -v "DeveloperName='$TAX_PROVIDER_CLASS_NAME' MasterLabel='$TAX_PROVIDER_CLASS_NAME' ApexAdapterId=$taxProviderClassId"
    echo_color green "Getting Id for TaxEngineProvider $TAX_PROVIDER_CLASS_NAME"
    taxEngineProviderId=$(get_record_id TaxEngineProvider DeveloperName "$TAX_PROVIDER_CLASS_NAME")
  fi
  echo_keypair taxEngineProviderId "$taxEngineProviderId"

  echo_color green "Getting Id for NamedCredential $NAMED_CREDENTIAL_MASTER_LABEL"
  taxMerchantCredentialId=$(get_record_id NamedCredential DeveloperName "$NAMED_CREDENTIAL_MASTER_LABEL")
  echo_keypair taxMerchantCredentialId "$taxMerchantCredentialId"
  echo_color green "Checking for existing TaxEngine $TAX_PROVIDER_CLASS_NAME"
  taxEngineId=$(get_record_id TaxEngine TaxEngineName "$TAX_PROVIDER_CLASS_NAME")
  if [ -z "$taxEngineId" ]; then
    echo_color green "Creating TaxEngine $TAX_PROVIDER_CLASS_NAME"
    sfdx data create record -s TaxEngine -v "TaxEngineName='$TAX_PROVIDER_CLASS_NAME' MerchantCredentialId=$taxMerchantCredentialId TaxEngineProviderId=$taxEngineProviderId Status='Active' SellerCode='Billing2' TaxEngineCity='San Francisco' TaxEngineCountry='United States' TaxEnginePostalCode='94105' TaxEngineState='California'"
    echo_color green "Getting Id for TaxEngine $TAX_PROVIDER_CLASS_NAME"
    taxEngineId=$(get_record_id TaxEngine TaxEngineName "$TAX_PROVIDER_CLASS_NAME")
  fi
  echo_color green "$TAX_PROVIDER_CLASS_NAME Tax Engine Id:"
  echo_keypair taxEngineId "$taxEngineId"
}

function create_stripe_gateway() {
  echo_color green "Creating Stripe Payment Gateway"
  sfdx data create record -s PaymentGateway -v "MerchantCredentialId=$stripeNamedCredentialId PaymentGatewayName=$STRIPE_PAYMENT_GATEWAY_NAME PaymentGatewayProviderId=$stripePaymentGatewayProviderId Status=Active"
}

function register_commerce_services() {
  echo_color green "Registering Commerce Services"
  commerceStoreId=$(get_record_id WebStore Name "$B2B_STORE_NAME")
  echo_keypair "Commerce Store Id" "$commerceStoreId"
  stripeApexClassId=$(get_record_id ApexClass Name "$STRIPE_GATEWAY_ADAPTER_NAME")
  echo_keypair "Stripe Apex Class Id" "$stripeApexClassId"
  stripePaymentGatewayProviderId=$(get_record_id PaymentGatewayProvider DeveloperName "$STRIPE_GATEWAY_PROVIDER_NAME")
  echo_keypair "Stripe Payment Gateway Provider Id" "$stripePaymentGatewayProviderId"
  stripeNamedCredentialId=$(get_record_id NamedCredential MasterLabel "$STRIPE_NAMED_CREDENTIAL")
  echo_keypair "Stripe Named Credential Id" "$stripeNamedCredentialId"
  export commerceStoreId stripeApexClassId stripePaymentGatewayProviderId stripeNamedCredentialId

  declare -a apex_class_ids
  for class_name in $INVENTORY_INTERFACE $PRICE_INTERFACE $SHIPMENT_INTERFACE $TAX_INTERFACE; do
    apex_class_ids["$class_name"]=$(get_record_id ApexClass Name "$class_name")
    echo_keypair "$class_name Apex Class Id" "${apex_class_ids["$class_name"]}"
  done

  for service in INVENTORY SHIPMENT TAX; do

    service_name=$(eval echo \$"${service}_EXTERNAL_SERVICE")
    echo_keypair "$service_name Service Name" "$service_name"
    service_type="$(tr '[:lower:]' '[:upper:]' <<<"${service:0:1}")${service:1}"
    echo_keypair "$service_name Service Type" "$service_type"
    service_class=$(get_record_id ApexClass Name "$(eval echo "\$${service}_INTERFACE")")
    echo_keypair "$service_name Service Class" "$service_class"
    service_id=$(get_record_id RegisteredExternalService DeveloperName "$service_name")

    echo_keypair "$service_name Service Id" "$service_id"

    if [ -z "$service_id" ]; then
      service_id=$(sfdx data create record -s RegisteredExternalService -v "DeveloperName=$service_name ExternalServiceProviderId=$service_class ExternalServiceProviderType=$service_type MasterLabel=$service_name" --json | grep -Eo '"id": "([^"]*)"' | awk -F':' '{print $2}' | tr -d ' "')
      echo_keypair "$service_name Service Id" "$service_id"
    fi
    sfdx data create record -s StoreIntegratedService -v "integration=$service_id StoreId=$commerceStoreId ServiceProviderType=$service_type"
  done

  serviceMappingId=$(sfdx data query -q "SELECT Id FROM StoreIntegratedService WHERE StoreId='$commerceStoreId' AND ServiceProviderType='Payment' LIMIT 1" -r csv | tail -n +2)
  echo_keypair "Payment Service Mapping Id" "$serviceMappingId"

  if [ -n "$serviceMappingId" ]; then
    sfdx data delete record -s StoreIntegratedService -i "$serviceMappingId"
  fi

  paymentGatewayId=$(get_record_id PaymentGateway PaymentGatewayName "$PAYMENT_GATEWAY_NAME")
  echo_keypair "Payment Gateway Id" "$paymentGatewayId"
  sfdx data create record -s StoreIntegratedService -v "Integration=$paymentGatewayId StoreId=$commerceStoreId ServiceProviderType=Payment"
}

function activate_tax_and_billing_policies() {
  echo_color green "Activating Tax and Billing Policies"

  query() {
    sfdx data query -q "SELECT Id FROM $1 WHERE Name='$2' AND (Status='Draft' OR Status='Inactive') LIMIT 1" -r csv | tail -n +2
  }

  update_record() {
    sfdx data update record -s "$1" -i "$2" -v "$3 Status=Active"
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
    echo_keypair "${keys[$i]}" "${values[$i]}"
  done

  echo_color green "Activating $DEFAULT_MOCK_TAX_TREATMENT_NAME"
  update_record TaxTreatment "${values[2]}" "TaxPolicyId='${values[3]}'"

  echo_color green "Activating $DEFAULT_MOCK_TAX_POLICY_NAME"
  update_record TaxPolicy "${values[3]}" "DefaultTaxTreatmentId='${values[2]}'"

  echo_color green "Activating $DEFAULT_PAYMENT_TERM_NAME"
  sfdx data update record -s PaymentTerm -i "${values[7]}" -v "IsDefault=TRUE Status=Active"

  echo_color green "Activating $DEFAULT_BILLING_TREATMENT_NAME"
  update_record BillingTreatment "${values[5]}" "BillingPolicyId='${values[6]}'"

  echo_color green "Activating $DEFAULT_BILLING_POLICY_NAME"
  update_record BillingPolicy "${values[6]}" "DefaultBillingTreatmentId='${values[5]}'"

  echo_color green "Copying Default Billing Policy Id and Default Tax Policy Id to Product2.json"
  sed -e "s/\"BillingPolicyId\": \"PutBillingPolicyHere\"/\"BillingPolicyId\": \"${values[6]}\"/g;s/\"TaxPolicyId\": \"PutTaxPolicyHere\"/\"TaxPolicyId\": \"${values[3]}\"/g" data/Product2-template.json >data/Product2.json
}

function deploy_org_settings() {
  echo_color green "Deploying Org Settings"
  deploy "${BASE_DIR}/main/default/settings"
}

function create_commerce_store() {
  echo_color green "Creating Commerce Store"
  if [ "$orgType" != 4 ]; then
    if [[ $(echo "$API_VERSION >= 58.0" | bc) -eq 1 ]]; then
      sf community create -n "$B2B_STORE_NAME" -t "$B2B_AURA_TEMPLATE_NAME" -p "$B2B_STORE_NAME" -d "B2B Commerce (Aura) created by Subscription Management Quickstart"
    else
      sf community create -n "$B2B_STORE_NAME" -t "$B2B_TEMPLATE_NAME" -p "$B2B_STORE_NAME" -d "B2B Commerce (Aura) created by Subscription Management Quickstart"
    fi
  else
    sf community create -n "$B2B_STORE_NAME" -t "$B2B_LWR_TEMPLATE_NAME" -p "$B2B_STORE_NAME" -d "B2B Commerce (LWR) created by Subscription Management Quickstart"
  fi
}

function create_sm_community() {
  echo_color green "Creating Subscription Management Customer Account Portal Digital Experience"
  sf community create -n "$COMMUNITY_NAME" -t "$COMMUNITY_TEMPLATE_NAME" -p "$COMMUNITY_NAME" -d "Customer Portal created by Subscription Management Quickstart"
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

build_soql_query() {
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
