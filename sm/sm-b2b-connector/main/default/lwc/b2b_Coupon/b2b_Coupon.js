import { LightningElement, api } from 'lwc';
import communityId from '@salesforce/community/Id';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCartItems from '@salesforce/apex/SM_CouponService.getCartItems';
import getAppliedCoupon from '@salesforce/apex/SM_CouponService.getAppliedCoupon';
import deleteCartCoupon from '@salesforce/apex/SM_CouponService.deleteCartCoupon';
import isQuoteDiscountApplied from '@salesforce/apex/SM_CouponService.isQuoteDiscountApplied';
import isisQuoteCreated from '@salesforce/apex/SM_CouponService.isQuoteCreated';

export default class B2b_Coupon extends NavigationMixin(LightningElement) {
    @api recordId;
    CouponApplied;
    disablebutton;
    coupons;
    isQuoteDiscountApplied = false;

    @api effectiveAccountId;
    
    // cartCouponId;
    // initialLoadCompleted=true;
    // isCouponApplied=false;
    // isLoading;

    connectedCallback() {
        this.isQuoteCreated();
        this.refreshQuoteData();
        getAppliedCoupon({communityId: communityId, cartId: this.recordId, effectiveAccountId: this.effectiveAccountId})
        .then(result => {
            this.coupons = result;
            this.CouponApplied = true;
            this.disablebutton = true;
        })
        .catch(error => {
            this.disablebutton = true;
            console.log('no coupon found error ' + JSON.stringify(error));
            console.log('coupon not found value ' + this.CouponApplied);
        });
    }

    isQuoteCreated(){ 
        isisQuoteCreated({cartId: this.recordId})
        .then(result => {
            this.isQuoteDiscountApplied = this.isQuoteDiscountApplied || result;
            console.log('isisQuoteCreated: ' + result);
        })
        .catch(error => {
            console.error('isisQuoteCreated:: error :', JSON.stringify(error));
        });
    }

    refreshQuoteData() {
        isQuoteDiscountApplied({cartId: this.recordId})
        .then(result => {
            this.isQuoteDiscountApplied = this.isQuoteDiscountApplied || result;
            console.log('DEB:: isQuoteDiscountApplied: ' + result);
        })
        .catch(error => {
            console.error('DEB:: error :', JSON.stringify(error));
        });
    }

    handleCoupnApply() {
        isQuoteDiscountApplied({cartId: this.recordId})
            .then(result => {
                this.isQuoteDiscountApplied = result;
                if(!this.isQuoteDiscountApplied) {
                    let couponCode = this.template.querySelector('lightning-input').value;
                    if(couponCode && couponCode.trim() != ''){
                         getCartItems({communityId: communityId, Coupon: couponCode.trim(), cartId: this.recordId, effectiveAccountId: this.effectiveAccountId})
                        .then(result => {
                            this.recordId = result;
                            this.coupon = couponCode;
                            this.CouponApplied = true;
                            this.disablebutton = true;
                            this.showSuccessMessage();
                            this.navigateToCart(this.recordId);
                        })
                        .catch(error => {
                            this.error = error;
                            this.showErrorMessage(error);
                            this.template.querySelector('lightning-input').value = '';
                            this.disablebutton = true;
                            console.log('error from coupon code-- > ' + JSON.stringify(this.error));
                        });
                    } else{
                        this.dispatchEvent(new ShowToastEvent({
                            message: 'INVALID COUPON.',
                            variant: 'error'
                        }));
                    }
                    
                } else {
                this.disablebutton = true;
            }
        })
        .catch(error => {
            // this.disablebutton = true;
            // this.error = error;
           // this.CouponApplied=true;
            console.error('DEB:: error :', JSON.stringify(error));
            this.disablebutton = true;
            // console.log('coupon not found value ' + this.CouponApplied);
        });
    }

    navigateToCart(cartId) {
        console.log('inside--->');
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: cartId,
                objectApiName: 'WebCart',
                actionName: 'view'
            }
        });
    }

    handleDeleteCoupon(event) {
        deleteCartCoupon({communityId: communityId, cartId: this.recordId, couponCode: event.target.dataset.code, effectiveAccountId: this.effectiveAccountId})
            .then(result => {
               var cartId = result;
               this.CouponApplied = false;
               this.CouponApplied = false;
               this.disablebutton = true;
               this.showRemovedMessage();
               this.navigateToCart(cartId);
            })
            .catch(error => {
                this.error = error;
            });
    }

    showErrorMessage(error) {
        let errMsg = error.body.message;
        if(errMsg == 'PROMOTIONALREADYAPPLIED'){
            errMsg = 'PROMOTION ALREADY APPLIED.';
        }
        else if(errMsg == 'UNQUALIFIEDCART'){
            errMsg = 'UNQUALIFIED CART';
        }
        if(errMsg == 'INVALIDCOUPON'){
            errMsg = 'INVALID COUPON';
        }
        this.dispatchEvent(new ShowToastEvent({
            message: (typeof error === 'string') ? error : errMsg,
            variant: 'error'
        }));
    }

    showSuccessMessage() {
        const event = new ShowToastEvent({
           
            message: 'Coupon Applied Successfully',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    showRemovedMessage() {
        const event = new ShowToastEvent({
            message: 'Coupon Removed Successfully',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    handleChange(event) {
        let inputvalue = event.target.value;
        // console.log('input coupon ' + inputvalue);
        this.disablebutton = !inputvalue;
    }
}