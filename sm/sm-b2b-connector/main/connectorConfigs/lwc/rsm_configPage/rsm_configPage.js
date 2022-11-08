import { LightningElement, track } from "lwc";
import getTabsAndConfiguration from "@salesforce/apex/RSM_AppConfgController.getTabsAndConfiguration";
import updateBulkMetadata from "@salesforce/apex/RSM_AppConfgController.updateBulkMetadata";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import configSaveSucess from "@salesforce/label/c.RSM_Config_Save_Success";
import configSaveError from "@salesforce/label/c.RSM_Config_Save_Failure";
import configHideValues from "@salesforce/label/c.RSM_Config_Hide_Values";



export default class Rsm_configPage extends LightningElement {
    
    isLoading = false;
    @track configData = [];
    updatedConfigData = {};
    initilized = false;
    isProductTabActive = false;
    disableButton = false;
    isRendered = false;
    label = {
        configSaveError,
        configSaveSucess,
        configHideValues
    }

    connectedCallback() {
        if (this.initilized) return;
        this.isLoading = true;
        this.initilized = true;
        this.getTabsAndConfigrationJS();
    }

    renderedCallback() {
        this.clearApiKeyField();
        if (this.isRendered) return;
        this.isRendered = true;
    }

    getTabsAndConfigrationJS() {
        getTabsAndConfiguration()
            .then((result) => {
                let configData = JSON.parse(result);
                for (let key in configData) {
                    this.configData.push({ value: configData[key], key: key });
                }
                this.configData.reverse();
            })
            .catch((error) => {
                console.log(error);
            })
            .finally(() => (this.isLoading = false));
    }
    

    handleGenricChange(event) {
        this.updatedConfigData[event.currentTarget.dataset.id] = event.currentTarget.value;
    }

    handleSave() {
        updateBulkMetadata({ jsonString: JSON.stringify(this.updatedConfigData) })
            .then((result) => {
                if (result) this.clearApiKeyField();
                this.disableButton = false;
                this.showToast({ message: this.label.configSaveSucess, variant: "success" });
            })
            .catch((error) => {
                this.showToast({ message: this.label.configSaveError, variant: "error" });
                console.log(error);
            });
    }

    clearApiKeyField() {
        let allInputs = this.template.querySelectorAll("lightning-input");
        for (let ele of allInputs) {
            if (this.label.configHideValues.split(',').includes(ele.label)) ele.value = "";
        }
    }

    showToast(obj) {
        const event = new ShowToastEvent(obj);
        this.dispatchEvent(event);
    }

}