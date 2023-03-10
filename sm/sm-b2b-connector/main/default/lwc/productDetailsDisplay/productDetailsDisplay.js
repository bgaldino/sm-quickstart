import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';
import Colors from '@salesforce/resourceUrl/B2B_Colors';
import Fonts from '@salesforce/resourceUrl/B2B_Fonts';
import BoldFonts from '@salesforce/resourceUrl/B2B_Fonts_Bold';
import communityId from '@salesforce/community/Id';
import iconsImg from '@salesforce/resourceUrl/img';
import addToCart from '@salesforce/apex/B2BGetInfo.addToCart';
import doesProductHasDiscount from '@salesforce/apex/B2BGetInfo.doesProductHasDiscount';
import AccountId from '@salesforce/schema/Case.AccountId';
import getCartSummary from '@salesforce/apex/B2BGetInfo.getCartSummary';
import calculatePrice from '@salesforce/apex/B2BGetProducts.calculatePrice';
import calculatePriceAPI from '@salesforce/apex/B2BGetProducts.calculatePriceApi';
import Id from '@salesforce/schema/Account.Id';
import errorLabel from '@salesforce/label/c.B2B_Negative_Or_Zero_Error';
import isguest from '@salesforce/user/isGuest';
import discountedCartChangeMessage from "@salesforce/label/c.RSM_Discounted_Webcart_Change_Error_Message";

const homePage = {
    name: 'Home',
    type: 'standard__namedPage',
    attributes: {
        pageName: 'home'
    }
};

export default class ProductDetailsDisplay extends NavigationMixin(LightningElement) {
   
    @api customFields;
    @api cartLocked;
    @api description;
    @api image;
    @api inStock = false;
    @api name;
    @api price;
    @api id;
    @api sku;
    @api accountId;
    @api currentPrice;
    isGuestUser = isguest;

    currentPriceBookEntryId;
    discountErrorModal = false;

    originalListPrice = 0;
    hasTotalPrice = true;
    smUnitPrice = 0;
    totalPrice = 0;
    totalPriceMultipliedByTwelve = 0;

    cartSummary;
    showSelectedPrice = true;
    isMonthly = true;

    selectedPricingModel;
    pricingModels=[];
    addToCartIsDisabled = false;
    @api
    get pricingModel() {
        //console.log('get Pricing model');
        return this._pricingModel;
    }

    set pricingModel(pricingModel) {
        //console.log('set Pricing model', pricingModel); 
        this._pricingModel = pricingModel;
        this.setSellingModels();
    }

    label = {
        discountedCartChangeMessage
    }

    hasDiscountBeenApplied;

    setSellingModels(){

        let pricingModels = [];
        let models   = JSON.parse(JSON.stringify(this._pricingModel));
        // console.log('setSellingModels models===== '+JSON.stringify(models));
        //if(models !=undefined && models.product && models.product.PricebookEntries){ //made by surya
            if(models !=undefined && models.product && models.PricebookEntries){

            //if(models.product.PricebookEntries !=undefined){
                //let pricebookEntries  = models.product.PricebookEntries;        //made by surya
                let pricebookEntries  = models.PricebookEntries;
                //this.currentPriceBookEntryId = models.product.PricebookEntries[0].Id;
                //console.log('setSellingModels pricebookEntries===== '+JSON.stringify(pricebookEntries));
                /*filter out the pricebookEntries with ProductSellingMedelId*/
                pricebookEntries =  pricebookEntries.filter(priceBook =>priceBook.ProductSellingModelId !=undefined);
                
                /*var swap = function (x){return x};
                
                for (var i = 0; i < pricebookEntries.length; i++) {
                    if(pricebookEntries[i].ProductSellingModel.Name == 'Evergreen Monthly') {
                        pricebookEntries[i] = swap(pricebookEntries[0], pricebookEntries[0]=pricebookEntries[1]);
                    }
                }*/
                let first = 'Evergreen Monthly';
                pricebookEntries.sort(function(x,y){ 
                    return x.ProductSellingModel.Name == first ? -1 : y.ProductSellingModel.Name == first ? 1 : 0; 
                });
                this.currentPriceBookEntryId = pricebookEntries[0].Id;

                pricebookEntries.forEach(function (pricebook, index) {
                    let modelName = pricebook.ProductSellingModel.Name;
                    let cyclePayed;
                    let showPrice = true;
                    let isMonthly = true;
                   // console.log('setSellingModels  ' + JSON.stringify(pricebook.ProductSellingModel.Name));

                    if(modelName != 'One-Time'){
                        cyclePayed = 'Billed in advance at the beginning of each billing cycle';
                    } else {
                        isMonthly = false;
                    }

                    if(modelName == 'One-Time' || modelName == 'Evergreen Monthly' || modelName == 'Term Annual'){
                        showPrice = false;
                    }

                    if(pricebook.ProductSellingModel.Name == 'Term Monthly'){
                        modelName = 'Annual Subscription (paid monthly)';
                    } else if(pricebook.ProductSellingModel.Name == 'Term Annual'){
                        modelName = 'Annual Subscription (paid upfront)';
                        isMonthly = false;
                    }

                    pricingModels.push({
                        Id: pricebook.Id,
                        Pricebook2Id: pricebook.Pricebook2Id,
                        checked: index==0? true:false,
                        Product2Id: pricebook.Product2Id,
                        ProductSellingModelId: pricebook.ProductSellingModelId,
                        UnitPrice: pricebook.UnitPrice,
                        totalPriceMultipliedByTwelve: pricebook.UnitPrice*12,
                        ProductSellingModelName: modelName,
                        ProductSellingModel: pricebook.ProductSellingModel.Name,
                        ProductSellingModelType: pricebook.ProductSellingModel.SellingModelType,
                        ProductSellingModelTermUnit: pricebook.ProductSellingModel.PricingTermUnit,
                        BillingCycle: cyclePayed,
                        ShowPrice: showPrice,
                        IsMonthly: isMonthly
                    });
                });
                this.selectedPricingModel = pricingModels.length > 0 ? pricingModels[0]:{};
            //}
            this.pricingModels =  pricingModels;
            // console.log('setSellingModels this.pricingModels===== '+JSON.stringify(this.pricingModels));
            this.initiatePriceCall();
        }
    }

    handleSubscriptionChange(event){
        // console.log('this.selectedPricingModel event--',JSON.stringify(event.target.dataset));
        let priceBookEntryId = event.target.dataset.id;
        this.currentPriceBookEntryId = event.target.dataset.id;
        let pricebookId = event.target.dataset.pricebook;
        let pricingModelId = event.target.dataset.modelid;
        let productType = event.target.dataset.producttype;
        // console.log(productType, 'productType----');
        this.pricingModels.filter(model => model.Id===priceBookEntryId);
        // console.log('filtered this.pricingModels---- ',this.pricingModels);
        for(let i=0;i<this.pricingModels.length;i++){
            if(this.pricingModels[i].Id===priceBookEntryId){
                this.pricingModels[i].checked = true;
            }else{
                this.pricingModels[i].checked = false;
            }
        }
        const result = this.pricingModels.filter(model => model.Id===priceBookEntryId);
        this.selectedPricingModel = result.length > 0?result[0]:{};
        //console.log('this.selectedPricingModel--'+JSON.stringify(this.selectedPricingModel));
        this.initiatePriceCall();
    }
    
    initiatePriceCall(){
        this.addToCartIsDisabled = true;
        //this.template.querySelector('[data-id="quantity"]').value = this._quantityFieldValue;
         calculatePriceAPI({
            listPricebookId: this.selectedPricingModel.Pricebook2Id,
            candidatePricebookIds : [this.selectedPricingModel.Pricebook2Id],
            productId : this.selectedPricingModel.Product2Id,
            quantity : parseInt(this._quantityFieldValue),
            ProductSellingModelId : this.selectedPricingModel.ProductSellingModelId
        })
        .then((result) => {
            // console.log('pdp price result', JSON.stringify(result.response));
            let pricing = JSON.parse(result.response);
            let totalPrice = pricing.records[1].record.ListPrice;
            //let totalPrice = pricing.records[1].record.TotalPrice;
            this.totalPrice = totalPrice;
            this.totalPriceMultipliedByTwelve = pricing.records[1].record.ListPrice*12;
            this.smUnitPrice = pricing.records[1].record.NetUnitPrice;
            this.originalListPrice = pricing.records[1].record.StartingUnitPrice;
            this.hasTotalPrice = true;
            this.showSelectedPrice = this.selectedPricingModel.ShowPrice;
            this.isMonthly = this.selectedPricingModel.IsMonthly;
            this.addToCartIsDisabled = false;
        })
        .catch((error) => {                    
            console.log(error);
        });

    }


    prodQuanity = 1;
    _invalidQuantity = false;
    _quantityFieldValue = 1;
    _categoryPath;
    _resolvedCategoryPath = [];
    
    _resolveConnected;
    _connected = new Promise((resolve) => {
        this._resolveConnected = resolve;
    });

    minus = `${iconsImg}#minus`;
    plus = `${iconsImg}#plus`;

    connectedCallback() {
        this._resolveConnected();
        loadStyle( this, Fonts);
        loadStyle(this, BoldFonts);
        loadStyle(this, Colors);
        this.updateCartInformation();
        this.checkIfDiscuntHasBeenApplied();
      //  this.initiatePriceCall();
    }

    disconnectedCallback() {
        this._connected = new Promise((resolve) => {
            this._resolveConnected = resolve;
        });
    }

    @api
    get categoryPath() {
        //console.log('categoryPath get');
        return this._categoryPath;
    }

    set categoryPath(newPath) {
        //console.log('categoryPath set');
        this._categoryPath = newPath;
        this.resolveCategoryPath(newPath || []);
    }

    get hasPrice() {
        //return ((this.price || {}).negotiated || '').length > 0;
        return this.currentPrice;
    }

    get hasSelectedPrice(){
        //return ((this.price || {}).negotiated || '').length > 0;
        //console.log('hasSelectedPrice----- ',(this.pricingModels || {}).length > 0);
        return (this.pricingModels || {}).length > 0;
    }

    get _isAddToCartDisabled() {
        return this._invalidQuantity || this.cartLocked || !this.inStock;
    }

    /*handleQuantityChange(event) {
        if (event.target.validity.valid && event.target.value) {
            this._invalidQuantity = false;
            this._quantityFieldValue = event.target.value;
        } else {
            this._invalidQuantity = true;
        }
    }*/
    handleQuantityChange(event) {
        if (event.target.value) {
            console.log('It there')
            this._invalidQuantity = false;
            this._quantityFieldValue = event.target.value;
            this.prodQuanity = event.target.value;
            this.initiatePriceCall();
        } else {
            this._invalidQuantity = true;
        }
    }

    closeModal(){
        this.discountErrorModal = false;
    }

    checkIfDiscuntHasBeenApplied() {
        doesProductHasDiscount({
            communityId: communityId,
            effectiveAccountId: this.accountId
        })
            .then((result) => {
                this.hasDiscountBeenApplied = result;
            })
            .catch((e) => {
                console.err('ERR: ', e);
            });
    }

    updateCartInformation() {
        getCartSummary({
            communityId: communityId,
            effectiveAccountId: this.account
        })
            .then((result) => {
                this.cartSummary = result;
                // console.log('*** summary ' + JSON.stringify(result));
            })
            .catch((e) => {
                console.log(e);
            });
    }

    handleOnlyNaturalkeyup(e) {
        if(e.target.value.length==1) {
            e.target.value=e.target.value.replace(/[^1-9]/g,'')
        } else {
            e.target.value=e.target.value.replace(/\D/g,'')
        }
        this.handleQuantityChange(e);
    }

    handleOnlyNaturalAfterPaste(e) {
        if(e.target.value.length==1) {
            e.target.value=e.target.value.replace(/[^1-9]/g,'0')
        } else {
            e.target.value=e.target.value.replace(/\D/g,'')
        }
    }

    notifyAddToCart(evt) {
         // console.log('---Unit Price----' + JSON.stringify(this.selectedPricingModel.UnitPrice));    
         if(this.hasDiscountBeenApplied) {
            this.discountErrorModal = true;
            return;
        }
         if(this.isGuestUser){

            let fullUrl = window.location.href;
        
            let baseUrl = fullUrl.substring(0,fullUrl.indexOf("/s/"));
            location.href = baseUrl+'/s/'+ 'login';


         }else{
          let setPrise;
          if(this.totalPrice){
              setPrise = this.totalPrice;
          } else if(this.selectedPricingModel.UnitPrice){
              setPrise = this.selectedPricingModel.UnitPrice;
          } else {
              setPrise = this.currentPrice;
          }
          console.log('---setPrice----' + JSON.stringify(setPrise));
          let quantity = this._quantityFieldValue;
          let qu =  this.template.querySelector('.prodQuanityinput').value;
          // console.log('****this.selectedPricingModel.Name' + JSON.stringify(this.selectedPricingModel.ProductSellingModelName));
          if(qu > 0) {
            addToCart({
                communityId: communityId,
                productName: this.name,
                cartId: this.cartSummary.cartId,
                productId: this.id.split('-')[0],
                price: setPrise,//this.selectedPricingModel.UnitPrice, //this.currentPrice,
                quantity: quantity,
                priceBookEntryId:  this.currentPriceBookEntryId,
                modelName: this.selectedPricingModel.ProductSellingModel,
                modelType: this.selectedPricingModel.ProductSellingModelType,
                modelTermUnit: this.selectedPricingModel.ProductSellingModelTermUnit,
                effectiveAccountId: this.accountId
            })
                .then((result) => {
                  //   console.log('*** add ' + JSON.stringify(result));
                    if(result){
                    this.dispatchEvent(
                        new CustomEvent('cartchanged', {
                            bubbles: true,
                            composed: true
                        })
                    );
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Your cart has been updated.',
                            variant: 'success',
                            mode: 'dismissable'
                        })
                    );
                } else{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message:
                                '{0} could not be added to your cart at this time. Please try again later.',
                            messageData: [this.name],
                            variant: 'error',
                            mode: 'dismissable'
                        })
                    );
                }
                })
                .catch(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message:
                                '{0} could not be added to your cart at this time. Please try again later.',
                            messageData: [this.name],
                            variant: 'error',
                            mode: 'dismissable'
                        })
                    );
                });
          } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message:
                        `${errorLabel}`,
                    messageData: [this.name],
                    variant: 'error',
                    mode: 'dismissable'
                })
            );
          }
          /*this.dispatchEvent(
              new CustomEvent('addtocart', {
                  detail: {
                      quantity
                  }
              })
          );*/

            }
        }

        notifyCreateAndAddToList() {
            this.dispatchEvent(new CustomEvent('createandaddtolist'));
        }
    
        resolveCategoryPath(newPath) {
            const path = [homePage].concat(
                newPath.map((level) => ({
                    name: level.name,
                    type: 'standard__recordPage',
                    attributes: {
                        actionName: 'view',
                        recordId: level.id
                    }
                }))
            );
    
            this._connected
                .then(() => {
                    const levelsResolved = path.map((level) =>
                        this[NavigationMixin.GenerateUrl]({
                            type: level.type,
                            attributes: level.attributes
                        }).then((url) => ({
                            name: level.name,
                            url: url
                        }))
                    );
    
                    return Promise.all(levelsResolved);
                })
                .then((levels) => {
                    this._resolvedCategoryPath = levels;
                });
        }

    addQty(){
        if(this.hasDiscountBeenApplied) {
            this.discountErrorModal = true;
        } else {
            this.prodQuanity = this.prodQuanity + 1;
            this._quantityFieldValue =this.prodQuanity;
            this._invalidQuantity = false;
            this.initiatePriceCall();
        }
    }

    subQuanity(){
        if(this.hasDiscountBeenApplied) {
            this.discountErrorModal = true;
        } else {
            if(this.prodQuanity > 1){
                this.prodQuanity = this.prodQuanity - 1;
                this._invalidQuantity = false;
                this._quantityFieldValue = this.prodQuanity;
                this.initiatePriceCall();
            }
        }
    }
}