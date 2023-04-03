import { LightningElement, wire, track, api } from 'lwc';
import getAssets from '@salesforce/apex/AssetManagementController.getAssetsByAccount'
import renewAssets from '@salesforce/apex/AssetManagementController.renewAssets'
import cancelAssets from '@salesforce/apex/AssetManagementController.cancelAssets'
import amendAssets from '@salesforce/apex/AssetManagementController.amendAssets'
import AssetManagementLabel from '@salesforce/label/c.AssetManagement';

const columns = [
    {
        label: 'Asset Name', fieldName: 'recordURL', type: 'url',
        typeAttributes: { label: { fieldName: 'name' }, target: '_blank' }
    },
    {
        label: 'Lifecycle Start Date', fieldName: 'lifeCycleStartDate', type: 'date', typeAttributes: {
            day: "2-digit",
            month: "2-digit",
            year: "numeric",
            timeZone: "UTC"
        }
    },
    {
        label: 'Lifecycle End Date', fieldName: 'lifeCycleEndDate', type: 'date', typeAttributes: {
            day: "2-digit",
            month: "2-digit",
            year: "numeric",
            timeZone: "UTC"
        }
    },
    { label: 'Renewal Term Unit', fieldName: 'renewalTermUnit', type: 'text' },
    { label: 'Renewal Term', fieldName: 'renewalTerm', type: 'Number' },
];

const columnsUpdated = [
    {
        label: 'Asset Name', fieldName: 'recordURL', type: 'url',
        typeAttributes: { label: { fieldName: 'name' }, target: '_blank' }
    },
    {
        label: 'Lifecycle Start Date', fieldName: 'lifeCycleStartDate', type: 'date', typeAttributes: {
            day: "2-digit",
            month: "2-digit",
            year: "numeric",
            timeZone: "UTC"
        }
    },
    {
        label: 'Lifecycle End Date', fieldName: 'lifeCycleEndDate', type: 'date', typeAttributes: {
            day: "2-digit",
            month: "2-digit",
            year: "numeric",
            timeZone: "UTC"
        }
    },
    { label: 'Renewal Term Unit', fieldName: 'renewalTermUnit', type: 'text' },
    { label: 'Renewal Term', fieldName: 'renewalTerm', type: 'Number' },
    {
        label: 'Status', fieldName: 'StatusURL', type: 'url',
        typeAttributes: { label: { fieldName: 'Status' }, target: '_blank' }
    },
];


export default class AssetManagement extends LightningElement {
    @track assetList;
    @track error;
    @track columns = columns;
    @track cancelledDate
    @track amendedDate;
    @track isToggle = {isLoaded: false, isCancelDatePopup: false, isButtonsActivated: true, isAmendDatePopup: false }
    @track selectedRows = [];
    @track selectedRowsAPI = []
    @track AssetManagementLabel = AssetManagementLabel
    @api recordId
    assetMap = new Map();
    a_Record_URL;
    asyncIdList = new Set();
    quantity;

    connectedCallback() {
        this.a_Record_URL = window.location.origin;
    }

    @wire(getAssets, { accountId: '$recordId' })
    assets({ error, data }) {
        if (data) {
            this.assetList = this.generateTree(data)
        }
        else if (error) {
            this.error = error;
            this.assetList = undefined;
        }
    }

    generateTree(data) {
        data.forEach(element => {
            let tempConRec = Object.assign({}, element);
            tempConRec._children = []
            this.assetMap.set(tempConRec.assetId, tempConRec);
        })
        let assetList = Array.from(this.assetMap.values());
        let r = [], h = assetList.reduce((a, c) => (a[c.assetId] = c, a), {});
        assetList.forEach((c, i, a, e = h[c.parentId]) => {
            (e ? (e._children) : r).push(c)
        });
        return r;
    }

    handleRowSelection(event) {
        this.selectedRows = [];
        let selectedRows = event.detail.selectedRows;
        if (selectedRows.length > 0) {
            let tempList = [];
            selectedRows.forEach(selectedRecord => {
                tempList.push(selectedRecord.assetId);
                this.selectedRows.push(selectedRecord);
            })
            /* 
            let assetList = Array.from(this.assetMap.values());
            assetList.forEach(asset => {
                if (asset.parentId !== undefined) {

                    if (tempList.includes(asset.parentId)) {
                        tempList.push(asset.assetId);
                        this.selectedRows.push(asset);
                    }
                }
            })
            */
            this.selectedRowsAPI = tempList;
        }

        this.isToggle.isButtonsActivated = selectedRows.length > 0 ? false : true;
    }

    toggleCancelDatePopup = () => {
        this.isToggle.isCancelDatePopup = this.isToggle.isCancelDatePopup === false ? true : false
    }

    toggleAmendDatePopup = () => {
        this.isToggle.isAmendDatePopup = this.isToggle.isAmendDatePopup === false ? true : false
    }

    get toggleCancelAssetButton() {
        return this.selectedRowsAPI.length > 0 && this.cancelledDate !== undefined ? false : true;
    }

    get toggleAmendAssetButton() {
        return this.selectedRowsAPI.length > 0 && this.amendedDate !== undefined && this.quantity !== undefined ? false : true;
    }

    handleAction = event => {
        let actionType = event.currentTarget.name;
        this.isToggle.isLoaded = true;
        if (actionType === 'Renew') {
            this.handleRenewAssets();
        }
        else if (actionType === 'Cancel') {
            this.handleCancelAssets();
        }
        else if (actionType === 'Amend') {
            this.handleAmendAssets();
        }
        this.isToggle.isLoaded = false;
        this.isToggle.isCancelDatePopup = false;
    }


    handleRenewAssets = () => {
        renewAssets({ assetList: this.selectedRows })
            .then((data) => {
                this.processAPIRequests(data);
            })
            .catch((error) => {
                this.error = error;
            });
    }

    handleCancelAssets = () => {
        cancelAssets({ assetList: this.selectedRows, cancelDate: this.cancelledDate })
            .then((data) => {
                this.processAPIRequests(data);
            })
            .catch((error) => {
                this.error = error;
            });
        this.isToggle.isCancelDatePopup = false;
    }

    handleAmendAssets = () => {
        amendAssets({ assetList: this.selectedRows, amendDate: this.amendedDate, quantity: this.quantity })
            .then((data) => {
                this.processAPIRequests(data);
            })
            .catch((error) => {
                this.error = error;
            });
        this.isToggle.isAmendDatePopup = false;
    }

    processAPIRequests = (data) => {
        const status = 'Submitted'
        data.forEach(asset => {
            let assetRecord = this.assetMap.get(asset.assetId);
            assetRecord.StatusURL = this.a_Record_URL + '/' + asset.statusURL;
            assetRecord.Status = status;
            assetRecord.requestIdentifier = asset.requestIdentifier;
            this.asyncIdList.add(asset.statusURL);
        });
        this.columns = columnsUpdated;
        this.assetList = this.generateTree(Array.from(this.assetMap.values()));
    }

    handleDate(event) {
        this.cancelledDate = event.currentTarget.value;
    }

    handleAmendDate(event) {
        let elemId = event.currentTarget.dataset.id
        if (elemId === 'AmendDate')
            this.amendedDate = event.currentTarget.value;

        if (elemId === 'quantity')
            this.quantity = event.currentTarget.value;
    }

    handleEvent(event) {
        let obj = event.detail.data.payload;
        let data = Array.from(this.assetMap.values());
        data.forEach(asset => {
            if (asset.requestIdentifier == obj.RequestIdentifier) {
                this.removeAsyncId(asset.statusURL)
                if (obj.HasErrors) {
                    asset.Status = 'Completed With Failures';
                    asset.StatusURL = this.a_Record_URL + '/lightning/r/RevenueTransactionErrorLog/' + asset.assetId + '/related/PrimaryRevenueTransactionErrorLogs/view';
                }
                else {
                    if (obj.hasOwnProperty('RenewalRecordId')) {
                        asset.Status = 'Renewed';
                        asset.StatusURL = this.a_Record_URL + '/' + obj.RenewalRecordId;
                    }
                    else if (obj.hasOwnProperty('CancellationRecordId')) {
                        asset.Status = 'Cancelled';
                        asset.StatusURL = this.a_Record_URL + '/' + obj.CancellationRecordId;
                    }
                    else {
                        asset.Status = 'Amended';
                        asset.StatusURL = this.a_Record_URL + '/' + obj.AmendmentRecordId;
                    }
                }
            }
        })
        this.assetList = this.generateTree(data);
    }

    removeAsyncId(statusURL) {
        this.asyncIdList.delete(statusURL);
    }
}