import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';

import { loadStyle } from 'lightning/platformResourceLoader';
import Colors from '@salesforce/resourceUrl/B2B_Colors';
import Fonts from '@salesforce/resourceUrl/B2B_Fonts';
import BoldFonts from '@salesforce/resourceUrl/B2B_Fonts_Bold';

import getOrderItems from '@salesforce/apex/B2BCartControllerSample.getOrderItemsByOrderSummaryId';
import getCartSummary from '@salesforce/apex/B2BCartControllerSample.getOrderSummary';

import { registerListener, unregisterAllListeners } from 'c/pubsub';

const CART_ITEMS_UPDATED_EVT = 'cartitemsupdated';

export default class B2b_orderConfirmationTotals extends NavigationMixin(LightningElement) {
    @api
    recordId;

    @api
    effectiveAccountId;

    @wire(CurrentPageReference)
    pageRef;

    pageParam = null;

    sortParam = 'CreatedDateDesc';

    @track firstCost = 0.0;
    @track monthlyCost = 0.0;

    connectedCallback() {
        loadStyle(this, Fonts);
        loadStyle(this, BoldFonts);
        loadStyle(this, Colors);
        
        this.getUpdatedCartSummary();
        this.getSummaryOrderItems();
        registerListener(
            CART_ITEMS_UPDATED_EVT,
            this.getUpdatedCartSummary,
            this
        );
        
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
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

    get prices() {
     /*   if(this.firstCost != 0.0){
            this.firstCost = this.firstCost + (0.1 * this.cartSummary.TotalAdjustedProductAmount);
        };*/
        return {
            originalPrice: this.cartSummary && this.cartSummary.TotalAdjustedProductAmount ,
            finalPrice: this.cartSummary && this.cartSummary.TotalAdjustedProductAmount ,
            taxes: this.cartSummary && (0.1 * this.cartSummary.TotalAdjustedProductAmount),
            firstBill: this.cartSummary && this.firstCost,
            monthlyBill: this.cartSummary && this.monthlyCost,
            dueToday: this.cartSummary && (this.cartSummary.TotalAdjustedProductAmount * 1.1)
        };
    }

    get currencyCode() {
        return (this.cartSummary && this.cartSummary.currencyIsoCode) || 'USD';
    }

    cartSummary;
    cartItems;
    _cartItemCount = 0;
    

    
    getUpdatedCartSummary(){
        getCartSummary({
            orderSummaryId: this.recordId
        })
            .then((cartSummary) => {
                this.cartSummary = cartSummary;
                console.log('*** cartSummary ' + JSON.stringify(cartSummary));
            })
            .catch((e) => {
                console.log(e);
            });
    }

    getSummaryOrderItems() {
        return getOrderItems({
            orderSummaryId: this.recordId
        })
            .then((cartItems) => {
                this.cartItems = cartItems;
                console.log('*** cartItems ' + JSON.stringify(cartItems));
                this.cartItems.forEach(item => {
                      console.log('*** item.B2B_PriceBookEntry_Id__c ' + JSON.stringify(item));
                      if(item.ProductSellingModel.Name == 'Term Monthly'){
                        item.model = 'Annual Subscription (paid monthly)';
                    } else if(item.ProductSellingModel.Name == 'Term Annual'){
                        item.model = 'Annual Subscription (paid upfront)';
                    } else {
                        item.model = item.ProductSellingModel.Name;
                    }
                    
                    if(item.model == 'One-Time'){
                        item.IsOneTime = true;
                    }
                         // console.log('*** name ' + JSON.stringify(item.ProductSellingModel.Name));
                         // console.log('*** type ' + JSON.stringify(item.ProductSellingModel.SellingModelType));
                          
                          if(item.ProductSellingModel.Name == 'Evergreen Monthly' || item.ProductSellingModel.Name == 'Term Annual'){
                            this.monthlyCost = this.monthlyCost + item.TotalPrice;
                           // console.log('*** monthly item.UnitPrice ' + JSON.stringify(item.UnitPrice));
                           // console.log('*** monthlyCost ' + JSON.stringify(this.monthlyCost));
                          }  
                            if(item.ProductSellingModel.SellingModelType){
                                this.firstCost = this.firstCost + item.TotalPrice  + 0.1 * item.TotalPrice ; 
                            }
                            //console.log('*** first  item.UnitPrice ' + JSON.stringify(item.UnitPrice));
                            //console.log('*** firstCost ' + JSON.stringify(this.firstCost));
                        //  
                });
            })
            .catch((e) => {
                console.log(e);
            });
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