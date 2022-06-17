# **Salesforce Subscription Management General Release Quick Start**
## **DISCLAIMER**
The setup script in this repository can create an example storefront that is built using Experience Cloud. Because Subscription Management isn't yet licensed for Experience Cloud, the following steps show you how to create a Community user with extra privileges to access the Subscription Management API. In a production org, do not create a privileged internal use to access Subscription Management APIs as doing so may violate your license agreement and create a security risk.

**The code in this repository is provided on an as-is basis to help with development. The code, examples and processes provided and documented in this repository are not eligible for support directly from Salesforce.**
## **INTRODUCTION**

This repository contains setup scripts, reference implementations and initial data to help quickly configure a fully functional, E2E Salesforce Subscription Management environment as part of the Subscription Management General Release.

**This repository is in Salesforce DX Source Format**

This repository is currently limited to **Salesforce Core Summer '22 (238)** environments.   This repository will be updated for further releases, and branches exist for previous releases.

## **INSTRUCTIONS**

**It is necessary to have Salesforce DX installed and configured to proceed. It is suggested to also use Visual Studio Code, Git and the Salesforce Extensions for Visual Studio Code installed to simplify and enhance the development and evaluation process as this repository will continue to be updated with new reference implementations and examples.**

Salesforce DX CLI can be downloaded [here](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm).     There are setup instructions on the download site.

Visual Studio Code can be downloaded [here](https://code.visualstudio.com/download). There are also instructions on the VS Code site.

Salesforce Extensions for Visual Studio Code can be downloaded [here](https://developer.salesforce.com/tools/vscode).  There are instructions for setting it up in VS Code.

Upon receipt and after confirming access to your developer or trial org, you can run the **setup.sh** script in the root directory to create a scratch org, push the sample source, metadata and data, set up a mock payment gateway, and an example Customer Account Portal that uses the Subscription Management APIs to help you with evaluating and developing for Subscription Management.  

After successful completion of the setup scripts, you will be able to use the published postman collection to access the org to validate your setup. To execute the setup script, type ./setup.sh in your terminal while in the root folder of this project.  

The script will prompt you for the type of org you are using and will make necessary adjustments.  

### Supported Org Types:
[0] Production/Developer

[1] Scratch

[2] Sandbox

[3] Falcon (test1 - Internal SFDC only)
### Supported Scratch Org Types:
[0] Developer

[1] Enterprise

There are currently 6 variables to control which actions will be attempted.  The default value of 1 for each variable indicates that action will be attempted.  To disable any of the actions, change the value to 0 in setup.sh

The current variables are:

**insertData** - Seeds sample data into new environments.  This should be changed to 0 after successfully seeding initial data as errors will be generated if the seed data already exists in the target environment.

**deployCode** - Pushes source code and metadata from most modules.  If the target is a scratch org, sfdx force:source:push is executed.  Other orgs utilize sfdx force:source:deploy.

**createGateway** - Creates the initial mock payment gateway for new environments.  This should be changed to 0 after successfully creating the gateway in the target environment.

**createCommunity** - Creates a Customer Account Portal Experience Cloud site that is configured to use Subscription Management in a new environment.  This should be changed to 0 after the community is successfully created in the target environment.

**installPackages** - Installs any defined managed packages.  Currenly this only installs the Streaming API Monitor.  This should be changed to 0 after successful installation.

**includeCommunity** - Perform operations related to the Customer Account Portal Experience Cloud site that is created during setup.  This includes pushing source code, metadata and community templates that have been configured by this setup script.

These scripts set up two default connected apps for you to facilitate your setup of the collection:  

The **Postman** connected app is for you to use to connect Postman or another REST client of your choice.  Please reference the consumer key and secret from the **Postman** connected app in your org to use in your collection environment variables.

The **Salesforce** connected app is for the Mock Payment Gateway and other configured services used during development and testing.  
