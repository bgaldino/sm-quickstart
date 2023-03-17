import { LightningElement, track, api } from "lwc";
import getAllAssets from "@salesforce/apex/SM_MyAssetsController.getAllAssetsForCurrentUser";
//import getAssets from "@salesforce/apex/AssetManagementController.getAssetsByAccount";
import renewAssets from "@salesforce/apex/SM_MyAssetsController.renewAssets";
import cancelAssets from "@salesforce/apex/SM_MyAssetsController.cancelAssets";
import amendAssets from "@salesforce/apex/SM_MyAssetsController.amendAssets";

const columns = [
  { label: "Asset Name", fieldName: "name", type: "text" },
  { label: "Current Quantity", fieldName: "currentQuantity", type: "decimal" },
  { label: "Lifecycle Start Date", fieldName: "lifecycleStartDate", type: "date-local" },
  { label: "Lifecycle End Date", fieldName: "lifecycleEndDate", type: "date-local" }
];
export default class Sb_myAssets extends LightningElement {
  isButtonsActivated = true;
  isCancelDatePopup = false;
  isAmendDatePopup = false;
  //assets = [];
  //unwrappedAssets = [];
  hasAssets = false;
  @track assets;
  @track assetList;
  @track error;
  @api recordId;
  @track columns = columns;
  selectedRows = [];
  @track cancelledDate;
  @track amendedDate;
  @track amendQuantity;
  @track isLoaded = false;

  connectedCallback() {
    this.getAssets();
  }
  getAssets() {
    getAllAssets({})
      .then((result) => {
        this.assets = result;
        this.hasAssets = true;
        console.log("Assets are:", this.assets);
      })
      .catch((error) => console.error("Error when loading the assets", error));
  }

  handleRowSelection = (event) => {
    this.selectedRows = event.detail.selectedRows;
    console.log('The selected row is: '+this.selectedRows);
    this.isButtonsActivated = this.selectedRows.length > 0 ? false : true;
  };

  toggleCancelDatePopup = () => {
    this.isCancelDatePopup = this.isCancelDatePopup === false ? true : false;
  };

  toggleAmendDatePopup = () => {
    this.isAmendDatePopup = this.isAmendDatePopup === false ? true : false;
  };

  handleAction = (event) => {
    let actionType = event.currentTarget.name;

    this.isLoaded = true;
    console.log("actionType", actionType);
    if (actionType === "Renew") {
      this.handleRenewAssets();
    } else if (actionType === "Cancel") {
      this.handleCancelAssets();
    } else if (actionType === "Amend") {
      this.handleAmendAssets();
    }
    this.isLoaded = false;
    this.isCancelDatePopup = false;
    this.isAmendDatePopup = false;
  };

  handleRenewAssets = () => {
    renewAssets({ assetList: this.selectedRows })
      .then((data) => {
        console.log(data);
      })
      .catch((error) => {
        this.error = error;
      });
  };

  handleCancelAssets = () => {
    cancelAssets({
      assetList: this.selectedRows,
      cancelDate: this.cancelledDate
    })
      .then((data) => {
        console.log(data);
      })
      .catch((error) => {
        this.error = error;
      });
    this.isCancelDatePopup = false;
  };

  handleAmendAssets = () => {
    amendAssets({
      assetList: this.selectedRows,
      startDate: this.amendedDate,
      quantityChange: this.amendedQuantity
    })
      .then((data) => {
        console.log(data);
      })
      .catch((error) => {
        this.error = error;
      });
    this.isAmendDatePopup = false;
  };

  handleCancelDate(event) {
    this.cancelledDate = event.currentTarget.value;
  }

  handleAmendDate(event) {
    this.amendedDate = event.currentTarget.value;
  }

  handleQuantity(event) {
    this.amendedQuantity = event.currentTarget.value;
  }

  get toggleCancelAssetButton() {
    return this.selectedRows.length > 0 && this.cancelledDate !== undefined
      ? false
      : true;
  }

  get toggleAmendAssetButton() {
    return this.selectedRows.length > 0 && this.amendedDate !== undefined
      ? false
      : true;
  }
}
