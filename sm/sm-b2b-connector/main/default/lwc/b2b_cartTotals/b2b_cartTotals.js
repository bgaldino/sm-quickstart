import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';

import { loadStyle } from 'lightning/platformResourceLoader';
import Colors from '@salesforce/resourceUrl/B2B_Colors';
import Fonts from '@salesforce/resourceUrl/B2B_Fonts';
import BoldFonts from '@salesforce/resourceUrl/B2B_Fonts_Bold';

import communityId from '@salesforce/community/Id';
import getCartSummary from '@salesforce/apex/RSM_CartController.getCartSummary';
import getCartItems from '@salesforce/apex/RSM_CartController.getCartItems';
import getCartItemsFields from '@salesforce/apex/RSM_CartController.getCartItemsFields';
import productWithPricingModel from '@salesforce/apex/B2BGetInfo.productWithPricingModel';
import getCartItemsByCartId from '@salesforce/apex/B2BGetInfo.getCartItemsByCartId';
import getTaxes from '@salesforce/apex/RSM_CartController.getOrderTaxAmount';

import { registerListener, unregisterAllListeners } from 'c/pubsub';
import { getLabelForOriginalPrice, displayOriginalPrice } from 'c/cartUtils';

const CART_ITEMS_UPDATED_EVT = 'cartitemsupdated';

const LOCKED_CART_STATUSES = new Set(['Processing', 'Checkout', 'Active']);

import {
    publish,
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';

import cartChanged from "@salesforce/messageChannel/lightning__commerce_cartChanged";


export default class B2b_cartTotals extends NavigationMixin(LightningElement) {
    @api
    recordId;

    @api
    effectiveAccountId;

    orderTaxAmount = 0.0;
    isOrderTax = false;
    spinnerValue = false;

    @wire(CurrentPageReference)
    pageRef;

    pageParam = null;

    sortParam = 'CreatedDateDesc';

     subscription = null;
    @wire(MessageContext)
    messageContext;

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                cartChanged,
                (message) => this.refreshData(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

     refreshData(message){
        console.log(message);
        if(message && message.stopFlow){
            return;
        }
        this.getUpdatedCartSummary();
        this.getCartItem();
        this.getOrderTaxes();
    }

    connectedCallback() {
        this.spinnerValue = true;
        console.log('inside---');
        loadStyle(this, Fonts);
        loadStyle(this, BoldFonts);
        loadStyle(this, Colors);
        this.subscribeToMessageChannel();
        this.getUpdatedCartSummary();
        this.getCartItem();
       this.getOrderTaxes();
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
    @track firstCost; 
    @track monthlyCost = 0.0;
    @track subTotalCost = 0.0;
    totalDiscount = 0.0;
    totalDueToday = 0.0;
    totalTax = 0.0;
    isLoading = false;

    get prices() {
        this.spinnerValue = true;
        return {
            originalPrice: this.cartSummary && this.cartSummary.totalListPrice,
            finalPrice: this.cartSummary && this.subTotalCost,
            firstBill: this.cartSummary && this.firstCost,
            monthlyBill: this.cartSummary && this.monthlyCost,
            discount: this.cartSummary && this.totalDiscount,   //this.cartSummary.totalPromotionalAdjustmentAmount,
            dueToday: this.cartSummary && this.firstCost + parseFloat(this.totalDiscount) + parseFloat(this.orderTaxAmount),    //(parseInt(this.cartSummary.totalProductAmountAfterAdjustments) + this.orderTaxAmount + parseFloat(this.cartSummary.totalChargeAmount))
            spinner: this.cartSummary.totalProductCount == "0" || this.firstCost > 0 || this.cartSummary.grandTotalAmount == "0.00" ? false : true
        };
    }

    get currencyCode() {
        return (this.cartSummary && this.cartSummary.currencyIsoCode) || 'USD';
    }

    cartSummary;
    cartItems = [];
    _cartItemCount = 0;

    getUpdatedCartSummary() {
        this.isLoading = true;
        return getCartSummary({
            communityId: communityId,
            activeCartOrId: this.recordId,
            effectiveAccountId: this.resolvedEffectiveAccountId
        })
            .then((cartSummary) => {
                this.cartSummary = cartSummary;
                this._cartItemCount = Number(
                    cartSummary.totalProductCount
                );
                this.isCartDisabled = LOCKED_CART_STATUSES.has(
                    cartSummary.status
                );
                this.isLoading = false;
            })
            .catch((e) => {
                this.isLoading = false;
                console.log(e);
            });
    }

    getOrderTaxes() {
        return getTaxes({
            cartId: this.recordId
        })
            .then((result) => {
                //if(result>=0){
                if(result != null){
                    this.isOrderTax = true;
                    this.orderTaxAmount = this.totalTax;
                }else{
                    this.isOrderTax = false;
                }
            })
            .catch((e) => {
                console.log(e);
            });
    }

    getCartItem() {
        this.isLoading = true;
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
                  this.firstCost = 0.0;
                  this.monthlyCost = 0.0;
                  this.subTotalCost = 0.0;
                  this.totalDiscount = 0.0;
                  this.totalDueToday = 0.0;
                  this.totalTax = 0.0;
                  this.cartItems.forEach(item => {
                    productWithPricingModel( {
                          productSellingModelName: item.productSellingModel
                      })
                      .then((res) => {
                        if(res.Name == 'Term Monthly'){
                            item.model = 'Annual Subscription (paid monthly)';
                            item.TotalPrice = item.TotalListPrice * 12;
                        } else if(res.Name == 'Evergreen Monthly'){
                            item.model = 'Annual Subscription (paid upfront)';
                            
                        } else {
                            item.model = res.Name;
                        }
                        if(item.model == 'One-Time'){
                            item.IsOneTime = true;
                        }
                          if(res.Name == 'Evergreen Monthly' || res.Name == 'Term Monthly'){
                            this.monthlyCost = this.monthlyCost + item.TotalListPrice;
                          } 
                          if(res.SellingModelType){
                            this.firstCost = this.firstCost + item.TotalListPrice;
                            //this.totalDueToday = this.totalDueToday + item.totalLineAmount;
                            if(item.totalAdjustmentAmount != undefined){
                                if(res.SellingModelType == 'TermDefined'){
                                    this.totalDiscount = parseFloat(this.totalDiscount) + parseFloat(item.totalAdjustmentAmount/12);
                                    this.totalTax = this.totalTax + item.TotalTaxAmount/12;
                                }else{
                                    this.totalDiscount = parseFloat(this.totalDiscount) + parseFloat(item.totalAdjustmentAmount);
                                    this.totalTax = this.totalTax + item.TotalTaxAmount;
                                }
                            }else{

                                if(res.SellingModelType == 'TermDefined'){
                                    this.totalDiscount = parseFloat(this.totalDiscount);
                                    this.totalTax = this.totalTax + item.TotalTaxAmount/12;
                                }else{
                                    this.totalDiscount = parseFloat(this.totalDiscount);
                                    this.totalTax = this.totalTax + item.TotalTaxAmount;
                                }/*
                                if(item.totalAdjustmentAmount != undefined){
                                    this.totalDiscount = parseFloat(this.totalDiscount) + parseFloat(item.totalAdjustmentAmount);
                                }else{
                                    this.totalDiscount = parseFloat(this.totalDiscount);
                                }
                                
                                this.totalTax = this.totalTax + item.TotalTaxAmount;*/
                            }
                          }
                       this.subTotalCost = this.subTotalCost + item.TotalPrice;

                        })
                      .catch((e) => {
                          this.isLoading = false;
                          console.log(e);
                      });

                      getCartItemsByCartId({  cartId: this.recordId}).then(res =>  {
                        let cartItemId = item.Id;
                        if(res[cartItemId]){ 
                            if(res[cartItemId]['dicount'] > 0){
                                item.discount = res[cartItemId]['dicount'] + res[cartItemId]['TotalPrice'];
                                item.discountPercent = (res[cartItemId]['dicount']*100)/item.discount + '%';
                            }
                        }
                      }).catch(error => {
                          this.isLoading = false;
                            console.log(error)
                      })
                  });
                  this.isLoading = false;
            }
                this.getOrderTaxes();
            })
            .catch((error) => {
                this.isLoading = false;
                console.log(error);
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