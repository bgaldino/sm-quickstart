import { LightningElement, api } from 'lwc';
import requestForAQuotes from '@salesforce/apex/RSM_RequestForQuote.requestForAQuotes';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import communityId from '@salesforce/community/Id';
import getCartItemsByCartId from '@salesforce/apex/B2BGetInfo.getCartItemsByCartId';
import isisQuoteCreated from '@salesforce/apex/SM_CouponService.isQuoteCreated';

export default class Rsm_requestForQuote extends LightningElement {

    quoteMsg = '';
    cartId;
    showSpinner =false;
    currentUrl = window.location.href;
    requestQuoteModal = false;
    _communityId = communityId;
    isbuttonDisabled = false;


    @api
    backgroundColor;

    get colorBackground() {
        return `background-color:${this.backgroundColor};`;
    }

    @api get buttonText(){

        return this._buttonText;
    }


    set buttonText(value) {
        console.log(value, 'value____');
        this._buttonText = value;
       
    }

    connectedCallback() {
        
        let urlParameters = this.currentUrl.match(/[a-z0-9]\w{4}0\w{12}|[a-z0-9]\w{4}0\w{9}/g);
        this.cartId = urlParameters[0];
        this.isQuoteCreated();
        this.getcartItems();
    }

    isQuoteCreated(){ 
        isisQuoteCreated({cartId: this.cartId})
        .then(result => {
            this.isbuttonDisabled = result;
            console.log('isisQuoteCreated: ' + result);
        })
        .catch(error => {
            console.error('isisQuoteCreated:: error :', JSON.stringify(error));
        });
    }

    getcartItems(){

        getCartItemsByCartId({cartId : this.cartId}).then(result => {

            console.log(JSON.stringify(result), 'json___');
            if(Object.keys(result).length === 0){

                this.isbuttonDisabled = true;
                console.log(JSON.stringify(result), 'cartItem Result');
            }

            for (const key in result) {

                if (result.hasOwnProperty(key)) {
            
                    console.log(`${key}: ${result[key].discount}`);
                    if(result[key].discount > 0 || result[key].adjustmentAmount < 0){
                        this.isbuttonDisabled = true;
                    }
            
                }
            }
            
            

        }).catch(error =>{

            console.log(error);
        })

    }

    handleRequestQuote(){
        this.requestQuoteModal = true;
    }

    closeQuoteModal(){
        this.requestQuoteModal = false;
    }

    handleQuoteMsg(event){
        console.log('>>>>> '+event.target.value)  ;  
        this.quoteMsg = event.target.value;

    }
    
    initiateQuoteRequest(){
        this.showSpinner = true;
        requestForAQuotes({cartId:this.cartId,cartType:'New',quoteMsg:this.quoteMsg, communityId : this._communityId})
            .then(result => {
                
                if(result != null){
                    console.log('result quote',JSON.stringify(result));
                    console.log('result isSuccess',result.isSuccess);
                    
                    if(result.isSuccess){
                        console.log('enter here');
                        this.requestQuoteModal = false;
                        const evt = new ShowToastEvent({
                            title: 'Success',
                            message: 'Request Sent!!',
                            variant: 'success',
                            mode: 'dismissable'
                        });
                        this.showSpinner = true;
                       // this.dispatchEvent(evt);
                        this.isRequestQuoteDisbaled = true;
                        setTimeout(() => {
                            this.navigateToCart(this.cartId);
                        }, 2000);
                        //this.handleCartUpdate();
                        //this.showSpinner = false;
                        
                    }
                   

                }
            })
            .catch(error => {
                this.isRequestQuoteDisbaled = false;
                this.isSubmitForRQDisbaled = false;
                console.log('Error '+JSON.stringify(error));
                
            });

        

    }


    navigateToCart(cartId) {
        console.log('cartId --- ', cartId);
        window.location.reload();
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__recordPage',
        //     attributes: {
        //         recordId: cartId,
        //         objectApiName: 'WebCart',
        //         actionName: 'view'
        //     }
        // });
    }



}