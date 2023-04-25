# **Salesforce Subscription Management General Release Quick Start**
## **DISCLAIMER**
The setup script in this repository can create an example storefront that is built using Experience Cloud using named credentials with extra privileges to access the Subscription Management APIs. In a production org, do not create a privileged internal user to access Subscription Management APIs as doing so may violate your license agreement and create a security risk.  Subscription Management is now available to be licensed to Customer & Partner Community users, and this repository will soon be updated to access the Subscription Management APIs with the proper credentials and permissions, and the named credential example will be removed.  The optional B2B Commerce storefront currently uses the appropriate credentials to access the Subscription Management APIs, and is the preferred quickstart options for most users.

**The code in this repository is provided on an as-is basis to help with development. The code, examples and processes provided and documented in this repository are not eligible for support directly from Salesforce. This script was developed for unix-based operating systems, such as mac os x and linux, as it requires multiple command line utilities to perform its operations.  It's been tested with bash and zsh.  Many of the recent enhancements are to support various internal Salesforce deployment processes.**

**The script was never intended to support the Windows operating system, and as such will not run without major modifications.**
## **INTRODUCTION**

This repository contains setup scripts, reference implementations and initial data to help quickly configure a fully functional, E2E Salesforce Subscription Management environment as part of the Subscription Management General Release.

**This repository is in Salesforce DX Source Format**

This repository is currently limited to **Salesforce Core Spring '23 (242) & Summer '23 (244)** environments.   This repository will be updated for further releases, and branches exist for previous releases.  Recent updates to this repository now include capabilities to determine the correct version of the target environment and will perform operations specific to the target environment version.  At the current time, only B2B Commerce Lightning Aura templates are supported, with LWR support coming soon.  LWR is the only available B2B Commerce template version as of 242 by default, but it is possible to enable the Aura template via a scratch org definition file, which is the approach utilized by the quickstart process.  If your target environment already has the B2B Commerce Aura template enabled from a previous release, you can safely proceed when prompted to create and include the example B2B Commerce storefront.

Documentation for Subscription Management is available [here](https://developer.salesforce.com/docs/revenue/subscription-management/overview).

Documentation for B2B Commerce is available [here](https://developer.salesforce.com/docs/atlas.en-us.b2b_b2c_comm_dev.meta/b2b_b2c_comm_dev/b2b_b2c_comm_dev_guide.htm).

## **INSTRUCTIONS**

**It is necessary to have Salesforce DX installed and configured to proceed. It is suggested to also use Visual Studio Code, Git and the Salesforce Extensions for Visual Studio Code installed to simplify and enhance the development and evaluation process as this repository will continue to be updated with new reference implementations and examples.**

Salesforce DX CLI can be downloaded [here](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm).     There are setup instructions on the download site.

Visual Studio Code can be downloaded [here](https://code.visualstudio.com/download). There are also instructions on the VS Code site.

Salesforce Extensions for Visual Studio Code can be downloaded [here](https://developer.salesforce.com/tools/vscode).  There are instructions for setting it up in VS Code.

Upon receipt and after confirming access to your developer or trial org, you can run the **setup.sh** script in the root directory to create a scratch org if desired, push the sample source, metadata and data, set up a mock payment gateway, and an example Customer Account Portal that uses the Subscription Management APIs to help you with evaluating and developing for Subscription Management.  Other optional components include an example B2B Commerce Lightning storefront configured to connect to Subscription Management.

After successful completion of the setup scripts, you will be able to use the published postman collection to access the org to validate your setup. To execute the setup script, type ./setup.sh in your terminal while in the root folder of this project.  

The script will prompt you for the type of org you are using and will make necessary adjustments. The script also prompts to include and configure the B2B Commerce/Subscription Management connector and storefront.

### Supported Org Types:
[0] Production

[1] Scratch

[2] Sandbox

[3] Falcon (test1 - Internal SFDC only)

[4] Developer
### Supported Scratch Org Types:
[0] Developer

[1] Enterprise

There are currently 12 variables to control which actions will be attempted.  The default value of 1 for each variable indicates that action will be attempted.  To disable any of the actions, change the value to 0 in setup.sh

The current variables are:

**insertData** - Seed sample data into new environments.  This should be changed to 0 after successfully seeding initial data as errors will be generated if the seed data already exists in the target environment.

**deployCode** - Deploy source code and metadata from most modules.  If the target is a scratch org, sfdx force:source:push is executed.  Other orgs utilize sfdx force:source:deploy.

**createGateway** - Create the initial mock payment gateway for new environments.  This should be changed to 0 after successfully creating the gateway in the target environment.

**createTaxEngine** - Create the initial mock tax engine for new environments.  This should be changed to 0 after successfully creating the tax engine in the target environment.

**createCommunity** - Create a Customer Account Portal Experience Cloud site that is configured to use Subscription Management in a new environment.  This should be changed to 0 after the community is successfully created in the target environment.

**installPackages** - Install any defined managed packages.  Currenly this only installs the Streaming API Monitor.  This should be changed to 0 after successful installation.

**includeCommunity** - Perform operations related to the Customer Account Portal Experience Cloud site that is created during setup.  This includes pushing source code, metadata and community templates that have been configured by this setup script.

**includeCommerceConnector** - Include the connector and reference components to connect Subscription Management to Lighting B2B Commerce.

**createConnectorStore** - Create a B2B Commerce storefront.

**includeConnectorStoreTemplate** - Deploy a fully configured B2B Commerce storefront to store created from above.

**registerCommerceServices** - Register all sample commerce services to the B2B storefront for inventory, shipment, and tax. 

**createStripeGateway** - Create a Stripe payment gateway. 

**deployConnectedApps** - Deploy connected apps and supporting certficates and metadata. 

These scripts set up two default connected apps for you to facilitate your setup of the collection:  

The **Postman** connected app is for you to use to connect Postman or another REST client of your choice.  Please reference the consumer key and secret from the **Postman** connected app in your org to use in your collection environment variables.

The **Salesforce** connected app is for the Mock Payment Gateway and other configured services used during development and testing.  
