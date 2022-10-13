import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';

import { loadStyle } from 'lightning/platformResourceLoader';
import Colors from '@salesforce/resourceUrl/B2B_Colors';
import Fonts from '@salesforce/resourceUrl/B2B_Fonts';
import BoldFonts from '@salesforce/resourceUrl/B2B_Fonts_Bold';

import communityId from '@salesforce/community/Id';
import getCartSummary from '@salesforce/apex/B2BCartControllerSample.getCartSummary';
import getCartItems from '@salesforce/apex/B2BCartControllerSample.getCartItems';
import getCartItemsFields from '@salesforce/apex/B2BCartControllerSample.getCartItemsFields';
import productWithPricingModel from '@salesforce/apex/B2BGetInfo.productWithPricingModel';
import getCartItemsByCartId from '@salesforce/apex/B2BGetInfo.getCartItemsByCartId';
import getTaxes from '@salesforce/apex/B2B_CartTaxesCalculation.calculateTaxAmount';
import createTaxCartItem from '@salesforce/apex/B2B_CartTaxesCalculation.createTaxCartItem';

import { registerListener, unregisterAllListeners } from 'c/pubsub';
import { getLabelForOriginalPrice, displayOriginalPrice } from 'c/cartUtils';

const CART_ITEMS_UPDATED_EVT = 'cartitemsupdated';

const LOCKED_CART_STATUSES = new Set(['Processing', 'Checkout', 'Active']);


export default class B2b_cartTotals extends NavigationMixin(LightningElement) {
    @api
    recordId;

    @api
    effectiveAccountId;

    @wire(CurrentPageReference)
    pageRef;

    pageParam = null;

    sortParam = 'CreatedDateDesc';

    connectedCallback() {
        loadStyle(this, Fonts);
        loadStyle(this, BoldFonts);
        loadStyle(this, Colors);
        
        this.getUpdatedCartSummary();
        this.getCartItem();
       // this.getPricingModel(); 
       registerListener(
            CART_ITEMS_UPDATED_EVT,
            this.getUpdatedCartSummary,
            this
        );
        registerListener(
            CART_ITEMS_UPDATED_EVT,
            this.getCartItem,
            this
        );
    }
    renderedCallback(){
       
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
  
    }

    get labels() {
        return {
            cartSummaryHeader: 'Your order details',
            total: 'Total'
        };
    }

    get resolvedEffectiveAccountId() {
        const effectiveAccountId = this.effectiveAccountId || '';
        let resolved = null;
        if (
            effectiveAccountId.length > 0 &&
            effectiveAccountId !== '000000000000000'
        ) {
            resolved = effectiveAccountId;
        }
        return resolved;
    }
    @track firstCost = 0.0; 
    @track monthlyCost = 0.0;
    @track currentCartTaxes = 0.0;
    @track subTotalCost = 0.0;

    get prices() {
        return {
            originalPrice: this.cartSummary && this.cartSummary.totalListPrice ,
            finalPrice: this.cartSummary && this.subTotalCost,
            taxes: this.cartSummary && this.currentCartTaxes,
            firstBill: this.cartSummary && this.firstCost,
            monthlyBill: this.cartSummary && this.monthlyCost,
            dueToday: this.cartSummary && (parseInt(this.cartSummary.totalProductAmount) + this.currentCartTaxes)
        };
    }

    get currencyCode() {
        return (this.cartSummary && this.cartSummary.currencyIsoCode) || 'USD';
    }

    cartSummary;
    cartItems = [];
    _cartItemCount = 0;

    getUpdatedCartSummary() {
        return getCartSummary({
            communityId: communityId,
            activeCartOrId: this.recordId,
            effectiveAccountId: this.resolvedEffectiveAccountId
        })
            .then((cartSummary) => {
                this.cartSummary = cartSummary;
                //console.log('*** cartSummary ' + JSON.stringify(cartSummary));
                this._cartItemCount = Number(
                    cartSummary.totalProductCount
                );
                this.isCartDisabled = LOCKED_CART_STATUSES.has(
                    cartSummary.status
                );
            })
            .catch((e) => {
                console.log(e);
            });
    }

    getCartItem() {
         getCartItemsFields({
            communityId: communityId,
            effectiveAccountId: this.resolvedEffectiveAccountId,
            activeCartOrId: this.recordId,
            pageParam: this.pageParam,
            sortParam: this.sortParam
        })
            .then((result) => {
                this.cartItems = result;
                
                if(this.cartItems){
                  //console.log('*** cartItems to request ' + JSON.stringify(this.cartItems)); 
                  this.getTaxesToItems(this.cartItems);
                  this.firstCost = 0.0;
                  this.monthlyCost = 0.0;
                  this.subTotalCost = 0.0;
                  this.cartItems.forEach(item => {
                    //  console.log('*** item.B2B_PriceBookEntry_Id__c ' + JSON.stringify(item));
                    productWithPricingModel( {
                          pricebookEntryId: item.B2B_PriceBookEntry_Id__c
                      })
                      .then((res) => {
                        if(res.Name == 'Term Monthly'){
                            item.model = 'Annual Subscription (paid monthly)';
                            item.TotalPrice = item.TotalListPrice * 12;
                        } else if(res.Name == 'Term Annual'){
                            item.model = 'Annual Subscription (paid upfront)';
                            
                        } else {
                            item.model = res.Name;
                        }
                        if(item.model == 'One-Time'){
                            item.IsOneTime = true;
                        }
                         // console.log('*** res ' + JSON.stringify(res.Name));
                         // console.log('*** item.model = res; ' + JSON.stringify(item.model));
                        //  this.getPricingModel();
                          if(res.Name == 'Evergreen Monthly' || res.Name == 'Term Monthly'){
                            this.monthlyCost = this.monthlyCost + item.TotalListPrice;
                         //   console.log('*** monthlyCost ' + JSON.stringify(this.monthlyCost));
                          } 
                          if(res.SellingModelType){
                            this.firstCost = this.firstCost + item.TotalListPrice;
                            // console.log('*** firstCost ' + JSON.stringify(this.firstCost));
                          } 
                          
                       //console.log('*** item.totalAmount ' + JSON.stringify(item.TotalPrice));
                       this.subTotalCost = this.subTotalCost + item.TotalPrice;
                       console.log('*** this.subTotalCost ' + JSON.stringify(this.subTotalCost));
                        })
                      .catch((e) => {
                          console.log(e);
                      });

                      getCartItemsByCartId({  cartId: this.recordId}).then(res =>  {
                        //console.log(JSON.stringify(res), 'result--->>>>');
                        let cartItemId = item.Id;
                        if(res[cartItemId]){ 
                            if(res[cartItemId]['Discount__c'] > 0){
                                item.discount = res[cartItemId]['Discount__c'] + res[cartItemId]['TotalPrice'];
                                item.discountPercent = (res[cartItemId]['Discount__c']*100)/item.discount + '%';
                            }
                        }
                      }).catch(error => {
                        console.log(error)
                      })
                  });
            }

            })
            .catch((error) => {
                console.log(error);
            });
    }
    
    getTaxesToItems(items){
        if(!items.length) {
            this.currentCartTaxes = 0;
        } else {
            return getTaxes({
                cartItems: items
            })
                .then((result) => {
                //    console.log('****result request--- ' + JSON.stringify(result));
                   // console.log('**** taxAmount ' + JSON.stringify(result.amountDetails.taxAmount));
                //    console.log(result);
                   this.currentCartTaxes = parseInt(result.amountDetails.taxAmount);
                   createTaxCartItem({cartId: this.recordId, rawResponse: JSON.stringify(result)})
                   .catch(e => console.log(e));
                   //console.log('****this.currentCartTaxes--- ' + JSON.stringify(this.currentCartTaxes));
                })
                .catch((e) => {
                    console.log(e);
                });
        }
        
    }

    handleProductDetailNavigation(evt) {
        evt.preventDefault();
        const productId = evt.target.dataset.productid;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: productId,
                actionName: 'view'
            }
        });
    }

}