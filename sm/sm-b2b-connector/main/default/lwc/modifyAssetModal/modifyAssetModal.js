import { LightningElement, api} from 'lwc';
import iconsImg from '@salesforce/resourceUrl/img';
import { loadStyle } from 'lightning/platformResourceLoader';
import Colors from '@salesforce/resourceUrl/B2B_Colors';
import Fonts from '@salesforce/resourceUrl/B2B_Fonts';
import BoldFonts from '@salesforce/resourceUrl/B2B_Fonts_Bold';
import getPurchaserDetails from '@salesforce/apex/RSM_PaymentMethod.getPurchaserInfo';
import buyerInfoUpdate from '@salesforce/apex/RSM_PaymentMethod.updateBuyerInfo';
import nextbillingDate from '@salesforce/apex/RSM_CancelAsset.getNextBillingDate';
import billingShippingAddress from '@salesforce/apex/RSM_PaymentMethod.getBillingShippingAddress';
import billingAddressUpdate from '@salesforce/apex/RSM_PaymentMethod.updateBillingAddress';
import shippingAddressUpdate from '@salesforce/apex/RSM_PaymentMethod.updateShippingAddress';
import numberOfMonths from '@salesforce/apex/RSM_PaymentMethod.getAssetMonths';

export default class ModifyAssetModal extends LightningElement {

    minus = `${iconsImg}#minus`;
    plus = `${iconsImg}#plus`;
    info = `${iconsImg}#info`;

    @api modifyAssetId;
    @api totalPrice;
    cardList;
    contact = {};
    emailChange;
    phoneChange;
    nameChange;
    showLoader = false;
    showCardPaymentFields = false;
    cardHolderName;
    cardNumber;
    ExpiryMonth;
    securityCode;
    cardValue='';
    isModalOpen = false;
    isEvergreen;
    nextBillingDate;
    billingAddress={};
    shippingAddress={};
    isAddressChanged = false;
    isShippingAddressChanged = false;
    assetMonths;

    
    connectedCallback(){
       
        this.showLoader = true;
        loadStyle( this, Fonts);
        loadStyle(this, BoldFonts);
        loadStyle(this, Colors);
        this.getNumberOfMonths();
        this.getPurchaserInfo();
        this.getBillingAndShippingAddress();

    }

    getNumberOfMonths(){

        numberOfMonths({assetId : this.modifyAssetId}).then(result =>{


            console.log(result, 'result___');
            this.assetMonths = result;


        }).catch(error => {

            console.log(error);
        })



    }

    handleBillingName(event){

        this.isAddressChanged = true;
        this.billingAddress.Name =  event.target.value;

    }

    handleStreet(event){
        this.isAddressChanged = true;
        this.billingAddress.Street =  event.target.value;

    }

    handleCity(event){
        this.isAddressChanged = true;
        this.billingAddress.City =  event.target.value;

    }

   

    handleState(event){
        this.isAddressChanged = true;
        this.billingAddress.State =  event.target.value;

    }

    handleBillZip(event){
        this.isAddressChanged = true;
        this.billingAddress.PostalCode =  event.target.value;

    }

    handleCounty(event){
        this.isAddressChanged = true;
        this.billingAddress.Country =  event.target.value;

    }


    handleShipllingName(event){
        this.isShippingAddressChanged = true;
        this.shippingAddress.Name =  event.target.value;

    }

    handleShipStreet(event){
        this.isShippingAddressChanged = true;
        this.shippingAddress.Street =  event.target.value;

    }

    handleShipCity(event){
        this.isShippingAddressChanged = true;
        this.shippingAddress.City =  event.target.value;

    }

    
    handleShipState(event){
        this.isShippingAddressChanged = true;
        this.shippingAddress.State =  event.target.value;

    }
      
    handleShipCounty(event){
        this.isShippingAddressChanged = true;
        this.shippingAddress.Country =  event.target.value;

    }

    handleShipZip(event){
        this.isShippingAddressChanged = true;
        this.shippingAddress.PostalCode =  event.target.value;

    }






    updateShippingAddress(){

        shippingAddressUpdate({shippingAddress : JSON.stringify(this.shippingAddress)}).then(result => {

            console.log('result___', JSON.stringify(result));


        }).catch(error =>{

            console.log(error, 'Shipping Address Update Error_____________');
        })


    }




    updateBillingAddress(){

        billingAddressUpdate({billingAddress : JSON.stringify(this.billingAddress)}).then(result => {

            console.log('result___', JSON.stringify(result));


        }).catch(error =>{

            console.log(error, 'Billing Address Update Error_____________');
        })


    }


  

    getBillingAndShippingAddress(){

        billingShippingAddress().then(result => {

            console.log(JSON.stringify(result), 'Billing and Shipping Address Data');
            this.billingAddress =result.Billing;
            this.shippingAddress = result.Shipping;

        }).catch(error=>{

            console.log(error, 'Billing Shipping Address Error');
        })


    }

    handleNextBillingDate(){

        nextbillingDate({assetId : this.modifyAssetId}).then(result => {


            console.log(JSON.stringify(result), 'result____');
            this.nextBillingDate = result.nextBillingDate;



        }).catch(error => {

            console.log(error);
        })

    }

    




   handleCloseModal(event){

    this.isModalOpen = event.detail;

   }



   

    handleContactName(event){

        console.log( event.target.value);
        this.nameChange = event.target.value;

    }

    handleEmailChange(event){

        console.log( event.target.value);
        this.emailChange = event.target.value;


    }

    handlePhoneChange(event){

        console.log( event.target.value);
        this.phoneChange = event.target.value;
    }



  


    handleSave(){

        console.log(JSON.stringify(this.billingAddress), 'Billing Address');

        this.updateBuyerInfoDetails();
        // this.createPaymentMethod();
        if(this.isAddressChanged == true){
            this.updateBillingAddress();
            
        }

        if(this.isShippingAddressChanged == true){

            this.updateShippingAddress();
          
        }

        const custEvent = new CustomEvent(
            'refreshasset', {
                detail: false 
            });

        this.dispatchEvent(custEvent);


    }

    getPurchaserInfo(){

        getPurchaserDetails().then(result => {


            console.log(JSON.stringify(result), 'result---');
            this.contact = result;
            this.showLoader = false;


        }).catch(error =>{

            console.log(error,'error----');
            this.showLoader = false;
        })
    }

    updateBuyerInfoDetails(){

        this.showLoader = true;
        buyerInfoUpdate({name:this.nameChange, email : this.emailChange, phone : this.phoneChange}).then(result => {

            console.log('Success');
            const custEvent = new CustomEvent(
                'closemodal', {
                    detail: false 
                });
    
            this.dispatchEvent(custEvent);
            this.showSuccess();
            this.showLoader = false;





        }).catch(error =>{

            this.showLoader = true;
            console.log(error);
        })
    }

    handleCancel(){

        const custEvent = new CustomEvent(
            'closemodal', {
                detail: false 
            });

        this.dispatchEvent(custEvent);
    }


}