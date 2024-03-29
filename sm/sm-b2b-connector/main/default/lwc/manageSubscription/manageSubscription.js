import { LightningElement, track, wire} from 'lwc';
import getUserSubscriptions from '@salesforce/apex/RSM_Subscription.getUserSubscriptions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import iconsImg from '@salesforce/resourceUrl/smb2b_img';
import icons from '@salesforce/resourceUrl/smb2b_icons';
import renewAsset from '@salesforce/apex/RSM_PaymentMethod.initiateRenewal';
import cancelAssetAPI from '@salesforce/apex/RSM_CancelAsset.initiateCancellation';
import nextbillingDate from '@salesforce/apex/RSM_CancelAsset.getNextBillingDate';
import communityId from '@salesforce/community/Id';
import successMsg from '@salesforce/label/c.RSM_Asset_Action_Success_Message';
import amendAssets from '@salesforce/apex/RSM_CancelAsset.amendAssets';
import getDefaultCurrency from '@salesforce/apex/B2BGetInfo.getPartnerUserCurrency';

export default class ManageSubscription extends LightningElement {

    @track assets = [];
    pageNumber= 1;
    pageSize;
    totalItemCount= 0;
    openModel = false;
    assetId;
    totalprice;
    defaultCurrency;

    dots = `${iconsImg}#dots`;
    edit = `${icons}#edit`;
    eye = `${icons}#eye`;
    autorenew =  `${icons}#auto-renew`;
    refresh =  `${icons}#refresh`;
    pause =  `${icons}#pause`;
    cancel =  `${icons}#cancel`;
    minus = `${iconsImg}#minus`;
    plus = `${iconsImg}#plus`;
    showLoader = false;
    showLoaderMenue = false;
    isModalOpen = false;
    nextBillingDate;
    assetEndDate;
    assetStartDate;
    assetProductName;
    assetTotalQty = 0;
    modifyAssetId;
    visibleAssets;
    isRenewal = false;
    isAmendIncrease = false
    isAmendDecrease = false;
    isAmend = false;

    label = {
        successMsg
    }

    @wire(getDefaultCurrency)
    wiredCurrency({ data, error }) {
        if (data) {
            this.defaultCurrency = data;
        } else if (error) {
            // Handle error
            console.error(error);
        }
    }


   connectedCallback(){
    
    this.getSubs();

   }




   handleCloseModal(event){
    this.isModalOpen = event.detail;

   }

   handleAmendDecraseQty(event){

        event.preventDefault();
        this.isAmend = true;
        this.isAmendIncrease = false;
        this.isAmendDecrease = true;
        this.isRenewal = false;
        this.isModalOpen = true;


   }

   handleAmendIncreaseQty(event){
        event.preventDefault();
        console.log('clicked amend button');
        this.isAmend = true;
        this.isAmendIncrease = true;
        this.isAmendDecrease = false;
        this.isRenewal = false;
        this.isModalOpen = true;
   }



   handleCancelAssetfromModal(event){

    
    this.isModalOpen = event.detail;
    // this.handleCancelAsset();
    this.handleCancelAssetAPI();
   

   }

   handleAmend(event){
        let data = event.detail;
        this.isModalOpen = false;
        this.showLoader = true;
        this.addRemoveQty(data)

   }

   addRemoveQty(data){

    let amdendData = {
    assetId: this.modifyAssetId,
    quantityChange: 1
  };
			
    //let assetId = this.modifyAssetId;
											
    let quantityChange = 1;
    if(data.isAdd == true){
         amdendData.quantityChange = data.changeQuantity; // Get the quantity change from a component property
    }else{
        console.log(quantityChange);
        if(parseInt(data.changeQuantity) >= this.assetTotalQty){

             this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Quantity limit exceeded. Please enter a quantity that is within the available quantity limit.',
                            variant: 'Error',
                             mode: 'sticky',
                        }),
                );
                this.showLoader = false;
                return;

        }else{

        amdendData.quantityChange = parseInt(data.changeQuantity) * -1;

        }
    }
   
    console.log(JSON.stringify(amdendData) + '  Qty change');

    amendAssets({amendData: JSON.stringify(amdendData)})
        .then(result => {
            this.showLoader = false;
            console.log(result);
                this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Asset successfully modified.',
                            variant: 'success',
                        }),
                );
        })
        .catch(error => {
             this.showLoader = false;
            // Handle the error
            this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Something went wrong!!' + JSON.stringify(error),
                            variant: 'error',
                        }),
                );
        });



   }


   handleRenewalAssetfromModal(event){
    this.isModalOpen = event.detail;  
    this.renewAssetMethod(event);

   }

   handleMenuClick(event){

    console.log(event.currentTarget.dataset.assetid, 'assetId______');
    this.modifyAssetId = event.currentTarget.dataset.assetid;
    this.handleNextBillingDate();


   }

   handleCancelAssetAPI(){

    this.showLoader = true;
    console.log(this.modifyAssetId, 'asset___________');

    let cancelData = {
        assetId: this.modifyAssetId
    }
   
    cancelAssetAPI({cancelData :JSON.stringify(cancelData)}).then(result=> {

        console.log(JSON.stringify(result), 'result cancel api________');
        let resultData = JSON.parse(result.response);
        let strResultDate = JSON.stringify(resultData);
        let isError = strResultDate.includes("errorCode");
        if(isError){

            if(resultData[0].errorCode === 'INVALID_API_INPUT'){

                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: resultData[0].message,
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(evt);
        
               }
        } else{
           
        /*const evt = new ShowToastEvent({
            title: 'Success',
            message: 'Asset has been canceled.',
            variant: 'success',
            mode: 'dismissable'
        });*/
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

        console.log(error, 'cancel api error');
        this.showLoader = false;

    })
}

   handleNextBillingDate(){
    
    this.showLoaderMenue = true;
    nextbillingDate({assetId : this.modifyAssetId}).then(result => {


        console.log(JSON.stringify(result), 'result____');
        this.nextBillingDate = result.nextBillingDate;
        this.assetEndDate = result.assetEndDate;
        this.assetStartDate = result.assetStartDate;
        this.assetProductName = result.productName;
        this.assetTotalQty = result.totalQty;
        this.showLoaderMenue = false;



    }).catch(error => {

        console.log(error);
        this.showLoaderMenue = false;
    })

}

   
   handlePreviousPage()
   {
       this.pageNumber = this.pageNumber - 1;
       this.getSubs();
   }

   handleNextPage() 
   {
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
x
renewAssetMethod(event){
    event.preventDefault();
    this.showLoader = true;

    let renewalData = {
        assetId: this.modifyAssetId
    }
   

    console.log(this.modifyAssetId, 'assetid_____');

    //let modifyAssetId = this.modifyAssetId;
    
    renewAsset({renewalData : JSON.stringify(renewalData)}).then(result => {

        console.log(result, 'Asset Result_____');
        const evt = new ShowToastEvent({
            title: 'Thanks',
            // message: 'Your request has been submitted, please wait for confirmation email.',
            message: this.label.successMsg,
            variant: 'info',
            mode: 'dismissable'
        });
        
        this.dispatchEvent(evt);


       

        this.showLoader = false;
       


    }).catch(error=> {

        console.log(error, 'error_____in asset renewal');
        this.showLoader = false;
    })


}

    handleCancel(event){
        event.preventDefault();
        console.log('clicked cancel button');
        this.isRenewal = false;
        this.isAmendDecrease = false;
        this.isAmendIncrease = false;
        this.isAmend = false;
        this.isModalOpen = true;
       

    }

    handleRenewal(event){
        event.preventDefault();
        console.log('clicked renewal button');
        this.isRenewal = true;
        this.isModalOpen = true;
         this.isAmendIncrease = false;
         this.isAmendDecrease = false;
         this.isAmend = false;

    }

    updateAssetHandler(event){
        this.visibleAssets=[...event.detail.records]
        console.log(event.detail.records)
    }


   getSubs(){
       this.showLoader = true;
       getUserSubscriptions({pageNumber: this.pageNumber, communityId : communityId}).then( (response) => {
           console.log('response',JSON.stringify(response));
           this.assets = response;
           this.showLoader = false;
       } ).catch( (error) => {
           console.log('Problem response B2B_Subscriptions.getUserSubscriptions - Details: '+JSON.stringify(error));
           this.showLoader = false;
       } );
   }

   openModalBox(event){
     
       
       event.preventDefault();
       this.assetId = event.currentTarget.dataset.assetid;
       this.totalprice = event.currentTarget.dataset.totalprice;
       this.openModel = true;
       
   }

   handleAssetRefresh(){
    console.log('component Refreshed');
    this.getSubs();

   }

   closeModalBox(event){

    this.openModel = event.detail;

   }
}