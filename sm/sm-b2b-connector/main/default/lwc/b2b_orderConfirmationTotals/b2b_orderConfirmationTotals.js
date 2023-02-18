import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';

import { loadStyle } from 'lightning/platformResourceLoader';
import Colors from '@salesforce/resourceUrl/B2B_Colors';
import Fonts from '@salesforce/resourceUrl/B2B_Fonts';
import BoldFonts from '@salesforce/resourceUrl/B2B_Fonts_Bold';

import getOrderItems from '@salesforce/apex/RSM_CartController.getOrderItemsByOrderSummaryId';
import getCartSummary from '@salesforce/apex/RSM_CartController.getOrderSummary';

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
        return {
            originalPrice: this.cartSummary && this.cartSummary.TotalAdjustedProductAmount,
            finalPrice: this.cartSummary && this.cartSummary.TotalAdjustedProductAmount,
            taxes: this.cartSummary && (this.cartSummary.TotalTaxAmount),
            firstBill: this.cartSummary && this.firstCost,
            monthlyBill: this.cartSummary && this.monthlyCost,
            //dueToday: this.cartSummary && (this.cartSummary.GrandTotalAmount + this.cartSummary.TotalTaxAmount)
            dueToday: this.cartSummary && (this.cartSummary.GrandTotalAmount + this.cartSummary.ShippingCost)
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
                this.cartItems.forEach(item => {
                    /*
                    if(item.ProductSellingModel.Name == 'Term Monthly'){
                        item.model = 'Annual Subscription (paid monthly)';
                    } else if(item.ProductSellingModel.Name == 'Evergreen Monthly'){
                        item.model = 'Annual Subscription (paid upfront)';
                    } else {
                        item.model = item.ProductSellingModel.Name;
                    }
                    */
                    if(item.ProductSellingModel.SellingModelType == 'TermDefined'){
                        item.model = 'Annual Subscription (paid monthly)';
                        item.RoundedLineAmount = item.RoundedLineAmount/12;
                    } else if(item.ProductSellingModel.SellingModelType == 'Evergreen'){
                        item.model = 'Annual Subscription (paid upfront)';
                    } else {
                        item.model = item.ProductSellingModel.Name;
                    }
                    
                    if(item.model == 'One-Time'){
                        item.IsOneTime = true;
                    }
                          
                    if(item.ProductSellingModel.SellingModelType == 'Evergreen' || item.ProductSellingModel.SellingModelType == 'TermDefined'){
                        //this.monthlyCost = this.monthlyCost + item.TotalPrice;
                        //this.monthlyCost = this.monthlyCost + item.ListPrice;
                        this.monthlyCost = this.monthlyCost + item.RoundedLineAmount;
                    }
                    if(item.ProductSellingModel.SellingModelType){
                        //this.firstCost = this.firstCost + item.TotalPrice  + item.TotalTaxAmount; 
                        //this.firstCost = this.firstCost + item.ListPrice  + item.TotalTaxAmount; 
                        this.firstCost = this.firstCost + item.RoundedLineAmount  + item.TotalTaxAmount; 
                    } 
                });

                if(this.firstCost && this.cartSummary.TotalTaxAmount) {
                   // this.firstCost += this.cartSummary.TotalTaxAmount;
                }
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