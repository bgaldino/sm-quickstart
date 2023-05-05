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

function get_sfdx() {
  case $(uname -o | tr '[:upper:]' '[:lower:]') in
  msys)
    echo "cmd //C sfdx"
    ;;
  *)
    echo "sfdx"
    ;;
  esac
}

sfdx=$(get_sfdx)

function echo_color() {
  local color="$1"
  shift
  local color_code
  color_code=$(eval "echo \${$(echo "$color" | tr '[:lower:]' '[:upper:]'):-}")
  if [[ -z "$color_code" ]]; then
    color_code="${NOCOLOR}"
  fi
  printf "%b%s%b\n" "${color_code}" "$*" "${NOCOLOR}"
}

function reset_color() {
  local string="$1"
  printf "%b%s%b\n" "${NOCOLOR}" "${string}" "${NOCOLOR}"
}

function echo_keypair() {
  printf "${CYAN}%s${NOCOLOR}:${ORANGE}%s${NOCOLOR}\n" "$1" "$2"
}

function error_and_exit() {
  echo "$1"
  exit 1
}

function remove_line_from_forceignore() {
  local pattern="$1"
  if ! grep -qr "$pattern" .forceignore; then
    echo "$pattern" >>.forceignore
  fi
  case $(uname -o | tr '[:upper:]' '[:lower:]') in
  darwin)
    sed -i '' "/^$(sed 's/[\/&]/\&/g' <<<"$pattern")\$/d" .forceignore
    ;;
  gnu/linux | linux | msys)
    sed -i "/^$(sed 's/[\/&]/\&/g' <<<"$pattern")\$/d" .forceignore
    ;;
  cygwin*)
    powershell -Command "(gc .forceignore) -notmatch '^$(sed 's/[\/&]/\&/g' <<<"$pattern")\$' | Out-File .forceignore"
    ;;
  *)
    echo "Unsupported operating system: $OSTYPE" && exit 1
    ;;
  esac
}

function add_line_to_forceignore() {
  local pattern="$1"
  if ! grep -qr "^${pattern}$" .forceignore; then
    echo "$pattern" >>.forceignore
  fi
}

function prompt_to_accept_disclaimer() {
  local disclaimer_msg=(
    "This setup can create an example storefront that is built using Experience Cloud to faciliate development with and understanding of Subscription Management."
    "Because Subscription Management isn't yet licensed for use with Experience Cloud, the Customer Account Portal that is created as part of this setup will execute some operations to access the Subscription Management APIs as a privleged internal user for development purposes."
    "This may not be used in a licensed and active production org - doing so may violate your license agreement and create a security risk."
  )

  echo_color seafoam "${disclaimer_msg[0]}"
  echo_color seafoam "${disclaimer_msg[1]}"
  echo_color red "${disclaimer_msg[2]}"

  PS3=$(echo_color seafoam "Do you agree to these conditions? (use numbers): ")
  local options=(
    "$(echo_color cyan 'Yes, proceed with setup including Experience Cloud')"
    "$(echo_color cyan 'No, proceed with setup without Experience Cloud')"
    "$(echo_color cyan 'No, do not proceed and exit setup')"
  )

  select acceptDisclaimer in "${options[@]}"; do
    case $REPLY in
    1)
      export createCommunity=true
      export includeCommunity=true
      remove_line_from_forceignore "sm/sm-my-community"
      remove_line_from_forceignore "sm/sm-community-template"
      export acceptDisclaimer=1
      break
      ;;
    2)
      export createCommunity=false
      export includeCommunity=false
      remove_line_from_forceignore "sm/sm-nocommunity"
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
      configOption=1
      ;;
    2)
      edition="Enterprise"
      configOption=2
      ;;
    3)
      edition="Enterprise with Rebate Management"
      configOption=3
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
    create_scratch_org "$scratchAlias" "$scratchEdition"
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
}

function get_consumer_key_for_connected_app() {
  local connectedApp="$B2B_CONNECTED_APP"
  local certificate="$B2B_CERTIFICATE"
  sfdx project retrieve start -d "$connectedApp" -d "$certificate" -t temp_folder
  unzip_completed=false
  while [ $unzip_completed == false ]; do
    if [ -f temp_folder/unpackaged.zip ]; then
      unzip -qo temp_folder/unpackaged.zip -d temp_folder
      unzip_completed=true
    else
      sleep 1
    fi
  done
  consumerKey=$(awk -F'<consumerKey>|</consumerKey>' '/<consumerKey>/ {print $2}' temp_folder/unpackaged/connectedApps/"$CONNECTED_APP_NAME_SMB2B".connectedApp)
  cert="$(sed -n '/BEGIN CERTIFICATE/,/END CERTIFICATE/p' temp_folder/unpackaged/certs/"$B2B_CERTIFICATE_NAME".crt | sed '1d;$d' | tr -d '[:space:]')"
  update_b2bsm_connected_app "$cert" "$consumerKey" "$SFDX_USER_EMAIL"
  rm -rf temp_folder
  echo_keypair consumerKey "$consumerKey"
  echo_keypair certificate "$cert"
}

function update_b2bsm_connected_app() {
  # Store the certificate, consumer key, and email variables in new variables for readability
  certificate_value=$1
  consumer_key_value=$2
  email_value=$3

  # Set the name of the meta.xml file
  meta_file="$B2B_CONNECTED_APP"

  # Use sed to insert the email value before the oauthConfig section, and then insert the certificate and consumer key values into the oauthConfig section.
  case $(uname -s | tr '[:upper:]' '[:lower:]') in
    linux* | gnu/linux*)
      sed -i "s#<contactEmail>.*</contactEmail>#<contactEmail>${email_value}</contactEmail>#g" "$meta_file"
      sed -i "s#</oauthConfig#<certificate>${certificate_value}</certificate><consumerKey>${consumer_key_value}</consumerKey></oauthConfig#g" "$meta_file"
      ;;
    darwin*)
      sed -i '' "s#<contactEmail>.*</contactEmail>#<contactEmail>${email_value}</contactEmail>#g" "$meta_file"
      sed -i '' "s#</oauthConfig#<certificate>${certificate_value}</certificate><consumerKey>${consumer_key_value}</consumerKey></oauthConfig#g" "$meta_file"
      ;;
    msys*)
      sed -i "s#<contactEmail>.*</contactEmail>#<contactEmail>${email_value}</contactEmail>#g" "$meta_file"
      sed -i "s#</oauthConfig#<certificate>${certificate_value}</certificate><consumerKey>${consumer_key_value}</consumerKey></oauthConfig#g" "$meta_file"
      ;;
    *)
      echo "Unsupported operating system: $(uname)"
      exit 1
      ;;
  esac
  
  echo "Certificate, consumer key, and email inserted successfully!"
}


function prompt_to_create_commerce_community() {
  while true; do
    read -rp "$(echo_color seafoam 'Would you like to create a B2B Commerce Digital Experience (Community)? (y/n) > ')" answer
    case ${answer:0:1} in
    y | Y)
      export createConnectorStore=true
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

function prompt_to_refresh_smartbytes() {
  while true; do
    read -rp "$(echo_color seafoam 'It appears that you are targeting a Revenue Cloud IDO (SmartBytes) - is this a refresh of a previous setup? (y/n) > ')" answer
    case ${answer:0:1} in
    y | Y)
      export refreshSmartbytes=true
      prompt_to_include_connected_apps
      break
      ;;
    n | N)
      export refreshSmartbytes=false
      break
      ;;
    *)
      echo_color red "Invalid input. Please enter y or n."
      ;;
    esac
  done
}

function prompt_to_include_connected_apps() {
  while true; do
    echo
    echo_color seafoam 'Would you like to include the connected apps?'

    # Store the formatted prompt message in a variable
    prompt_message=$(echo_color seafoam '(If this is a new org from Q Central, choose yes.  If you are refreshing an already configured org or if this is the master template, choose no) (y/n) > ')

    read -rp "${prompt_message}" answer
    case ${answer:0:1} in
    y | Y)
      export deployConnectedApps=true
      break
      ;;
    n | N)
      export deployConnectedApps=false
      #get_consumer_key_for_connected_app
      populate_b2b_connector_custom_metadata_consumer_key
      break
      ;;
    *)
      echo_color red "Invalid input. Please enter y or n."
      ;;
    esac
  done
}

function set_user_email() {
  echo_color beige "Retrieving email for username $1"
  SFDX_USER_EMAIL=$($sfdx data query -q "SELECT Email from User WHERE Username='$1' LIMIT 1" -r csv | tail -n +2)
  export SFDX_USER_EMAIL
  echo_color green "Email: ${SFDX_USER_EMAIL:-unknown} for username $1"
}

function get_dev_hub_org_info() {
  local tmpfile
  local devhub_username
  tmpfile=$(mktemp || exit 1)
  devhub_username=$($sfdx config get target-dev-hub --json | sed -n 's/.*"value": "\(.*\)",/\1/p')
  $sfdx org display -o "$devhub_username" --json >"$tmpfile"
  if ! $sfdx org display -o "$devhub_username" --json >"$tmpfile"; then
    echo_color rose "Failed to retrieve Dev Hub org info - exiting"
    rm "$tmpfile"
    exit 1
  fi
  DEV_HUB_USERNAME=$(grep -o '"username": *"[^"]*' "$tmpfile" | grep -o '[^"]*$')
  DEV_HUB_API_VERSION=$(grep -o '"apiVersion": *"[^"]*' "$tmpfile" | grep -o '[^"]*$')
  echo_color beige DEV_HUB_USERNAME: "$DEV_HUB_USERNAME"
  echo_color beige DEV_HUB_API_VERSION: "$DEV_HUB_API_VERSION"
  rm "$tmpfile"
  export DEV_HUB_USERNAME DEV_HUB_API_VERSION
}

function set_sfdx_user_info() {
  local tmpfile
  tmpfile="$(mktemp)" # Use the "$(command)" syntax to capture the result of a command. Exit if mktemp fails.
  if ! $sfdx org display user --json >"$tmpfile"; then
    echo "Error: Failed to retrieve SFDX user info"
    rm "$tmpfile"
    return 1
  fi

  SFDX_USERNAME=$(grep -o '"username": *"[^"]*' "$tmpfile" | grep -o '[^"]*$')
  SFDX_USERID=$(grep -o '"id": *"[^"]*' "$tmpfile" | grep -o '[^"]*$')
  SFDX_ORGID=$(grep -o '"orgId": *"[^"]*' "$tmpfile" | grep -o '[^"]*$')
  SFDX_INSTANCEURL=$(grep -o '"instanceUrl": *"[^"]*' "$tmpfile" | grep -o '[^"]*$')
  SFDX_MYDOMAIN=${SFDX_INSTANCEURL#*\/\/}
  SFDX_MYSUBDOMAIN=${SFDX_MYDOMAIN%%.*}

  if [ -z "$SFDX_USERNAME" ]; then # Simplify check for empty string
    echo "Error: Failed to retrieve SFDX user info - exiting"
    rm "$tmpfile"
    exit 1
  fi

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
  $sfdx data query -q "SELECT Id FROM $1 WHERE $2='$3' LIMIT 1" -r csv | tail -n +2
}

function get_standard_pricebook_id() {
  local q="SELECT Id FROM Pricebook2 WHERE IsStandard=true LIMIT 1"
  $sfdx data query -q "$q" -r csv | tail -n +2
}

function get_payment_gateway_id() {
  local q="SELECT Id FROM PaymentGateway WHERE PaymentGatewayName='$PAYMENT_GATEWAY_NAME' AND PaymentGatewayProviderId='$1' LIMIT 1"
  $sfdx data query -q "$q" -r csv | tail -n +2
}

function create_scratch_org() {
  get_dev_hub_org_info
  if [ -z "$DEV_HUB_USERNAME" ]; then
    echo_color rose "No Dev Hub org found - exiting"
    exit 1
  fi
  # Determine which scratch definition file to use based on the config option
  case $configOption in
  1)
    defFile="config/dev-scratch-def.json"
    ;;
  2)
    if [[ ${DEV_HUB_API_VERSION%.*} -ge 58 ]]; then
      defFile="config/enterprise-scratch-def-v58.json"
    else
      defFile="config/enterprise-scratch-def-v57.json"
    fi
    ;;
  3)
    defFile="config/enterprise-rebates-scratch-def.json"
    ;;
  *)
    if [[ ${DEV_HUB_API_VERSION%.*} -ge 58 ]]; then
      defFile="config/enterprise-scratch-def-v58.json"
    else
      defFile="config/enterprise-scratch-def-v57.json"
    fi
    ;;
  esac
  echo_keypair "Scratch Definition File" "$defFile"
  # Create the scratch org using the specified definition file
  if ! $sfdx org create scratch -f "$defFile" -a "$1" -d -y 30 -w 15; then
    echo "Failed to create scratch org"
    exit 1
  fi
}

function deploy() {
  case $(uname -o | tr '[:upper:]' '[:lower:]') in
  msys*)
    if [[ "$($sfdx --version | grep sfdx-cli | cut -d '/' -f 2 | cut -d '.' -f 1-2)" < "$(echo $SFDX_RC_VERSION)" ]]; then
      $sfdx deploy metadata -g -c -r -d "$1" -a "$API_VERSION" -l NoTestRun
    else
      $sfdx project deploy start -g -c -r -d "$1" -a "$API_VERSION" -l NoTestRun
    fi
    ;;
  *)
    if [[ $(echo "$(sfdx_version) >= $SFDX_RC_VERSION" | bc) -eq 1 ]]; then
      $sfdx project deploy start -g -c -r -d "$1" -a "$API_VERSION" -l NoTestRun
    else
      $sfdx deploy metadata -g -c -r -d "$1" -a "$API_VERSION" -l NoTestRun
    fi
    ;;
  esac
}

function install_package() {
  $sfdx package install -p "$1"
}

function check_b2b_videoplayer() {
  if ! $b2bvp; then
    echo_color green "Checking for B2B LE Video Player"
    if $sfdx package installed list --json | grep -q '"SubscriberPackageNamespace": *"b2bvp"'; then
      echo_color cyan "B2B LE Video Player Found"
      b2bvp=true
    fi
  fi
}

function check_SBQQ() {
  if ! $sbqq; then
    echo_color green "Checking for Salesforce CPQ (SBQQ)"
    if $sfdx package installed list --json | grep -q '"SubscriberPackageNamespace": *"SBQQ"'; then
      echo_color cyan "Salesforce CPQ Found"
      sbqq=true
    fi
  fi
}

function check_blng() {
  if ! $blng; then
    echo_color green "Checking for Salesforce Billing (blng)"
    if $sfdx package installed list --json | grep -q '"SubscriberPackageNamespace": *"blng"'; then
      echo_color cyan "Salesforce Billing Found"
      blng=true
    fi
  fi
}

function check_sfdx_commerce_plugin {
  if $sfdx plugins | grep -q '@salesforce/commerce'; then
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

function replace_connected_app_files() {
  local app_names=("$@")
  echo_color seafoam "Updating Connected App Callback URLs"
  for app_name in "${app_names[@]}"; do
    cp quickstart-config/"${app_name}.connectedApp-meta-template.xml" quickstart-config/"${app_name}.connectedApp-meta-template.bak"
    case $orgType in
    1 | 2)
      baseSubdomain="test"
      ;;
    *)
      baseSubdomain="login"
      ;;
    esac

    case $(uname -o | tr '[:upper:]' '[:lower:]') in
    linux* | gnu/linux*)
      sed -i "s|<callbackUrl>https://login.salesforce.com/services/oauth2/callback</callbackUrl>|<callbackUrl>https://$baseSubdomain.salesforce.com/services/oauth2/callback\nhttps://$SFDX_MYDOMAIN/services/oauth2/callback\nhttps://$SFDX_MYDOMAIN/services/authcallback/SF</callbackUrl>|g" quickstart-config/"${app_name}".connectedApp-meta-template.bak
      ;;
    darwin*)
      sed -i '' -e "s|<callbackUrl>https://login.salesforce.com/services/oauth2/callback</callbackUrl>|<callbackUrl>https://$baseSubdomain.salesforce.com/services/oauth2/callback\nhttps://$SFDX_MYDOMAIN/services/oauth2/callback\nhttps://$SFDX_MYDOMAIN/services/authcallback/SF</callbackUrl>|g" quickstart-config/"${app_name}".connectedApp-meta-template.bak
      ;;
    msys*)
      sed -i "s#<callbackUrl>https://login.salesforce.com/services/oauth2/callback</callbackUrl>#<callbackUrl>https://$baseSubdomain.salesforce.com/services/oauth2/callback\nhttps://$SFDX_MYDOMAIN/services/oauth2/callback\nhttps://$SFDX_MYDOMAIN/services/authcallback/SF</callbackUrl>#g" quickstart-config/"${app_name}".connectedApp-meta-template.bak
      ;;
    *)
      echo "Unsupported operating system: $(uname)"
      exit 1
      ;;
    esac

    mv quickstart-config/"${app_name}".connectedApp-meta-template.bak "$SM_CONNECTED_APPS_DIR"/default/connectedApps/"${app_name}".connectedApp-meta.xml
  done
}

# Define function to replace named credential files
function replace_named_credential_files() {
  local named_credentials=("$@")
  echo_color seafoam "Updating Named Credential URLs"
  for named_cred in "${named_credentials[@]}"; do
    cp quickstart-config/"${named_cred}".namedCredential-meta-template.xml quickstart-config/"${named_cred}".namedCredential-meta-template.bak

    case $(uname -o | tr '[:upper:]' '[:lower:]') in
    linux* | gnu/linux*)
      sed -i "s|www.salesforce.com|$SFDX_MYDOMAIN|g" quickstart-config/"${named_cred}".namedCredential-meta-template.bak
      ;;
    darwin*)
      sed -i '' -e "s|www.salesforce.com|$SFDX_MYDOMAIN|g" quickstart-config/"${named_cred}".namedCredential-meta-template.bak
      ;;
    msys*)
      sed -i "s#www.salesforce.com#$SFDX_MYDOMAIN#g" quickstart-config/"${named_cred}".namedCredential-meta-template.bak
      ;;
    *)
      echo "Unsupported operating system: $(uname)"
      exit 1
      ;;
    esac

    mv quickstart-config/"${named_cred}".namedCredential-meta-template.bak "$SM_CONNECTED_APPS_DIR"/default/namedCredentials/"${named_cred}".namedCredential-meta.xml
  done
}

function convert_files() {
  replace_connected_app_files "$CONNECTED_APP_NAME_POSTMAN" "$CONNECTED_APP_NAME_SALESFORCE"
  replace_named_credential_files "$NAMED_CREDENTIAL_SM"
}

function sfdx_version() {
  $sfdx --version | awk '/sfdx-cli/{print $2}' FS=/ | cut -d . -f1,2 | awk '{print $0 + 0}'
}

function set_org_api_version {
  if awk -v ver="$SFDX_RC_VERSION" "BEGIN {exit ($(sfdx --version | grep sfdx-cli | cut -d ' ' -f 2) >= ver)}" >/dev/null; then
    API_VERSION=$($sfdx org display --json | grep -o '"apiVersion": *"[^"]*' | grep -o '[^"]*$')
  else
    API_VERSION=$($sfdx force:org:display --json | grep -o '"apiVersion": *"[^"]*' | grep -o '[^"]*$')
  fi

  echo_keypair "API Version" "$API_VERSION"
}

function update_org_api_version {
  set_org_api_version
  local sfdx_project_file="./sfdx-project.json"
  if [ -f "$sfdx_project_file" ]; then
    local current_version
    case "$(uname -o | tr '[:upper:]' '[:lower:]')" in
    msys)
      current_version=$(cat "$sfdx_project_file" | sed -n 's/.*"sourceApiVersion": "\([0-9\.]*\)".*/\1/p')
      ;;
    *)
      current_version=$(cat "$sfdx_project_file" | sed -n 's/.*"sourceApiVersion":[[:space:]]*"\([0-9]*\)".*/\1/p')
      ;;
    esac
    echo_color green "Current API Version: $current_version"
    if [ "$API_VERSION" != "$current_version" ]; then
      echo_color green "Updating the sfdx-project.json file with the org API version..."
      case "$(uname -o | tr '[:upper:]' '[:lower:]')" in
      darwin)
        sed -i '' "s/\"sourceApiVersion\":.*/\"sourceApiVersion\": \"$API_VERSION\",/" "$sfdx_project_file"
        ;;
      linux | gnu/linux)
        sed -i "s/\"sourceApiVersion\":.*/\"sourceApiVersion\": \"$API_VERSION\",/" "$sfdx_project_file"
        ;;
      msys)
        sed -i "s/\"sourceApiVersion\":.*/\"sourceApiVersion\": \"$API_VERSION\",/" "$sfdx_project_file"
        ;;
      esac
      echo_color green "The sfdx-project.json file has been updated with the org API version"
    else
      echo_color green "The sfdx-project.json file is already up to date with the org API version"
    fi
  else
    echo_color green "The sfdx-project.json file was not found"
  fi
}

function replace_api_version {
  echo_color seafoam "Replacing the API version to $API_VERSION in meta-xml files in $DEFAULT_DIR and subdirectories..."
  case $(uname -o | tr '[:upper:]' '[:lower:]') in
  darwin)
    find "$DEFAULT_DIR" -type f -name "*.xml" -not -path "$BASE_DIR/libs/*" -not -path "$COMMERCE_CONNECTOR_LIBS_DIR/*" -exec sh -c 'if grep -q "<apiVersion>$API_VERSION</apiVersion>" "$0"; then exit 1; else sed -i "" "s|<apiVersion>[^<]*</apiVersion>|<apiVersion>'"$API_VERSION"'</apiVersion>|g" "$0"; fi' {} \;
    find "$DEFAULT_DIR" -type f -name "*.xml" -not -path "$BASE_DIR/libs/*" -not -path "$COMMERCE_CONNECTOR_LIBS_DIR/*" -exec sed -i "" -E 's|(<value xsi:type="xsd:string">/services/data/v)[0-9]+\.[0-9]+(/.*)|\1'"$API_VERSION"'\2|g' {} \;
    ;;
  linux | gnu/linux | msys)
    find "$DEFAULT_DIR" -type f -name "*.xml" -not -path "$BASE_DIR/libs/*" -not -path "$COMMERCE_CONNECTOR_LIBS_DIR/*" -exec sh -c 'if grep -q "<apiVersion>$API_VERSION</apiVersion>" "$0"; then exit 1; else sed -i "s|<apiVersion>[^<]*</apiVersion>|<apiVersion>'"$API_VERSION"'</apiVersion>|g" "$0"; fi' {} \;
    find "$DEFAULT_DIR" -type f -name "*.xml" -not -path "$BASE_DIR/libs/*" -not -path "$COMMERCE_CONNECTOR_LIBS_DIR/*" -exec sed -i -E 's|(<value xsi:type="xsd:string">/services/data/v)[0-9]+\.[0-9]+(/.*)|\1'"$API_VERSION"'\2|g' {} \;
    ;;
  esac
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
  local q="Select COUNT(Id) from PermissionSetLicenseAssign Where AssigneeId='$SFDX_USERID' and PermissionSetLicenseId IN (SELECT Id FROM PermissionSetLicense WHERE DeveloperName = '$1')"
  permsetCount=$($sfdx data query -q "$q" -r csv | tail -n +2)
}

function assign_permset_license() {
  local ps=("$@")
  for i in "${ps[@]}"; do
    count_permset_license "$i"
    if [ "$permsetCount" == "0" ]; then
      echo_color green "Assiging Permission Set License: $i"
      $sfdx org assign permsetlicense -n "$i"
    else
      echo_color green "Permission Set License Assignment for Permset $i exists for $SFDX_USERNAME"
    fi
  done
}

function count_permset() {
  local q="SELECT COUNT(Id) FROM PermissionSetAssignment WHERE AssigneeID='$SFDX_USERID' AND PermissionSetId IN (SELECT Id FROM PermissionSet WHERE Name IN ($1))"
  $sfdx data query -q "$q" -r csv | tail -n +2
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
  local permsetCount
  permsetCount=$(count_permset "$joined")
  permsets="${ps[*]}"
  if [[ $permsetCount -ne $len ]]; then
    echo_color green "Permsets Missing - Attempting to Assign All Permsets"
    sfdx org assign permset -n $permsets
  else
    echo_color green "All Permsets Assigned"
  fi
}

function assign_permset() {
  local ps=("$@")
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

function check_qbranch() {
  if ((orgType == 0)); then
    echo_color green "Checking for QBranch Utils"
    local qbranch_ns
    local q="SELECT Identifier__c FROM QLabs__mdt LIMIT 1"
    qbranch_ns=$($sfdx package installed list --json | awk '/"SubscriberPackageNamespace": "qbranch"/{print $2}')
    if [[ -n $qbranch_ns ]]; then
      echo_color cyan "QBranch Utils Found - Querying for CDO/RCIDO"
      qbranchId=$($sfdx data query -q "$q" -r csv | tail -n +2)
      case $qbranchId in
      "$CDO_ID" | "$MFGIDO_ID")
        echo_color cyan "QBranch CDO/SDO Found"
        export cdo=true
        ;;
      "$RCIDO_ID")
        echo_color cyan "QBranch Revenue Cloud IDO Found"
        export rcido=true
        prompt_to_refresh_smartbytes
        ;;
      esac
    fi
  fi
}

function prepare_refresh_smartbytes() {
  add_line_to_forceignore "$B2B_STATICRESOURCES_PATH"
  #add_line_to_forceignore "$SM_TEMP_DIR/default/profiles/Admin.profile-meta.xml"
  add_line_to_forceignore "$SM_TEMP_DIR/default/objects"
  add_line_to_forceignore "$SM_TEMP_DIR/default/flexipages"
  add_line_to_forceignore "$SM_TEMP_DIR/default/layouts"
  add_line_to_forceignore "$SM_TEMP_DIR/default/cspTrustedSites"
  add_line_to_forceignore "$SM_TEMP_DIR/default/applications"
  add_line_to_forceignore "sm/sm-b2b-connector/main/default/customMetadata/RSM_Connector_Configuration.Consumer_Key.md-meta.xml"
}

function check_b2b_aura_template() {
  local aura_template
  #local template_name
  if [[ ${API_VERSION%.*} -ge 58 ]]; then
    #template_name=$B2B_AURA_TEMPLATE_NAME
    aura_template=$($sfdx community template list --json | awk -F'"' '/"templateName": "B2B Commerce \(Aura\)"/{print $4}')
  else
    #template_name=$B2B_TEMPLATE_NAME
    aura_template=$($sfdx community template list --json | awk -F'"' '/"templateName": "B2B Commerce"/{print $4}')
  fi
  if [[ -n $aura_template ]]; then
    echo_color cyan "B2B Aura Template Found"
    export b2b_aura_template=1
  else
    echo_color red "B2B Aura Template Not Found"
    export b2b_aura_template=0
  fi
}

function check_b2b_lwr_template() {
  local lwr_template
  lwr_template=$($sfdx community template list --json | awk -F'"' '/"templateName": "B2B Commerce \(LWR\)"/{print $4}')
  if [[ -n $lwr_template ]]; then
    echo_color cyan "B2B LWR Template Found"
    export b2b_lwr_template=1
  fi
}

function populate_b2b_connector_custom_metadata_consumer_key() {
  get_consumer_key_for_connected_app

  files_to_process=(
    "$QS_CONFIG_B2B_DIR/customMetadata/RSM_Connector_Configuration.Consumer_key.md-meta.xml"
  )

  for file in "${files_to_process[@]}"; do
    base_file=$(basename "$file")
    temp_file="${base_file%.*}_temp.xml"
    awk -v consumerKey="$consumerKey" \
      '{gsub(/INSERT_CONSUMER_KEY/, consumerKey); print}' "$file" >"$temp_file"
    if [[ $base_file == *".remoteSite-meta.xml" ]]; then
      mv "$temp_file" "$COMMERCE_CONNECTOR_TEMP_DIR/default/remoteSiteSettings/$base_file"
    else
      mv "$temp_file" "$COMMERCE_CONNECTOR_MAIN_DIR/default/customMetadata/$base_file"
    fi
  done
}

function populate_b2b_connector_custom_metadata() {
  echo_color green "Populating variables for B2B Connector Custom Metadata"
  get_store_url
  get_org_base_url
  echo_color green "Getting Id for WebStore $B2B_STORE_NAME"
  commerceStoreId=$(get_record_id WebStore Name "$B2B_STORE_NAME")
  echo_keypair commerceStoreId "$commerceStoreId"
  defaultCategoryId=$(get_record_id ProductCategory Name "$B2B_CATEGORY_NAME")
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
  defaultCategoryId=$(get_record_id ProductCategory Name "$B2B_CATEGORY_NAME")
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
  standardPricebook2Id=$(get_standard_pricebook_id)
  echo_keypair standardPricebook2Id "$standardPricebook2Id"
  smPricebook2Id=$(get_record_id Pricebook2 Name "$CANDIDATE_PRICEBOOK_NAME")
  echo_keypair smPricebook2Id "$smPricebook2Id"
  commercePricebook2Id=$(get_record_id Pricebook2 Name "$COMMERCE_PRICEBOOK_NAME")
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
    local q="SELECT Id FROM Pricebook2 WHERE Name='$value' AND IsStandard=($key='STANDARD_PRICEBOOK_NAME')"
    id=$($sfdx data query -q "$q" -r csv | tail -n +2)
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
  defaultBillingTreatmentItemId=$($sfdx data query -q "SELECT Id FROM BillingTreatmentItem WHERE Name='$DEFAULT_BILLING_TREATMENT_ITEM_NAME' LIMIT 1" -r csv | tail -n +2)
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
  defaultOneTimeProductPricebookEntryId=$($sfdx data query -q "SELECT Id from PricebookEntry WHERE Product2Id IN (SELECT Id FROM Product2 WHERE NAME = '$DEFAULT_ONE_TIME_PRODUCT')" -r csv | tail -n +2)
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
  $sfdx data import tree -p data/data-plan-1.json
  echo ""

  echo_color green "Activating Tax & Billing Policies and Updating Product2 data records with Activated Policy Ids"
  activate_tax_and_billing_policies || error_and_exit "Tax & Billing Policy Activation Failed"
  echo ""
  #TODO: refactor to be more modular and do checks for existing data
  echo_color green "Pushing Product & Pricing Data to the Org"
  # Choose to seed data with all SM Product setup completed or choose the base option to not add PSMO and PBE for use in workshops
  if $includeCommerceConnector; then
    echo_color green "Getting Standard and Commerce Pricebooks for Pricebook Entries and replacing in data files"
    commerceStoreId=$(get_record_id WebStore Name "$B2B_STORE_NAME")
    echo_keypair commerceStoreId "$commerceStoreId"
    standardPricebook2Id=$(get_standard_pricebook_id)
    echo_keypair standardPricebook2Id "$standardPricebook2Id"
    smPricebook2Id=$(get_record_id Pricebook2 Name "$CANDIDATE_PRICEBOOK_NAME")
    echo_keypair smPricebook2Id "$smPricebook2Id"
    commercePricebook2Id=$(get_record_id Pricebook2 Name "$COMMERCE_PRICEBOOK_NAME")
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
    $sfdx data import tree -p data/data-plan-commerce.json
    echo_color green "Updating Webstore $B2B_STORE_NAME StrikethroughPricebookId to $commercePricebook2Id"
    $sfdx data update record -s WebStore -i "$commerceStoreId" -v "StrikethroughPricebookId='$commercePricebook2Id'"
  else
    $sfdx data import tree -p data/data-plan-2.json
  fi
  #sfdx data import tree -p data/data-plan-2-base.json
  echo_color green "Pushing Default Account & Contact"
  $sfdx data import tree -p data/data-plan-3.json
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
    $sfdx data create record -s TaxEngineProvider -v "DeveloperName='$TAX_PROVIDER_CLASS_NAME' MasterLabel='$TAX_PROVIDER_CLASS_NAME' ApexAdapterId=$taxProviderClassId"
    echo_color green "Getting Id for TaxEngineProvider $TAX_PROVIDER_CLASS_NAME"
    taxEngineProviderId=$(get_record_id TaxEngineProvider DeveloperName "$TAX_PROVIDER_CLASS_NAME")
  fi
  echo_keypair taxEngineProviderId "$taxEngineProviderId"

  echo_color green "Getting Id for NamedCredential $NAMED_CREDENTIAL_MASTER_LABEL"
  taxMerchantCredentialId=$(get_record_id NamedCredential DeveloperName "$NAMED_CREDENTIAL_DEVELOPER_NAME")
  echo_keypair taxMerchantCredentialId "$taxMerchantCredentialId"
  echo_color green "Checking for existing TaxEngine $TAX_PROVIDER_CLASS_NAME"
  taxEngineId=$(get_record_id TaxEngine TaxEngineName "$TAX_PROVIDER_CLASS_NAME")
  if [ -z "$taxEngineId" ]; then
    echo_color green "Creating TaxEngine $TAX_PROVIDER_CLASS_NAME"
    $sfdx data create record -s TaxEngine -v "TaxEngineName='$TAX_PROVIDER_CLASS_NAME' MerchantCredentialId=$taxMerchantCredentialId TaxEngineProviderId=$taxEngineProviderId Status='Active' SellerCode='Billing2' TaxEngineCity='San Francisco' TaxEngineCountry='United States' TaxEnginePostalCode='94105' TaxEngineState='California'"
    echo_color green "Getting Id for TaxEngine $TAX_PROVIDER_CLASS_NAME"
    taxEngineId=$(get_record_id TaxEngine TaxEngineName "$TAX_PROVIDER_CLASS_NAME")
  fi
  echo_color green "$TAX_PROVIDER_CLASS_NAME Tax Engine Id:"
  echo_keypair taxEngineId "$taxEngineId"
}

function create_stripe_gateway() {
  echo_color green "Creating Stripe Payment Gateway"
  $sfdx data create record -s PaymentGateway -v "MerchantCredentialId=$stripeNamedCredentialId PaymentGatewayName=$STRIPE_PAYMENT_GATEWAY_NAME PaymentGatewayProviderId=$stripePaymentGatewayProviderId Status=Active"
}

function create_mock_payment_gateway() {
  echo_color green "Getting Named Credential $NAMED_CREDENTIAL_MASTER_LABEL"
  namedCredentialId=$(get_record_id NamedCredential DeveloperName "$NAMED_CREDENTIAL_DEVELOPER_NAME")
  echo_keypair namedCredentialId "$namedCredentialId"
  echo_color green "Creating PaymentGateway record using MerchantCredentialId=$namedCredentialId, PaymentGatewayProviderId=$1."
  $sfdx data create record -s PaymentGateway -v "MerchantCredentialId=$namedCredentialId PaymentGatewayName=$PAYMENT_GATEWAY_NAME PaymentGatewayProviderId=$1 Status=Active"
  echo_color green "Getting PaymentGateway record Id"
  paymentGatewayId=$(get_payment_gateway_id "$1")
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
      service_id=$($sfdx data create record -s RegisteredExternalService -v "DeveloperName=$service_name ExternalServiceProviderId=$service_class ExternalServiceProviderType=$service_type MasterLabel=$service_name" --json | grep -Eo '"id": "([^"]*)"' | awk -F':' '{print $2}' | tr -d ' "')
      echo_keypair "$service_name Service Id" "$service_id"
    fi
    $sfdx data create record -s StoreIntegratedService -v "integration=$service_id StoreId=$commerceStoreId ServiceProviderType=$service_type"
  done
  local q="SELECT Id FROM StoreIntegratedService WHERE StoreId='$commerceStoreId' AND ServiceProviderType='Payment' LIMIT 1"
  serviceMappingId=$($sfdx data query -q "$q" -r csv | tail -n +2)
  echo_keypair "Payment Service Mapping Id" "$serviceMappingId"

  if [ -n "$serviceMappingId" ]; then
    $sfdx data delete record -s StoreIntegratedService -i "$serviceMappingId"
  fi

  paymentGatewayId=$(get_record_id PaymentGateway PaymentGatewayName "$PAYMENT_GATEWAY_NAME")
  echo_keypair "Payment Gateway Id" "$paymentGatewayId"
  $sfdx data create record -s StoreIntegratedService -v "Integration=$paymentGatewayId StoreId=$commerceStoreId ServiceProviderType=Payment"
}

function activate_tax_and_billing_policies() {
  echo_color green "Activating Tax and Billing Policies"

  query() {
    $sfdx data query -q "SELECT Id FROM $1 WHERE Name='$2' AND (Status='Draft' OR Status='Inactive') LIMIT 1" -r csv | tail -n +2
  }

  update_record() {
    $sfdx data update record -s "$1" -i "$2" -v "$3 Status=Active"
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
  $sfdx data update record -s PaymentTerm -i "${values[7]}" -v "IsDefault=TRUE Status=Active"

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
  check_b2b_aura_template
  if [ "$b2b_aura_template" == 1 ]; then
    if [[ ${API_VERSION%.*} -ge 58 ]]; then
      $sfdx community create -n "$B2B_STORE_NAME" -t "$B2B_AURA_TEMPLATE_NAME" -p "$B2B_STORE_NAME" -d "B2B Commerce (Aura) created by Subscription Management Quickstart"
    else
      $sfdx community create -n "$B2B_STORE_NAME" -t "$B2B_TEMPLATE_NAME" -p "$B2B_STORE_NAME" -d "B2B Commerce (Aura) created by Subscription Management Quickstart"
    fi
  else
    check_b2b_lwr_template
    if [ "$b2b_lwr_template" == 1 ]; then
      $sfdx community create -n "$B2B_STORE_NAME" -t "$B2B_LWR_TEMPLATE_NAME" -p "$B2B_STORE_NAME" -d "B2B Commerce (LWR) created by Subscription Management Quickstart"
    else
      echo_color red "You have set the variable for createCommerceStore to true, but no valid template was found. Please check your configuration."
      exit 1
    fi
  fi
}

function create_sm_community() {
  echo_color green "Creating Subscription Management Customer Account Portal Digital Experience"
  $sfdx community create -n "$COMMUNITY_NAME" -t "$COMMUNITY_TEMPLATE_NAME" -p "$COMMUNITY_NAME" -d "Customer Portal created by Subscription Management Quickstart"
}

function prepare_experiences_directory() {
  # Retrieve Pricebook ID if not already retrieved
  if [ -z "$pricebook1" ]; then
    pricebook1=$(get_standard_pricebook_id)
    echo_keypair pricebook1 "$pricebook1"
  fi

  # Retrieve Payment Gateway ID if not already retrieved
  if [ -z "$paymentGatewayId" ]; then
    if [ -z "$paymentGatewayProviderId" ]; then
      paymentGatewayProviderId=$(get_record_id PaymentGatewayProvider DeveloperName "$PAYMENT_GATEWAY_PROVIDER_NAME")
      echo_keypair paymentGatewayProviderId "$paymentGatewayProviderId"
    fi
    paymentGatewayId=$(get_payment_gateway_id "$paymentGatewayProviderId")

    # Check if paymentGatewayId is empty or null
    if [ -z "${paymentGatewayId}" ]; then
      echo "Error: Failed to retrieve Payment Gateway ID"
      exit 1
    fi

    echo_keypair paymentGatewayId "$paymentGatewayId"
  fi

  # If both Pricebook ID and Payment Gateway ID have been retrieved, update home.json
  if [ -n "$pricebook1" ] && [ -n "$paymentGatewayId" ]; then
    tmpfile=$(mktemp)
    sed -e "s/INSERT_GATEWAY/$paymentGatewayId/g;s/INSERT_PRICEBOOK/$pricebook1/g" quickstart-config/home.json >"$tmpfile"
    mv -f "$tmpfile" "$COMMUNITY_TEMPLATE_DIR"/default/experiences/"${COMMUNITY_NAME}"1/views/home.json
  else
    error_and_exit "Could not retrieve Pricebook or Payment Gateway.  Exiting before pushing community template"
  fi

  # Copy CDO/SDO community components if necessary
  if $cdo && ! $rcido; then
    echo_color green "Copying CDO/SDO community components to ${COMMUNITY_NAME}1"
    cp -f quickstart-config/cdo/experiences/"${COMMUNITY_NAME}"1/routes/actionPlan* "$COMMUNITY_TEMPLATE_DIR"/default/experiences/"${COMMUNITY_NAME}"1/routes/.
    cp -f quickstart-config/cdo/experiences/"${COMMUNITY_NAME}"1/views/actionPlan* "$COMMUNITY_TEMPLATE_DIR"/default/experiences/"${COMMUNITY_NAME}"1/views/.
    if $includeConnectorStoreTemplate; then
      echo_color green "Copying CDO/SDO community components to ${B2B_STORE_NAME}1"
      cp -f quickstart-config/sm-b2b-connector/experiences/"${B2B_STORE_NAME}"1/routes/actionPlan* "$COMMERCE_CONNECTOR_TEMPLATE_DIR"/default/experiences/"${B2B_STORE_NAME}"1/routes/.
      cp -f quickstart-config/sm-b2b-connector/experiences/"${B2B_STORE_NAME}"1/views/actionPlan* "$COMMERCE_CONNECTOR_TEMPLATE_DIR"/default/experiences/"${B2B_STORE_NAME}"1/views/.
      cp -f quickstart-config/sm-b2b-connector/experiences/"${B2B_STORE_NAME}"1/routes/recommendation* "$COMMERCE_CONNECTOR_TEMPLATE_DIR"/default/experiences/"${B2B_STORE_NAME}"1/routes/.
      cp -f quickstart-config/sm-b2b-connector/experiences/"${B2B_STORE_NAME}"1/views/recommendation* "$COMMERCE_CONNECTOR_TEMPLATE_DIR"/default/experiences/"${B2B_STORE_NAME}"1/views/.
      rm -f "$COMMERCE_CONNECTOR_TEMPLATE_DIR"/default/experiences/"${B2B_STORE_NAME}"1/views/newsDetail.json
      rm -f "$COMMERCE_CONNECTOR_TEMPLATE_DIR"/default/experiences/"${B2B_STORE_NAME}"1/routes/newsDetail.json
    fi
  fi

  # Remove components for specific org types
  #echo_keypair orgType "$orgType"
  if ((orgType == 4 || orgType == 3 || rcido || (orgType == 0 && cdo))); then
    rm -f "$COMMUNITY_TEMPLATE_DIR"/default/experiences/"${COMMUNITY_NAME}"1/views/articleDetail.json
    rm -f "$COMMUNITY_TEMPLATE_DIR"/default/experiences/"${COMMUNITY_NAME}"1/routes/articleDetail.json
    rm -f "$COMMUNITY_TEMPLATE_DIR"/default/experiences/"${COMMUNITY_NAME}"1/views/topArticles.json
    rm -f "$COMMUNITY_TEMPLATE_DIR"/default/experiences/"${COMMUNITY_NAME}"1/routes/topArticles.json
  fi
  if [ "$orgType" == 3 ]; then
    rm -f "$COMMERCE_CONNECTOR_TEMPLATE_DIR"/default/experiences/"${B2B_STORE_NAME}"1/views/newsDetail.json
    rm -f "$COMMERCE_CONNECTOR_TEMPLATE_DIR"/default/experiences/"${B2B_STORE_NAME}"1/routes/newsDetail.json
  fi

  # Remove components for MFGIDO org type
  if $mfgido; then
    echo_color green "Removing Self Register components from $B2B_STORE_NAME for MFGIDO"
    rm -rf "$COMMERCE_CONNECTOR_TEMPLATE_DIR"/default/aura/selfRegister*
    rm -rf "$COMMERCE_CONNECTOR_TEMPLATE_DIR"/default/lwc/selfLogin*
    rm -rf "$COMMERCE_CONNECTOR_TEMPLATE_DIR"/default/lwc/selfRegister*
    rm -rf "$COMMERCE_CONNECTOR_TEMPLATE_DIR"/default/permissionsets/Account_Switcher_User.permissionset-meta.xml
  fi
}

function open_org() {
  local path=""
  local browser="${2:-}"

  # Set path based on org key
  case "$1" in
  "setup")
    path="lightning/setup/SetupOneHome/home"
    ;;
  "dev")
    path="lightning/page/home"
    ;;
  *)
    echo "Invalid org key passed to open_org function"
    return 1
    ;;
  esac

  # Check if browser is specified and valid
  case "$browser" in
  "chrome") ;;
  "edge") ;;
  "firefox") ;;
  "") ;;
  *)
    echo "Invalid browser specified"
    return 1
    ;;
  esac

  # Set the command with or without browser flag, depending on $browser
  if [ -z "$browser" ]; then
    $sfdx org open -p "$path"
  else
    $sfdx org open -p "$path" --browser "$browser"
  fi
}
