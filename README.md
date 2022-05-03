# **Salesforce Subscription Management General Release**

## **INTRODUCTION**

This repository contains setup scripts, reference implementations and initial data to help quickly configure a fully functional, E2E Salesforce Subscription Management environment as part of the Subscription Management General Release.

This repository is currently limited to **Salesforce Core Summer '22 (238)** environments.   This repository will be updated for further releases, and branches exist for previous releases.

## **INSTRUCTIONS**

**It is necessary to have Salesforce DX, Visual Studio Code, Git and the Salesforce Extensions for Visual Studio Code installed to proceed.**

You can also use other tools, such as IlluminatedCloud for IntelliJ IDEA, but that is beyond the scope of this document.

Salesforce DX CLI can be downloaded [here](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm).     There are setup instructions on the download site.

Visual Studio Code can be downloaded [here](https://code.visualstudio.com/download). There are also instructions on the VS Code site.

Salesforce Extensions for Visual Studio Code can be downloaded [here](https://developer.salesforce.com/tools/vscode).  There are instructions for setting it up in VS Code.

Git can be downloaded [here](https://git-scm.com/downloads).  There are instructions on the site.  For mac users, the easiest way to get git is to install XCode from the AppStore, launch it and click the button to confirm installation of helper tools. Instructions are [here](https://www.freecodecamp.org/news/install-xcode-command-line-tools/).

Upon receipt and after confirming access to your customer preview environment, you can run the **setup.sh** script in the scripts directory to push the sample source, metadata and data, and will also set up a mock payment gateway.  After successful completion of the setup scripts, you will be able to use the published postman collection to access the org to validate your setup.  The script must be executed from the scripts directory.  To do so, use terminal to cd into scripts from the project root folder and type ./setup.sh.

These scripts set up two default connected apps for you to facilitate your setup of the collection.  Please reference the consumer key and secret from the **Postman** connected app in your org to use in your collection environment variables.