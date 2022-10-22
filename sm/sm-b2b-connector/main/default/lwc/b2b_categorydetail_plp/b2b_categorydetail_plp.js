/* eslint-disable @lwc/lwc/no-async-operation */
import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import communityId from '@salesforce/community/Id';
import productSearch from '@salesforce/apex/B2B_SearchController.productSearch';
import getCartSummary from '@salesforce/apex/B2BGetInfo.getCartSummary';
//import addToCart from '@salesforce/apex/B2BGetInfo.addToCart';
//import addToCartWithSubscription from '@salesforce/apex/B2B_SubscriptionController.addToCart';
//import getActiveCartStatus from '@salesforce/apex/B2B_ProceedToCheckOutCntrl.getActiveCartStatus';
//import createQuotes from '@salesforce/apex/B2B_ProceedToCheckOutCntrl.createQuotes';
//import checkQueueStatus from '@salesforce/apex/B2B_CartController.checkQueueStatus';
import { transformData } from './dataNormalizer';

/**
 * A search resutls component that shows results of a product search or
 * category browsing.This component handles data retrieval and management, as
 * well as projection for internal display components.
 * When deployed, it is available in the Builder under Custom Components as
 * 'B2B Custom Search Results'
 */
export default class SearchResults extends NavigationMixin(LightningElement) {
    /**
     * Gets the effective account - if any - of the user viewing the product.
     *
     * @type {string}
     */
    @api
    get effectiveAccountId() {
        return this._effectiveAccountId;
    }
    @track sortBy;
    @track sortDirection;

    @api resultssort;
    /**
     * Sets the effective account - if any - of the user viewing the product
     * and fetches updated cart information
     */
    set effectiveAccountId(newId) {
        this._effectiveAccountId = newId;
        this.updateCartInformation();
    }

    /**
     *  Gets or sets the unique identifier of a category.
     *
     * @type {string}
     */
    @api
    get recordId() {
        // console.log('get recordId---- '+this._recordId);
        return this._recordId;
    }
    set recordId(value) {
        // console.log('set recordId value---- '+value);
        this._recordId = value;
        this._landingRecordId = value;
        this.triggerProductSearch();
    }

    /**
     *  Gets or sets the search term.
     *
     * @type {string}
     */
    @api
    get term() {
        // console.log('get term-- '+this._term);
        return this._term;
    }
    set term(value) {
        this._term = value;
        if (value) {
            this.triggerProductSearch();
        }
    }

    showSpinner = false;
    /**
     *  Gets or sets fields to show on a card.
     *
     * @type {string}
     */
    @api
    get cardContentMapping() {
        return this._cardContentMapping;
    }
    set cardContentMapping(value) {
        this._cardContentMapping = value;
    }

    /**
     *  Gets or sets the layout of this component. Possible values are: grid, list.
     *
     * @type {string}
     */
    @api
    resultsLayout;

    /**
     *  Gets or sets whether the product image to be shown on the cards.
     *
     * @type {string}
     */
    @api
    showProductImage;

    /**
     * Triggering the search query imperatively. We can do declarative way if
     *  '_isLoading` is not required. It would be something like this.
     *
     *  @wire(productSearch, {
     *      communityId: communityId,
     *      searchQuery: '$searchQuery',
     *      effectiveAccountId: '$resolvedEffectiveAccountId'
     *  })
     *  searchHandler(res) {
     *      if (res) {
     *          if (res.error) {
     *              this.error = res.error;
     *          } else if (res.data) {
     *              this.displayData = res.data;
     *          }
     *      }
     *  }
     *
     *  Note that setting the loading status while changing the parameter could
     *  work, but somtimes it gets into a weird cache state where no network
     *  call or callback (to your searchHandler where you can reset the load
     *  state) and you get into infinite UI spinning.
     *
     * @type {ConnectApi.ProductSummaryPage}
     * @private
     */
     
    triggerProductSearch() {
        console.log('inside triggerProductSearch original')
        const searchQuery = JSON.stringify({
            searchTerm: this.term,
            categoryId: this.recordId,
            refinements: this._refinements,
            includeQuantityRule:true,

            // use fields for picking only specific fields
            // using ./dataNormalizer's normalizedCardContentMapping
            //fields:['RecurringProduct__c'], //normalizedCardContentMapping(this._cardContentMapping),
            page: this._pageNumber - 1,
            pageSize:30,
            grouping :{groupingOption:'VariationParent'},
            includePrices: true
        });
        // console.log('searchQuery---- '+searchQuery);
        this._isLoading = true;

        productSearch({
            communityId: communityId,
            searchQuery: searchQuery,
            effectiveAccountId: this.resolvedEffectiveAccountId
        })
            .then((result) => {
                // console.log('search result');
                this.displayData = result;
                this._isLoading = false;
                // console.log(result);
            })
            .catch((error) => {
                this.error = error;
                this._isLoading = false;
                console.log(error);
            });
    }

    /**
     * Gets the normalized component configuration that can be passed down to
     *  the inner components.
     *
     * @type {object}
     * @readonly
     * @private
     */
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

    /**
     * Gets or sets the normalized, displayable results for use by the display components.
     *
     * @private
     */
    get displayData() {
        return this._displayData || {};
    }
    set displayData(data) {
        this._displayData = transformData(data, this._cardContentMapping);
        // console.log('this._displayData---'+this._displayData);
    }

    /**
     * Gets whether product search is executing and waiting for result.
     *
     * @type {Boolean}
     * @readonly
     * @private
     */
    get isLoading() {
        return this._isLoading;
    }

    /**
     * Gets whether results has more than 1 page.
     *
     * @type {Boolean}
     * @readonly
     * @private
     */
    get hasMorePages() {
        return this.displayData.total > this.displayData.pageSize;
    }

    /**
     * Gets the current page number.
     *
     * @type {Number}
     * @readonly
     * @private
     */
    get pageNumber() {
        return this._pageNumber;
    }

    /**
     * Gets the header text which shows the search results details.
     *
     * @type {string}
     * @readonly
     * @private
     */
    get headerText() {
        console.log("hiiii");
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

            text = `${startIndex} - ${endIndex} of ${totalItemCount} Items`;
        } else if (totalItemCount === 1) {
            text = '1 Result';
        }

        return text;
    }

    /**
     * Gets the normalized effective account of the user.
     *
     * @type {string}
     * @readonly
     * @private
     */
    get resolvedEffectiveAccountId() {
        const effectiveAcocuntId = this.effectiveAccountId || '';
        let resolved = null;

        if (
            effectiveAcocuntId.length > 0 &&
            effectiveAcocuntId !== '000000000000000'
        ) {
            resolved = effectiveAcocuntId;
        }
        return resolved;
    }

    /**
     * Gets whether the cart is currently locked
     *
     * Returns true if the cart status is set to either processing or checkout (the two locked states)
     *
     * @readonly
     */
    get isCartLocked() {
        const cartStatus = (this._cartSummary || {}).status;
        return cartStatus === 'Processing' || cartStatus === 'Checkout';
    }

    @track isListView;
    @track isGridView;
    @track gridIconClass = 'slds-p-around_xxx-small gridClass slds-float_right active slds-m-left_small';
    @track listIconClass = 'slds-p-around_xxx-small listClass  slds-float_right slds-m-left_small';

    /**
     * The connectedCallback() lifecycle hook fires when a component is inserted into the DOM.
     */
    connectedCallback() {
        this.updateCartInformation();
        // this.gridIconClass = this.resultsLayout === 'grid' ? 'slds-p-around_xxx-small slds-float_right gridClass active' :  'slds-p-around_xxx-small slds-float_right gridClass ';
        // this.listIconClass = this.resultsLayout === 'list' ? 'slds-p-around_xxx-small listClass active' :  'slds-p-around_xxx-small listClass ';
    }

    

    handleSwitchLayout(e) {
        this.resultsLayout = e.currentTarget.dataset.value;
        console.log('original handleSwitchLayout--- '+this.resultsLayout);
        this.gridIconClass = this.resultsLayout === 'grid' ? 'slds-p-around_xxx-small gridClass slds-float_right active' :  'slds-p-around_xxx-small slds-float_right gridClass ';
        this.listIconClass = this.resultsLayout === 'list' ? 'slds-p-around_xxx-small listClass  slds-float_right active' :  'slds-p-around_xxx-small  slds-float_right listClass ';
        this.triggerProductSearch();
    }

    
    /**
     * Handles a user request to add the product to their active cart.
     *
     * @private
     */
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

      /*  addToCartWithSubscription({
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
            });*/
    }

    /**
     * Handles a user request to clear all the filters.
     *
     * @private
     */
    handleClearAll(/*evt*/) {
        this._refinements = [];
        this._recordId = this._landingRecordId;
        this._pageNumber = 1;
        this.template.querySelector('c-filter').clearAll();
        this.triggerProductSearch();
    }

    /**
     * Handles a user request to navigate to the product detail page.
     *
     * @private
     */
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

    /**
     * Handles a user request to navigate to previous page results page.
     *
     * @private
     */
    handlePreviousPage(evt) {
        evt.stopPropagation();

        this._pageNumber = this._pageNumber - 1;
        this.triggerProductSearch();
    }

    /**
     * Handles a user request to navigate to next page results page.
     *
     * @private
     */
    handleNextPage(evt) {
        evt.stopPropagation();

        this._pageNumber = this._pageNumber + 1;
        this.triggerProductSearch();
    }

    /**
     * Handles a user request to filter the results from facet section.
     *
     * @private
     */
    handleFacetValueUpdate(evt) {
        evt.stopPropagation();

        this._refinements = evt.detail.refinements;
        this._pageNumber = 1;
        this.triggerProductSearch();
    }

    /**
     * Handles a user request to show a selected category from facet section.
     *
     * @private
     */
    handleCategoryUpdate(evt) {
        evt.stopPropagation();

        this._recordId = evt.detail.categoryId;
        this._pageNumber = 1;
        this.triggerProductSearch();
    }

    /**
     * Ensures cart information is up to date
     */
    updateCartInformation() {
        getCartSummary({
            communityId: communityId,
            effectiveAccountId: this.resolvedEffectiveAccountId
        })
            .then((result) => {
                this._cartSummary = result;
            })
            .catch((e) => {
                // Handle cart summary error properly
                // For this sample, we can just log the error
                /*console.log(e);*/
            });
    }

    _displayData;
    _isLoading = false;
    _pageNumber = 1;
    _refinements = [];
    _term;
    _recordId;
    _landingRecordId;
    _cardContentMapping;
    _effectiveAccountId;
    /**
     * The cart summary information
     * @type {ConnectApi.CartSummary}
     */
    _cartSummary;
    /*getCartStatus() {
        getActiveCartStatus({}).then(data => {
            if (data) {
                let cartId = data.cartId;
                let cartType = data.cartType;
                this.cartId = cartId;
                console.log('** getCart data  ' + JSON.stringify(data));
                this.createQuotes(cartId,cartType);
            }
        })
            .catch(errorResult => {
                console.log('** getCart error ' + JSON.stringify(errorResult));
            });

    }*/
    /*createQuotes(cartId,cartType){
        this.addToCartMessageState = 'We are processing your cart so hang tight. We appreciate your patience.';
        createQuotes({cartId:cartId,cartType:cartType})
            .then(result => {
               
                if(result != null){
                    /*console.log(JSON.stringify(result));*/

                    /*console.log(result.jobId);
                    
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
    /*checkQuoteJob(jobId){
        this.showSpinner = true;
        //let comReference = this;
        /*console.log('checkQueueStatus ' + jobId);
        checkQueueStatus({jobId:jobId})
            .then(result => {
                /*console.log('checkQueueStatus ' + JSON.stringify(result));
                if(result != null){
                   
                    if(result==='Completed'){
                        this.showSpinner = false;
                       
                        for (let  i = 1; i < this.jobInterval; i++){
                            clearInterval(this.jobInterval);
                        }
                            
                        // sync quote to cart
                       // this.synchQuoteToCart(this.cartId);
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
    }*/
}