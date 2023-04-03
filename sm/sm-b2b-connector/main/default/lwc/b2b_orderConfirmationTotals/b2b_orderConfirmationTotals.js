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
            dueToday: this.cartSummary && (this.cartSummary.GrandTotalAmount + this.cartSummary.ShippingCost),
            promo: this.cartSummary && this.total_discount,
            monthlyTax: this.cartSummary && this.total_tax
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
    annual_price = 0;
    monthly_price = 0;
    total_tax = 0;
    total_discount = 0;
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
                        //this.annual_price = item.RoundedLineAmount/12;
                        //item.TotalPrice = item.TotalPrice/12;
                    } else if(item.ProductSellingModel.SellingModelType == 'Evergreen'){
                        item.model = 'Annual Subscription (paid upfront)';
                        //item.TotalPrice = item.TotalPrice/12;
                    } else {
                        item.model = item.ProductSellingModel.Name;
                    }
                    
                    if(item.model == 'One-Time'){
                        item.IsOneTime = true;
                        this.firstCost = this.firstCost + item.RoundedLineAmount;//  + item.TotalTaxAmount; 
                        this.total_tax = this.total_tax + item.TotalTaxAmount; 
                        this.total_discount =  this.total_discount + item.TotalAdjustmentAmount;
                    }
                          
                    /*if(item.ProductSellingModel.SellingModelType == 'Evergreen' || item.ProductSellingModel.SellingModelType == 'TermDefined'){
                        //this.monthlyCost = this.monthlyCost + item.TotalPrice;
                        //this.monthlyCost = this.monthlyCost + item.ListPrice;
                        //this.monthlyCost = this.monthlyCost + item.RoundedLineAmount;
                        this.monthlyCost = this.monthlyCost + item.TotalPrice;
                    }*/
                    if(item.ProductSellingModel.SellingModelType == 'Evergreen'){
                        this.monthlyCost = this.monthlyCost + item.RoundedLineAmount;
                        this.firstCost = this.firstCost + item.RoundedLineAmount;//  + item.TotalTaxAmount; 
                        this.total_tax = this.total_tax + item.TotalTaxAmount; 
                        this.total_discount =  this.total_discount + item.TotalAdjustmentAmount;
                    }
                    if(item.ProductSellingModel.SellingModelType == 'TermDefined'){
                        this.monthlyCost = this.monthlyCost + item.RoundedLineAmount;
                        this.firstCost = this.firstCost + item.RoundedLineAmount;//  + item.TotalTaxAmount; 
                        //this.total_tax = this.total_tax + item.TotalTaxAmount; 
                        this.total_tax = this.total_tax + item.TotalTaxAmount/12;  //@surya- to show monthly value
                        //this.total_discount =  this.total_discount + Math.round(item.TotalAdjustmentAmount/12);parseFloat("123.456").toFixed(2);
                        var numb = item.TotalAdjustmentAmount/12;
                        numb = numb.toFixed(2);
                        this.total_discount =  parseFloat(this.total_discount) + parseFloat(numb);
                    }
                    /*if(item.ProductSellingModel.SellingModelType){
                        console.log('hiii');
                        //this.firstCost = this.firstCost + item.TotalPrice  + item.TotalTaxAmount; 
                        //this.firstCost = this.firstCost + item.ListPrice  + item.TotalTaxAmount; 
                        //this.firstCost = this.firstCost + item.RoundedLineAmount  + item.TotalTaxAmount; 
                        this.firstCost = this.firstCost + item.TotalPrice  + item.TotalTaxAmount; 
                    }*/ 
                });

                this.firstCost = this.firstCost + this.total_discount + this.total_tax;
                this.monthlyCost = this.monthlyCost;
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