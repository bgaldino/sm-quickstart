import { LightningElement, wire, track, api} from 'lwc';
import getUserSubscriptions from '@salesforce/apex/RSM_Subscription.getUserSubscriptions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import iconsImg from '@salesforce/resourceUrl/smb2b_img';
import icons from '@salesforce/resourceUrl/smb2b_icons';
import renewAsset from '@salesforce/apex/RC_ManageAsset.renewAssets';
import cancelAsset from '@salesforce/apex/RC_ManageAsset.cancelAssets';
import amendAsset from '@salesforce/apex/RC_ManageAsset.amendAssets';
import assetData from '@salesforce/apex/RC_ManageAsset.getAssetData';
import getAssets from '@salesforce/apex/RC_ManageAsset.getAssetInfo';
import communityId from '@salesforce/community/Id';
import successMsg from '@salesforce/label/c.RSM_Asset_Action_Success_Message';
import getAssetInfo from '@salesforce/apex/RC_ManageAsset.getAssetInfo';

export default class ManageSubscription extends LightningElement {
    @track assets = [];
    @track assetList;
    @track error = null;
    @track cancelledDate
    @track amendedDate;
    assetMap = new Map();
    a_Record_URL;
    asyncIdList = new Set();
    quantity;

    pageNumber= 1;
    pageSize;
    totalItemCount= 0;
    openModel = false;
    assetId;
    totalprice;

    dots = `${iconsImg}#dots`;
    edit = `${icons}#edit`;
    eye = `${icons}#eye`;
    autorenew =  `${icons}#auto-renew`;
    refresh =  `${icons}#refresh`;
    pause =  `${icons}#pause`;
    cancel =  `${icons}#cancel`;
    showLoader = false;
    showLoaderMenue = false;
    isModalOpen = false;
    nextBillingDate;
    assetEndDate;
    modifyDate;
    assetStartDate;
    assetProductName;
    modifyAssetId;
    visibleAssets;
    isRenewal = false;
    label = {
        successMsg
    }

    connectedCallback() {
        this.getSubs();
    }

    handleCloseModal(event) {
        this.isModalOpen = event.detail;
    }

    handleCancelAssetfromModal(event) {
        this.isModalOpen = event.detail;
        // this.handleCancelAsset();
        this.handleCancelAssetAPI();
    }

    handleRenewalAssetfromModal(event) {
        this.isModalOpen = event.detail;
        this.renewAssetMethod(event);
    }

    handleAmendAssetfromModal(event) {
        this.isModalOpen = event.detail;
        this.handleAmendAsset();
    }
    
    handleMenuClick(event) {
        console.log(event.currentTarget.dataset.assetid, 'assetId______');
        this.modifyAssetId = event.currentTarget.dataset.assetid;
        this.handleNextBillingDate();
    }
    
    handleAmendAsset() {
        this.showLoader = true;
        console.log(this.modifyAssetId, 'asset___________');
        amendAsset({assetId :this.modifyAssetId}).then(result=> {
        console.log(JSON.stringify(result), 'result amend api________');
        let resultData = JSON.parse(result.response);
        let strResultDate = JSON.stringify(resultData);
        let isError = strResultDate.includes("errorCode");
        if(isError) {
            if(resultData[0].errorCode === 'INVALID_API_INPUT') {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: resultData[0].message,
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(evt);
        
               }
            } else {
                const evt = new ShowToastEvent({
                    title: 'Thanks',
                    // message: 'Your request has been submitted, please wait for confirmation email.',
                    message: this.label.successMsg,
                    variant: 'info',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            }
            this.showLoader = false;
        }).then(error => {
            console.log(error, 'amend api error');
            this.showLoader = false;
        })
    }
    
    handleCancelAssetAPIorig() {
        this.showLoader = true;
        console.log(this.modifyAssetId, 'asset___________');
        cancelAsset({assetId: this.modifyAssetId}).then(result => {
            console.log(JSON.stringify(result), 'result cancel api________');
            const resultData = JSON.parse(result.response);
            const isError = resultData.some(res => res.hasOwnProperty('errorCode'));
            if (isError) {
                const errorMessage = resultData[0].message;
                if (resultData[0].errorCode === 'INVALID_API_INPUT') {
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: errorMessage,
                        variant: 'error',
                        mode: 'sticky'
                    });
                this.dispatchEvent(evt);
            }
            } else {
                const evt = new ShowToastEvent({
                    title: 'Thanks',
                    message: this.label.successMsg,
                    variant: 'info',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            }
            this.showLoader = false;
        }).catch(error => {
            console.log(error, 'cancel api error');
            this.showLoader = false;
        })
    }

    handleCancelAssetAPI() {
      this.showLoader = true;
      console.log(this.modifyAssetId, 'asset___________');
      const cancelDate = new Date(this.modifyDate);
      console.log(cancelDate, 'cancelDate_______')
      cancelAsset({assetId: this.modifyAssetId, cancelDate: cancelDate})
        .then((data) => {
                this.processAPIRequests(data);
        })
        .catch((error) => {
            this.error = error;
        });
    }
    
    
    handleNextBillingDate() {
        this.showLoaderMenue = true;
        assetData({assetId : this.modifyAssetId}).then(result => {
            console.log(JSON.stringify(result), 'result____');
            this.nextBillingDate = result.nextBillingDate;
            console.log(this.nextBillingDate, 'nextBillingDate____');
            this.modifyDate = (result.nextBillingDate)+'T00:00:00-00:00';
            console.log(this.modifyDate, 'modifyDate____');
            this.assetEndDate = result.assetEndDate;
            console.log(this.assetEndDate, 'assetEndDate____')
            this.assetStartDate = result.assetStartDate;
            console.log(this.assetStartDate, 'assetStartDate____')
            this.assetProductName = result.productName;
            console.log(this.assetProductName, 'assetProductName____')
            this.showLoaderMenue = false;
        }).catch(error => {
            console.log(error);
            this.showLoaderMenue = false;
        })
    }
    
    handlePreviousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.getSubs();
    }
    
    handleNextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.getSubs();
    }
    
    showToast(title, message) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
    
    renewAssetMethod(event) {
        event.preventDefault();
        this.showLoader = true;
        console.log(this.modifyAssetId, 'assetid_____');
        let modifyAssetId = this.modifyAssetId;
        renewAsset({assetId : modifyAssetId}).then(result => {
            console.log(result, 'Asset Result_____');
            const evt = new ShowToastEvent({
                title: 'Thanks',
                message: this.label.successMsg,
                variant: 'info',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            this.showLoader = false;
        }).catch(error=> {
            console.log(error, 'error_____in asset renewal');
            this.showLoader = false;
        });
    }
    
    handleCancel(event) {
        event.preventDefault();
        console.log('clicked cancel button');
        this.isRenewal = false;
        this.isModalOpen = true;
    }

    handleRenewal(event) {
        event.preventDefault();
        console.log('clicked renewal button');
        this.isRenewal = true;
        this.isModalOpen = true;
    }

    updateAssetHandler(event) {
        this.visibleAssets=[...event.detail.records]
        console.log(event.detail.records)
    }
    
    getSubs() {
        this.showLoader = true;
        getUserSubscriptions({pageNumber: this.pageNumber, communityId : communityId}).then( (response) => {
            console.log('response',JSON.stringify(response));
            this.assets = response;
            this.showLoader = false;
        }).catch((error) => {
            console.log('Problem response B2B_Subscriptions.getUserSubscriptions - Details: '+JSON.stringify(error));
            this.showLoader = false;
        });
    }
    
    openModalBox(event) {
        event.preventDefault();
        this.assetId = event.currentTarget.dataset.assetid;
        this.totalprice = event.currentTarget.dataset.totalprice;
        this.openModel = true;
    }
    
    handleAssetRefresh() {
        console.log('component Refreshed');
        this.getSubs();
    }
    
    closeModalBox(event) {
        this.openModel = event.detail;
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

    removeAsyncId(statusURL) {
        this.asyncIdList.delete(statusURL);
    }
}