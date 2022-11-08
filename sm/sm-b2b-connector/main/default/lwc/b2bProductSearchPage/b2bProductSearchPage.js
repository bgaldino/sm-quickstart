import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import iconsImg from '@salesforce/resourceUrl/img';

import communityId from '@salesforce/community/Id';
//import productSearch from '@salesforce/apex/B2B_SearchController.productSearch';
import productSearch from '@salesforce/apex/B2B_SearchController.productSearchIterable';
import getSortRule from "@salesforce/apex/B2B_SearchController.getSortRule";
import getCartSummary from '@salesforce/apex/B2BGetInfo.getCartSummary';
import getPrices from '@salesforce/apex/B2B_RelatedProductsController.getProductPrices';
//import addToCart from '@salesforce/apex/B2BGetInfo.addToCart';
import addToCartWithSubscription from '@salesforce/apex/B2B_SubscriptionController.addToCart';
//import getActiveCartStatus from '@salesforce/apex/B2B_ProceedToCheckOutCntrl.getActiveCartStatus';
//import createQuotes from '@salesforce/apex/B2B_ProceedToCheckOutCntrl.createQuotes';
import checkQueueStatus from '@salesforce/apex/B2B_CartController.checkQueueStatus';
import { transformData } from './b2bDataNormalizer';
import { loadStyle } from 'lightning/platformResourceLoader';
import Colors from '@salesforce/resourceUrl/B2B_Colors';
import Fonts from '@salesforce/resourceUrl/B2B_Fonts';
import BoldFonts from '@salesforce/resourceUrl/B2B_Fonts_Bold';

export default class B2bProductSearchPage extends NavigationMixin(LightningElement) {


    @api
    get effectiveAccountId() {
        return this._effectiveAccountId;
    }

    set effectiveAccountId(newId) {
        this._effectiveAccountId = newId;
    }

    @api
    get recordId() {
       return this._recordId;
    }
    set recordId(value) {
        this._recordId = value;
        this._landingRecordId = value;
        this.triggerProductSearch();
    }

  
    @api
    get term() {
        return this._term;
    }
    termSearched;
    set term(value) {
        this._term = value;
        if (value) {
            this.termSearched = value;
            this.triggerProductSearch();
        }
    }
    rowsView = `${iconsImg}#rows-view`;
    gridView = `${iconsImg}#grid-view`;
    showSpinner = false;
  
    @api
    get cardContentMapping() {
        return this._cardContentMapping;
    }
    set cardContentMapping(value) {
        this._cardContentMapping = value;
    }

    
    @api resultsLayout;
  
    @api showProductImage;
    
    @api displayData;
 
    @api config;
   
    connectedCallback(){
        loadStyle(this, Fonts);
        loadStyle(this, BoldFonts);
        loadStyle(this, Colors);
    }

    triggerProductSearch() {
        const searchQuery = JSON.stringify({
            searchTerm: this.term,
            categoryId: this.recordId,
            refinements: this._refinements,
            includeQuantityRule:true,
    
            page: this._pageNumber - 1,
            pageSize:15,
            grouping :{groupingOption:'VariationParent'},
            includePrices: true,
            sortRuleId: this.defaultRule
        });
        //console.log('**searchQuery ' + JSON.stringify(searchQuery));
        this._isLoading = true;
        productSearch({
            communityId: communityId,
            searchQuery: searchQuery,
            effectiveAccountId: this.resolvedEffectiveAccountId
        })
            .then((result) => {
              var resData = result;
                this._isLoading = false;
                return getPrices({productId : this.getProductIds(resData)})
                  .then(res => {
                    this.mergeProductPrices(resData, res);
                    this.displayData = resData;
              //      console.log('***disp ' + JSON.stringify(this.displayData));
                })
               // this.categoryPath = this.displayData.categoryPath;
             //   console.log('**this.displayData ' + JSON.stringify(this.displayData));
            })
            .catch((error) => {
                this.error = error;
                this._isLoading = false;
                console.log(error);
            });
    }
    getProductIds(result) {
        let test = (result.productsPage.products || []).map((product) => product.id);
        return test;
      }

    mergeProductPrices(result, prices) {
        (result.productsPage.products || []).forEach((product) => {
            //console.log('product'+ JSON.stringify(product));
          if (prices.hasOwnProperty(product.id)) {
           // console.log('prod --'+ prices[product.id]);
            product.price = prices[product.id];
            product.negotiatedPrice = prices[product.id];
            product.unitPrice = product.negotiatedPrice;
            
           // console.log('After Price --'+ JSON.stringify(product));
          }
        });
      }

    get config() {
        return {
            layoutConfig: {
                resultsLayout: this.resultsLayout,
                cardConfig: {
                    showImage: this.showProductImage,
                    resultsLayout: this.resultsLayout,
                    actionDisabled: this.isCartLocked
                }
            }
        };
    }

    get displayData() {
        return this._displayData || {};
    }
    set displayData(data) {
        this._displayData = transformData(data, this._cardContentMapping);
    }

    get isLoading() {
        return this._isLoading;
    }

    get hasMorePages() {
        return this.displayData.total > this.displayData.pageSize;
    }

    get pageNumber() {
        return this._pageNumber;
    }
    
    searchResultsfound = true;
    get headerText() {
        let text = '';
        const totalItemCount = this.displayData.total;
        const pageSize = this.displayData.pageSize;
        console.log('totalItemCount--- original-- '+totalItemCount+' pageSize--- original-- '+pageSize);
        if (totalItemCount > 1) {
            const startIndex = (this._pageNumber - 1) * pageSize + 1;

            const endIndex = Math.min(
                startIndex + pageSize - 1,
                totalItemCount
            );

            text = `${totalItemCount}  Results`;
            this.searchResultsfound = true;
        } else if (totalItemCount === 1) {
            text = '1 Result';
            this.searchResultsfound = true;
        } else{
            text = '0 Results found';
            this.searchResultsfound = false;
        }

        return text;
    }

    get resolvedEffectiveAccountId() {
        const effectiveAcocuntId = this.effectiveAccountId || '';
        let resolved = null;

        if (
            effectiveAcocuntId.length > 0 &&
            effectiveAcocuntId !== '000000000000000'
        ) {
            resolved = effectiveAcocuntId;
        }
        console.log('*** account ' + resolved);
        return resolved;
    }

    get isCartLocked() {
        const cartStatus = (this._cartSummary || {}).status;
        return cartStatus === 'Processing' || cartStatus === 'Checkout';
    }
    sortOptions;
    value = 'Best Match';
    defaultRule;
    @wire(getSortRule, {communityId: communityId})
    getSortRuleWired({ error, data }) {
        if (data) {
            try {
                let options = [];
                for (var key in data) {
                    options.push({ label: key, value: data[key]  });
                    if(key = 'Best Match'){
                      this.defaultRule = data[key];
                    }
                }
                this.sortOptions = options;
            } catch (error) {
                console.error('check error here', error);
            }
        } else if (error) {
            console.error('check error here', error);
        }
    }

    @track isListView;
    @track isGridView;
    @track gridIconClass = 'slds-button slds-button_icon slds-p-around_xxx-small gridClass slds-float_right active ';
    @track listIconClass = 'slds-button slds-button_icon slds-p-around_xxx-small listClass  slds-float_right ';

    handleSwitchLayout(e) {
        this.resultsLayout = e.currentTarget.dataset.value;
        this.gridIconClass = this.resultsLayout === 'grid' ? 'slds-button slds-button_icon slds-p-around_xxx-small gridClass slds-float_right active' :  'slds-button slds-button_icon slds-p-around_xxx-small slds-float_right gridClass ';
        this.listIconClass = this.resultsLayout === 'list' ? 'slds-button slds-button_icon slds-p-around_xxx-small listClass  slds-float_right active' :  'slds-button slds-button_icon slds-p-around_xxx-small  slds-float_right listClass ';
        this.triggerProductSearch();
    }

    handleAction(evt) {
        evt.stopPropagation();
        let addToCartDomain = {};
        addToCartDomain.unitPrice = evt.detail.price;
        addToCartDomain.listPrice = addToCartDomain.unitPrice;
        addToCartDomain.quantity  =  '1';
        addToCartDomain.productId  = evt.detail.productId;
        addToCartDomain.pricebookId  = '';
        addToCartDomain.currencyCode  = evt.detail.currency;
        addToCartDomain.communityId  = communityId;
        addToCartDomain.isProratedPrice = false;
        addToCartDomain.isRecurringProduct = false ;
        let cartItems = [];
        let cartItem = {};
        cartItem.unitPrice = addToCartDomain.unitPrice;
        cartItem.pricebookEntryId = evt.detail.pricebookEntryId;
        cartItem.quantity = evt.detail.quantity;
        cartItem.productId = evt.detail.productId;
        let productIdToCartItem = {};
        productIdToCartItem[cartItem.productId] = cartItem;
        addToCartDomain.productIdToCartItem  = productIdToCartItem;
        cartItems.push(cartItem);
        addToCartDomain.cartItems  = cartItems;
        /*console.log('addToCartDomain--'+addToCartDomain);*/

        addToCartWithSubscription({
            communityId: communityId,
            productId: evt.detail.productId,
            quantity: '1',
            effectiveAccountId: this.resolvedEffectiveAccountId,
            addToCartDomain:addToCartDomain,
            preserveCart:true
        })
            .then(() => {
                this.getCartStatus();
                setTimeout(() => {
                    //this.showSpinner = false;
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
                
                }, 5000);
            })
            .catch(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message:
                            '{0} could not be added to your cart at this time. Please try again later.',
                        messageData: [evt.detail.productName],
                        variant: 'error',
                        mode: 'dismissable'
                    })
                );
            });
    }

    handleClearAll(/*evt*/) {
        this._refinements = [];
        this._recordId = this._landingRecordId;
        this._pageNumber = 1;
        this.template.querySelector('c-filter').clearAll();
        this.triggerProductSearch();
    }

    handleShowDetail(evt) {
        evt.stopPropagation();

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: evt.detail.productId,
                actionName: 'view'
            }
        });
    }

    handlePreviousPage(evt) {
        evt.stopPropagation();

        this._pageNumber = this._pageNumber - 1;
        this.triggerProductSearch();
    }

    handleNextPage(evt) {
        evt.stopPropagation();

        this._pageNumber = this._pageNumber + 1;
        this.triggerProductSearch();
        var scrollOptions = {
            left: 0,
            top: 0,
            behavior: 'smooth'
        }
        window.scrollTo(scrollOptions);
    }

    handleFacetValueUpdate(evt) {
        evt.stopPropagation();

        this._refinements = evt.detail.refinements;
        this._pageNumber = 1;
        this.triggerProductSearch();
        var scrollOptions = {
            left: 0,
            top: 0,
            behavior: 'smooth'
        }
        window.scrollTo(scrollOptions);
    }

    handleCategoryUpdate(evt) {
        evt.stopPropagation();

        this._recordId = evt.detail.categoryId;
        this._pageNumber = 1;
        this.triggerProductSearch();
    }

    updateCartInformation() {
        getCartSummary({
            communityId: communityId,
            effectiveAccountId: this.resolvedEffectiveAccountId
        })
            .then((result) => {
                this._cartSummary = result;
            })
            .catch((e) => {
                /*console.log(e);*/
            });
    }

    sortRule;
    _displayData;
    _isLoading = false;
    _pageNumber = 1;
    _refinements = [];
    _term;
    _recordId;
    _landingRecordId;
    _cardContentMapping;
    _effectiveAccountId;
    categPath = [{"id":"0ZG8Z000000GsRzWAK","name":"Products"}];
    
    get path() {
        return {
            journey: this.categPath.map(
            (category) => ({
                id: category.id,
                name: category.name
            })
        )
    };
    }

    handleInputChange(event){
        event.stopPropagation();
        this.term = event.target.value;
        this._pageNumber = 1;
        this.triggerProductSearch();
    }

    handleChangeSortRule(event) {
        event.stopPropagation();
        this.defaultRule = event.detail.value;
        this.triggerProductSearch();
    }

    _cartSummary;
    getCartStatus() {
      /*  getActiveCartStatus({}).then(data => {
            if (data) {
                let cartId = data.cartId;
                let cartType = data.cartType;
                this.cartId = cartId;
                console.log('** getCart data  ' + JSON.stringify(data));
             //   this.createQuotes(cartId,cartType);
            }
        })
            .catch(errorResult => {
                console.log('** getCart error ' + JSON.stringify(errorResult));
            });*/

    }
  /*  createQuotes(cartId,cartType){
        this.addToCartMessageState = 'We are processing your cart so hang tight. We appreciate your patience.';
        createQuotes({cartId:cartId,cartType:cartType})
            .then(result => {
               
                if(result != null){
                    if(result.isSuccess){
                        console.log(JSON.stringify(result));
                        this.jobInterval = setInterval(() => {  
                            this.checkQuoteJob(result.jobId);
                        }, 2000);
                    }
                }
            })
            .catch(errorResult => {
                console.log('Error '+JSON.stringify(errorResult));
            });
    }*/
    checkQuoteJob(jobId){
        this.showSpinner = true;
        checkQueueStatus({jobId:jobId})
            .then(result => {
                if(result != null){
                   
                    if(result==='Completed'){
                        this.showSpinner = false;
                       
                        for (let  i = 1; i < this.jobInterval; i++){
                            clearInterval(this.jobInterval);
                        }
                    }else if(result==='Aborted'||result==='Failed'){
                        this.showSpinner = false;
                        for (let  i = 1; i < this.jobInterval; i++){
                            clearInterval(this.jobInterval);
                        }
                    }
                }
            })
            .catch(errorResult => {
                console.log('Check Quote Job Error '+JSON.stringify(errorResult));
            });
    }
  
    get image() {
        return this.displayData.image || {};
    }

    get fields() {
        return (this.displayData.fields || []).map(({ name, value }, id) => ({
            id: id + 1,
            tabIndex: id === 0 ? 0 : -1,
            class: id
                ? 'slds-truncate slds-text-heading_small'
                : 'slds-truncate slds-text-heading_medium',
            value:
                name === 'Name' || name === 'Description'
                    ? value
                    : `${name}: ${value}`
        }));
    }

    get showImage() {
        return !!(this.config || {}).showImage;
    }

    get actionDisabled() {
        return !!(this.config || {}).actionDisabled;
    }

    get price() {
        const prices = this.displayData.price;
        return prices;
    }

    get hasPrice() {
        return !!this.price;
    }

    get listingPrice() {
        return this.displayData.prices.price;
    }

    get priceBookEntryId() {
        return this.displayData.prices.priceBookEntryId;
    }

    get currency() {
        return this.displayData.prices.currencyIsoCode;
    }

     get recurringProduct() {
         
        let isReruccing = false;
        for (let i = 0; i < this.displayData.fields.length; i++) {
          
           if(this.displayData.fields[i].name==='RecurringProduct__c' && this.displayData.fields[i].value==='true'){
               isReruccing = true;
           }
         }
        
       return isReruccing;
   }
    get cardContainerClass() {
        return 'card-layout-list';
    }

    notifyAction() {
        this.dispatchEvent(
            new CustomEvent('calltoaction', {
                bubbles: true,
                composed: true,
                detail: {
                    productId: this.displayData.id,
                    productName: this.displayData.name,
                    pricebookEntryId: this.priceBookEntryId,
                    price: this.price,
                    Description:this.displayData.Description,
                    currencyCode : this.currency
                }
            })
        );
    }

    notifyShowDetail(evt) {
        evt.preventDefault();

        this.dispatchEvent(
            new CustomEvent('showdetail', {
                bubbles: true,
                composed: true,
                detail: { productId: this.displayData.id
                
                }
            })
        );
    }
}