import { LightningElement, track} from 'lwc';
import getUserSubscriptions from '@salesforce/apex/RSM_Subscription.getUserSubscriptions';
import getMyInvoices from '@salesforce/apex/RSM_MyInvoices.getUserInvoices';
import retrieveOrderDetailPDF from '@salesforce/apex/RSM_MyInvoices.retrieveOrderDetailPDF';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import iconsImg from '@salesforce/resourceUrl/img';
import icons from '@salesforce/resourceUrl/icons';

export default class B2b_MyInvoices extends LightningElement {

    assets = [];
    @track invoices = [];
    pageNumber= 1;
    pageSize;
    totalItemCount= 0;
    openModel = false;
    assetId;
    totalprice;
    showSpinner = false;
    currentPage;
    totalPage;
    disableNext;
    disablePrevious;

    dots = `${iconsImg}#dots`;
    edit = `${icons}#edit`;
    eye = `${icons}#eye`;
    autorenew =  `${icons}#auto-renew`;
    refresh =  `${icons}#refresh`;
    pause =  `${icons}#pause`;
    cancel =  `${icons}#cancel`;
    next = `${icons}#plus`;
    minus = `${icons}#minus`;

   connectedCallback(){
        this.showSpinner = true;
        this.getSubs();
   }

   onCancelEvent(){

    this.showToast('Subscription Cancel', 'Subscription has been Cancelled.');

   }

   onRenewEvent(){

    this.showToast('Subscription Renewal', 'Subscription has been Renewed.');

   }

   
   handlePreviousPage()
   {
       this.pageNumber = this.pageNumber - 1;
       this.showSpinner = true;
       this.getSubs();
   }

   handleNextPage() 
   {
       this.pageNumber = this.pageNumber + 1;
       this.showSpinner = true;
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


   getSubs(){
        getMyInvoices({pageNumber: this.pageNumber})
        .then( (response) => {
            this.showSpinner = false;
            this.disableNext = false;
            this.disablePrevious = false;
            console.log('getMyInvoices response--- ',JSON.stringify(response));
            this.invoices = response;
            this.currentPage = Number(response.pageNumber*response.pageSize);
            this.totalPage = Number(response.totalItemCount);
            if(this.currentPage == response.pageSize){
                this.disablePrevious = true;
            }
            if(response.records.length < response.pageSize){
                this.disableNext = true;
                this.currentPage = this.totalPage;
            }
        }).catch( (error) => {
            this.showSpinner = false;
            console.log('Problem response RSM_MyInvoices.getUserInvoices - Details: '+JSON.stringify(error));
        });
   }

   openModalBox(event){
     
       //
       //console.log(assetId, 'assetId---');
       event.preventDefault();
       this.assetId = event.currentTarget.dataset.assetid;
       this.totalprice = event.currentTarget.dataset.totalprice;
       this.openModel = true;
       
   }

   closeModalBox(event){

    this.openModel = event.detail;

   }

   downloadInvoicePDF(event){
        this.showSpinner = true;
        var invId = event.target.dataset.invid;
        console.log('downloadInvoicePDF--- ',invId);
        
        retrieveOrderDetailPDF({invoiceId: invId})
        .then( (response) => {
            this.showSpinner = false;
            console.log('getMyInvoices response--- ',JSON.stringify(response));
            //var url = '/servlet/servlet.FileDownload?file='+response;
            var url = response.domainUrl+'/servlet/servlet.FileDownload?file='+response.docId;
            window.open(url);
            //this.invoices = response;
        }).catch( (error) => {
            this.showSpinner = false;
            console.log('Problem response RSM_MyInvoices.retrieveOrderDetailPDF - Details: '+JSON.stringify(error));
        });
        
   }
}