import { LightningElement, api,wire } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import Colors from '@salesforce/resourceUrl/B2B_Colors';
import iconsImg from '@salesforce/resourceUrl/img';
import getPaymentInfo from '@salesforce/apex/B2BPaymentController.getPaymentInfo';
import submitPoOrder from '@salesforce/apex/B2BPaymentController.submitPoOrder';
import setPaymentInfo from '@salesforce/apex/B2BPaymentController.setPaymentInfo';
import callCreatePaymentMethodAPI from '@salesforce/apex/B2BPaymentController.callCreatePaymentMethodAPI';
import { NavigationMixin } from 'lightning/navigation';
import getCountriesAndStates from "@salesforce/apex/B2BGetInfo.getCountriesAndStates";
import submitCreditCardOrder from '@salesforce/apex/B2BPaymentController.submitCreditCardOrder';

import updatePAError from '@salesforce/apex/B2BPaymentController.updatePaymentAuthError';

import getVFOrigin from '@salesforce/apex/B2BPaymentController.getVFOrigin';


import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { FlowNavigationNextEvent, FlowAttributeChangeEvent } from 'lightning/flowSupport';

export default class B2bStripePaymentNew extends NavigationMixin(LightningElement) {
    hidePurchaseOrder = false;
    hideCreditCard = false;
    selectedPaymentType = 'PoNumber';
    isPoNumberSelected = true;
    isCardPaymentSelected = false;
    fname = '';
    lname = '';
    addressLine1 ='';
    zipCode = '';
    city = '';
    state = '';
    country = '';
    info = `${iconsImg}#info`;
    tnc = false;
    @api tncLabel = '<p>By clicking “I Accept” below, you are indicating that you have read and consent to our  <a href="https://markforged.com/allowable-use/" target="_blank" >Allowable Use Policy</a> and to the applicable terms and conditions posted  <a href="https://markforged.com/legal/" target="_blank">here</a>. Resellers must pass applicable terms to their end-users.</p>';
    handleTNC(event){
        if(this.isCardPaymentSelected == true){
            if(this.fname != '' && this.lname != '' && this.addressLine1 != '' && this.zipCode != '' && this.country != ''){
                this.tnc = event.target.checked;
                this.tNcBool = true;
            }else{
                this.showToast(
                    'Please fill all the required fields',
                    'error'
                );
                console.log('Dont proceed error');
                event.target.checked = false;
                this.tnc = event.target.checked;
            }
        }else{
            if(this.purchaseOrderNumber != '' && this.purchaseOrderNumber != undefined){
                this.tnc = event.target.checked;
                this.tNcBool = true;
            }else{
                this.showToast(
                    'Please fill all the required fields',
                    'error'
                );
                event.target.checked = false;
                this.tnc = event.target.checked;
            }
        }
    }
    handleFName(event){
        this.fname = event.target.value;
        //console.log('fname-- ',this.fname);
    }
    handleLName(event){
        this.lname = event.target.value;
        //console.log('lname-- ',this.lname);
    }
    handleAddLine(event){
        this.addressLine1 = event.target.value;
        //console.log('addressLine1-- ',this.addressLine1);
    }
    handleZipCode(event){
        this.zipCode = event.target.value;
        //console.log('zipCode-- ',this.zipCode);
    }
    handleState(event){
        this.state = event.target.value;
    }
    handleCity(event){
        this.city = event.target.value;
    }
    handleCountry(event){
        //this.country = 'US';
        this.country = event.detail.value;
    }

    get options() {
        return [
                 { label: 'United States', value: 'US' },
                 { label: 'Canada', value: 'CA' },
                 { label: 'India', value: 'IN' },
               ];
    }
    iframeUrl;
    // Wire getVFOrigin Apex method to a Property
    @wire(getVFOrigin)
    vfOrigin;
    tNcBool;
    handlePaymentTypeSelected(event) {
        //check this
        this.purchaseOrderNumber = '';
        this.fname = '';
        this.lname = '';
        this.addressLine1 = '';
        this.zipCode = '';
        this.country = '';
        //check end

        this.selectedPaymentType = event.currentTarget.value;
        this.tNcBool = false;
        if (this.selectedPaymentType == 'PoNumber') {
            this.isPoNumberSelected = true;
            this.isCardPaymentSelected = false;
            this.tnc = false;
        } else if (this.selectedPaymentType == 'cardPayment') {
            this.isPoNumberSelected = false;
            this.isCardPaymentSelected = true;
            this.tnc = false;
            setTimeout(() => {
                //this.initStripe();
            }, 1000);

        }
    }
    purchaseOrderNumber;
    purchaseOrderNumberCustomer;
    handlePoUpdate(event) {
        this.purchaseOrderNumber = event.detail.value;
    }
    handleCustomerPoUpdate(event) {
        this.purchaseOrderNumberCustomer = event.detail.value;
    }
    stripe;
    elements;
    cart;
    @api paymentType;
    @api enteredPoNumberValue;
    @api cartId;
    @api stripeUrl = 'https://js.stripe.com/v3/';
    cardElement;
    showSpinner = false;
    canPay = false;
    stripeCustomerId;
    submitOrderCalled = false;
    handleVFResponse(message) {
        //console.log('In handle vf respone method no---');
        var cmp = this;
        if (message.origin === this.vfOrigin.data) {
            let receivedMessage = message.data;
            if(receivedMessage && receivedMessage != null){
                /*if(receivedMessage.addErrorCss == true){
                        this.template.querySelector("iframe").style.cssText = 'border: none; height: 110px;';
                }else{
                    this.template.querySelector("iframe").style.cssText = 'border: none; height: 50px;';
                }*/
                if(receivedMessage.hasOwnProperty('addCss')){
                    var addCssToStripe = receivedMessage.addCss;
                    //console.log('heee-- ',addCssToStripe);
                    if(addCssToStripe === "error"){
                        this.template.querySelector("iframe").style.cssText = 'border: none; height: 110px;';
                    }
                    if(addCssToStripe === "noError"){
                        this.template.querySelector("iframe").style.cssText = 'border: none; height: 50px;';
                    }
                    if(addCssToStripe === true){
                        this.template.querySelector("iframe").style.cssText = 'border: none; height: 700px;';
                        cmp.showSpinner = false;
                    }
                    if(addCssToStripe === false){
                        this.template.querySelector("iframe").style.cssText = 'border: none; height: 50px;';
                        cmp.showSpinner = true;
                    }
                }
                else if(receivedMessage.hasOwnProperty('paId')){
                    let dataMap = {
                        paId: receivedMessage.paId
                    }
                    updatePAError({dataMap: dataMap})
                    .then(function (result) {
                        cmp.showSpinner = false;
                    });
                }
                else{
                    if(receivedMessage.cToken && receivedMessage.cToken != null &&  receivedMessage.cToken.token && receivedMessage.cToken.token != null){
                        if(this.submitOrderCalled){
                            return ;
                        }
                        this.submitOrderCalled = true;
                        this.submitCCOrder(receivedMessage);
                    }
                }
            }
        }
    }
    
    submitCCOrder(receivedMessage){
        let dataMap = {
            "cartId": this.cartId,
            "endCustomerPONumber": this.purchaseOrderNumberCustomer,
            "paymentMethod": 'CC',
            "stripeCustomerId": this.stripeCustomerId,
            "cToken": receivedMessage.cToken.token,
            "cPay" : receivedMessage.cPay.paymentIntent,
            "cTokenId": receivedMessage.cToken.token.id,
            "cPayId" : receivedMessage.cPay.paymentIntent.id,
            "name" : this.fname + ' '+ this.lname
        };
        submitCreditCardOrder({
            dataMap: dataMap
        }).then((result) => {
            if(result && result.isSuccess){
                //call method to create payment method using SM API
                this.createStripePaymentMethod(result);
                /*const navigateNextEvent = new FlowNavigationNextEvent();
                this.dispatchEvent(navigateNextEvent);*/
            }else{
                this.showToast(result.msg,'error');
            }
        }).catch((e) => {
            this.showToast(
                e.message,
                'error'
            );
        });
    }
    createStripePaymentMethod(result){
        let dataMap = result;
        callCreatePaymentMethodAPI({
            dataMap: dataMap
        }).then((result)=>{
            console.log('callCreatePaymentMethodAPI completed-- ',result);
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }).catch((e)=>{
            this.showToast(
                e.message,
                'error'
            );
        });
    }

    showCustPo = false;

    goback(){
        let pageRef = {
        type: 'standard__webPage',
        attributes: {
            url: '/checkout/' + this.cartId
        }
        };
        this[NavigationMixin.Navigate](pageRef);
    }

    connectedCallback() {
        console.log('Inside connectedCallback');
        loadStyle(this, Colors);
        window.addEventListener("message", this.handleVFResponse.bind(this));
        let dataMap = {
            cartId: this.cartId
        };
        this.showSpinner = true;
        getPaymentInfo({
            dataMap: dataMap
        })
            .then((result) => {
                this.showSpinner = false;
                if (result && result.isSuccess) {
                    this.hidePurchaseOrder = result.hidePurchaseOrder;
                    this.hideCreditCard = result.hideCreditCard;
                    this.cart = result.cart;
                    this.canPay = result.canPay;
                    if(result.userType == 'Partner'){
                        this.showCustPo = true;
                    }
                    if(!result.hideCreditCard){
                        this.stripeCustomerId = result.stripeCustomerId ;
                        this.iframeUrl = result.iframeUrl;//https://lynxdev-markforged.cs125.force.com/shop/apex/B2BStripePay
                        //this.loadStripe(result);
                        if(result.hidePurchaseOrder){
                            this.isPoNumberSelected = false;
                            this.isCardPaymentSelected = true;
                            this.selectedPaymentType = 'cardPayment';
                        }
                    }
                    
                } else {
                    this.showToast('No payment Methods Found', 'error');
                }
            })
            .catch((e) => {
                this.showToast(
                    'Some Error occured while processing this Opportunity,Please contact System admin.',
                    'error'
                );
            });

    }

    loadStripe(result) {
        //this.stripeCustomerId = result.stripeCustomerId ;
        loadScript(this, this.stripeUrl)
            .then(() => {
                console.log('Stripe script loaded--- ');
                var stripe = Stripe(result.stripConfig.Public_Key__c);
                this.stripe = stripe;
            }
            ).catch(error => console.log(error));
    }

    initStripe() {
        console.log('InitStripe to load the card details cmp');
        var stripe = this.stripe;
        var elements = stripe.elements();
        this.elements = elements;
        
        const cardWrapper = this.template.querySelector("div.cardWrapper");
        const style = {
            base: {
                color: '#32325d',
                lineHeight: '18px',
                fontFamily: '"Helvetica Neue", Helvetica, sans-serif',
                fontSmoothing: 'antialiased',
                fontSize: '16px',
                '::placeholder': {
                    color: '#aab7c4'
                }
            },
            invalid: {
                color: '#fa755a',
                iconColor: '#fa755a'
            },
            empty: {
                color: '#fa755a',
                iconColor: '#fa755a'
            }
        };
        this.cardElement = elements.create("card", { style, hidePostalCode: true });
        this.cardElement.mount(cardWrapper);
    }

    handleFiretoVF(message) {
        console.log('inside handle fire to vf no',JSON.stringify(message));
        this.template.querySelector("iframe").contentWindow.postMessage(JSON.stringify(message), this.vfOrigin.data);
    }
    canSubmitPayment(){
        console.log('buttonClicked');
        let compRef = this;
        if(this.selectedPaymentType == 'cardPayment'){
            if(this.fname == '' || this.lname == '' || this.addressLine1 == '' || this.zipCode == '' || this.country == ''){
                compRef.showToast(
                    'Please fill all the required fields',
                    'error'
                );
            }else{
                this.submitOrder();
            }
        }else if(this.selectedPaymentType == 'PoNumber'){
            if(this.purchaseOrderNumber == '' || this.purchaseOrderNumber == undefined){
                this.showToast(
                    'Please fill all the required fields',
                    'error'
                );
            }else{
                this.submitOrder();
            }
        }
    }
    submitOrder() {
        let selectedPaymentType =  this.selectedPaymentType ;
        if (selectedPaymentType == 'PoNumber') {
            this.submitPoOrder();
        }else if(selectedPaymentType == 'cardPayment'){
            const attributeChangeEvent = new FlowAttributeChangeEvent('paymentType', this.selectedPaymentType);
            this.dispatchEvent(attributeChangeEvent);
            this.submitCardOrder();
        }
    }

    submitPoOrder(){
        if(this.validatePoCheckout()){
            let dataMap = {
                "cartId": this.cartId,
                "poNumber": this.purchaseOrderNumber,
                "endCustomerPONumber": this.purchaseOrderNumberCustomer,
                "paymentMethod": 'PO'
            };
            this.showSpinner = true;
            submitPoOrder({
                dataMap: dataMap
            }).then((result) => {
                this.showSpinner = false;
                if(result && result.isSuccess){
                    //const attributeChangeEvent = new FlowAttributeChangeEvent('paymentType', 'TESTSTRING');
                    const attributeChangeEvent = new FlowAttributeChangeEvent('paymentType', this.selectedPaymentType);
                    this.dispatchEvent(attributeChangeEvent);
                    const attributeChangeEvent2 = new FlowAttributeChangeEvent('enteredPoNumberValue', this.purchaseOrderNumber);
                    this.dispatchEvent(attributeChangeEvent2);  
                    const navigateNextEvent = new FlowNavigationNextEvent();
                    this.dispatchEvent(navigateNextEvent);
                }else{
                    this.showToast(result.msg,'error');
                }
                    
            }).catch((e) => {
                console.log("error-- ",e);
                this.showToast(
                    'Some Error occured while processing PO Number,Please contact System admin.',
                    'error'
                );
            });
        }
    }

    showToast(message ,variant) {
        let title = variant == 'error' ? 'Error' : 'Success';
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    validatePoCheckout(){
        const poInput = this.getComponent('[data-po-number]');
        if (poInput != null && poInput.reportValidity())
        {
            return true;
        }else{
            return false;
        }
    }

    validateCCCheckout(){
        return true;
    }

    submitCardOrder(){

        if(this.validateCCCheckout()){
            let dataMap = {
                "cartId": this.cartId,
                "endCustomerPONumber": this.purchaseOrderNumberCustomer,
                "paymentMethod": 'CC',
                "stripeCustomerId": this.stripeCustomerId
            };
            this.showSpinner = true;
            //this.hideCreditCard  = true;
            setPaymentInfo({
                dataMap: dataMap
            }).then((result) => {
                
                if(result && result.PI_Secret){
                    result.billing_details = {
                        name : this.fname + ' '+ this.lname,//'static user sure',
                        //email : 'staticUser@yopmail.com',
                        address: {
                            line1: this.addressLine1,//"164 Indusco Ct.",
                            //line2: "this.address2",
                            city: this.city,//"Troy",
                            state: this.state,//"Washington",
                            country: this.country,//"US",
                            postal_code: this.zipCode//"48083"
                        }
                    };
                    this.handleFiretoVF(result);
                }
                //const navigateNextEvent = new FlowNavigationNextEvent();
                //this.dispatchEvent(navigateNextEvent);
            }).catch((e) => {
                this.showToast(
                    e.message,
                    'error'
                );
            });
        }
    }
    stripeCardPayment;
    /*confirmStripeCardPayment(result){
        this.stripe.confirmCardPayment(result.PI_Secret,{
            payment_method:{
                card: this.cardElement,
                billing_details: result.billing_details,
            },setup_future_usage: true ? 'on_session' : ''
        }).then((response) => {
            var t = response;
            if(response.error){
                var temperr = response.error;
            }else{
                var temp = response;
                this.stripeCardPayment = response;
                //this.createStripeToken(response);
                this.createStripeToken(response);
            }
        }).catch((e) => {
            this.showToast(
                e.message,
                'error'
            );
        });
    }*/

    async confirmStripeCardPayment(receivedfromLWC) {
        try{
            var el = this.elements.getElement('card');
            const cPay = await this.stripe.confirmCardPayment(receivedfromLWC.PI_Secret, {
                payment_method: {
                    card: this.cardElement,
                    billing_details: receivedfromLWC.billing_details,
                }, setup_future_usage: true ? 'on_session' : ''
            });
            if (cPay) {
                if (cPay.error) {
                    console.log('Errorr---- ',cPay);
                    this.createStripeToken(cPay);
                    //showError(cPay.error.message);
                   //updatePAError(receivedfromLWC.PA_Id);
                } else {
                    console.log('Passed---- ',el);
                    this.stripeCardPayment = cPay;
                    this.createStripeToken(cPay);
                    //hideError();
                    //createToken(cPay,receivedfromLWC);

                }
            }
        }catch(e){
            console.log('Exception--- ',e);
        }
    }

    stripeToken;
    createStripeToken(result){
        console.log('in createStripeToken----- ', JSON.stringify(result));
        this.stripe.createToken(this.cardElement)
        .then((result) => {
            if(result.error){
                this.showSpinner = false;
                console.log('createStripeToken error----- ',JSON.stringify(result.error));
            }else{
                var temp = result;
                this.stripeToken = result;
                let dataMap = {
                    "cToken":this.stripeToken,
                    "cPay":this.stripeCardPayment
                };
                let resp = {
                    "data": dataMap,
                    "origin":this.vfOrigin.data
                };

                this.handleVFResponse(resp);
                console.log('createStripeToken passed----- ',JSON.stringify(result),temp);
            }
        }).catch((e) => {
            this.showToast(
                e.message,
                'error'
            );
        });
    }
    getComponent(locator) {
        return this.template.querySelector(locator);
    }

}