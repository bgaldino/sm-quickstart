import { LightningElement, wire, track, api } from "lwc";
import getAssets from "@salesforce/apex/AssetManagementController.getAssetsByAccount";
import renewAssets from "@salesforce/apex/AssetManagementController.renewAssets";
import cancelAssets from "@salesforce/apex/AssetManagementController.cancelAssets";
import amendAssets from "@salesforce/apex/AssetManagementController.amendAssets";

const columns = [
  { label: "Asset Name", fieldName: "Name", type: "text" },
  {
    label: "Lifecycle Start Date",
    fieldName: "LifecycleStartDate",
    type: "date",
    typeAttributes: {
      day: "2-digit",
      month: "2-digit",
      year: "numeric",
      timeZone: "UTC"
    }
  },
  {
    label: "Lifecycle End Date",
    fieldName: "LifecycleEndDate",
    type: "date",
    typeAttributes: {
      day: "2-digit",
      month: "2-digit",
      year: "numeric",
      timeZone: "UTC"
    }
  },
  { label: "Renewal Term Unit", fieldName: "RenewalTermUnit", type: "text" },
  { label: "Renewal Term", fieldName: "RenewalTerm", type: "Number" }
];

export default class AssetManagement extends LightningElement {
  isButtonsActivated = true;
  isCancelDatePopup = false;
  isAmendDatePopup = false;
  @track assetList;
  @track error;
  @api recordId;
  @track columns = columns;
  selectedRows = [];
  @track cancelledDate;
  @track amendedDate;
  @track amendQuantity;
  @track isLoaded = false;

  @wire(getAssets, { accountId: "$recordId" })
  assets({ error, data }) {
    if (data) {
      this.assetList = data;
    } else if (error) {
      this.error = error;
      this.assetList = undefined;
    }
  }

  handleRowSelection = (event) => {
    this.selectedRows = event.detail.selectedRows;
    console.log(this.selectedRows);
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

  handleDate(event) {
    this.cancelledDate = event.currentTarget.value;
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
