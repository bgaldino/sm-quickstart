import { LightningElement,api, wire, track } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import communityId from '@salesforce/community/Id';
import getProduct from '@salesforce/apex/B2BGetInfo.getProduct';
import getCartItemsByCartId from '@salesforce/apex/B2BGetInfo.getCartItemsByCartId';
import getCartItems from '@salesforce/apex/RSM_CartController.getCartItems';
import updateCartItem from '@salesforce/apex/RSM_CartController.updateCartItem';
import deleteCartItem from '@salesforce/apex/RSM_CartController.deleteCartItem';
import deleteCart from '@salesforce/apex/RSM_CartController.deleteCart';
import createCart from '@salesforce/apex/RSM_CartController.createCart';
import updateCartItems from '@salesforce/apex/B2BGetInfo.updateCartItems';
import productWithPricingModel from '@salesforce/apex/B2BGetInfo.productWithPricingModel';
import deleteOrderByCartId from '@salesforce/apex/RSM_CartController.deleteOrderByCartId';
import errorLabel from '@salesforce/label/c.B2B_Negative_Or_Zero_Error';
import getCategoryId from '@salesforce/apex/RSM_CartController.getCategoryId';

import { transformData } from './b2bDataNormalizer';

import { fireEvent } from 'c/pubsub';
import { isCartClosed } from 'c/cartUtils';
import { refreshApex } from '@salesforce/apex';

const CART_CHANGED_EVT = 'cartchanged';
const CART_ITEMS_UPDATED_EVT = 'cartitemsupdated';
const QUANTITY_CHANGED_EVT = 'quantitychanged';

const LOCKED_CART_STATUSES = new Set(['Processing', 'Checkout']);

import {
    publish,
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';

import cartChanged from "@salesforce/messageChannel/lightning__commerce_cartChanged";

export default class B2b_cartItemsContent extends NavigationMixin(LightningElement) {
    @api recordId;

    @api effectiveAccountId;

    @wire(CurrentPageReference)
    pageRef;

    _cartItemCount = 0;

    @track cartItems = [];
    isDiscountApplied = false;

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
        this.updateCartItems();
    }

    sortOptions = [
        { value: 'CreatedDateDesc', label: this.labels.CreatedDateDesc },
        { value: 'CreatedDateAsc', label: this.labels.CreatedDateAsc },
        { value: 'NameAsc', label: this.labels.NameAsc },
        { value: 'NameDesc', label: this.labels.NameDesc }
    ];
    categPath = [{"id":"0ZGDn000000oRTWOA2","name":"Products"}, {"id":"0ZG8Z000000GsRzWAK","name":"Cart"}];

    pageParam = null;

    sortParam = 'CreatedDateDesc';

    isCartClosed = false;

    currencyCode;
    isCartEmpty = false;

    // get isCartEmpty() {
    //     return Array.isArray(this.cartItems) && this.cartItems.length === 0;
    // }

    get labels() {
        return {
            loadingCartItems: 'Loading Cart Items',
            clearCartButton: 'Clear Cart',
            sortBy: 'Sort By',
            cartHeader: 'Shopping Cart',
            emptyCartHeaderLabel: 'Your cart’s empty',
            emptyCartBodyLabel:
                'Search or browse products, and add them to your cart. Your selections appear here.',
            closedCartLabel: "The cart that you requested isn't available.",
            CreatedDateDesc: 'Date Added - Newest First',
            CreatedDateAsc: 'Date Added - Oldest First',
            NameAsc: 'Name - A to Z',
            NameDesc: 'Name - Z to A'
        };
    }

    get cartHeader() {
        return `${this.labels.cartHeader} (${this._cartItemCount})`;
    }

    get isCartItemListIndeterminate() {
        return !Array.isArray(this.cartItems);
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
    runOnce = true;
    get path() {
        if(this.runOnce){
            this.getBreadcrumbs();
        }
        return {
            journey: this.categPath.map(
            (category) => ({
                id: category.id,
                name: category.name
            })
        )
    };
    }

    getBreadcrumbs(){
        console.log('inside getBreadcrumbs');
        
        getCategoryId({
            cartId: this.recordId
        }).then((result) => {
            console.log('result---- ',result);
            this.categPath = [{"id":result,"name":"Products"}, {"id":this.recordId,"name":"Cart"}];
            this.runOnce = false;
        }).catch((error) => {
            console.error('deletion order error: ', error);
        })
    }

    _cardContentMapping;

    @api
    get cardContentMapping() {
        return this._cardContentMapping;
    }
    set cardContentMapping(value) {
        this._cardContentMapping = value;
    }

    connectedCallback() {
        this.spinnerValue = true;
        this.subscribeToMessageChannel();
        deleteOrderByCartId({
            cartId: this.recordId
        }).then((result) => {
            this.updateCartItems();
        }).catch((error) => {
            console.error('deletion order error: ', error);
        })
    }

    updateCartItems() {
        this.spinnerValue = true;
        return getCartItems({
            communityId: communityId,
            effectiveAccountId: this.resolvedEffectiveAccountId,
            activeCartOrId: this.recordId,
            pageParam: this.pageParam,
            sortParam: this.sortParam

        })
            .then((result) => {
                let cartItemsTmp = result.cartItems;
                let isDiscountApplied = false;
                this._cartItemCount = Number(
                    result.cartSummary.totalProductCount
                );
                this.currencyCode = result.cartSummary.currencyIsoCode;
                // this.isCartDisabled = LOCKED_CART_STATUSES.has(
                //     result.cartSummary.status
                // );
                this.isCartDisabled = false;
                if(cartItemsTmp.length != 0){
                     return getCartItemsByCartId({
                        cartId: cartItemsTmp[0].cartItem.cartId
                    })
                    .then((res) => {
                        cartItemsTmp.forEach(item => {
                            let cartItemId = item['cartItem']['cartItemId'];
                            if(res[cartItemId]) item.desc2 = res[cartItemId]['productDescription'];
                            if(res[cartItemId]) item.entry = res[cartItemId]['priceBookEntryId'];

                            item.isCouponApplied = item.cartItem.totalPrice != item.cartItem.totalListPrice;

                            if(res[cartItemId]){ 
                                if(res[cartItemId]['productSellingModel'] == 'Term Monthly'){
                                    item.model = 'Annual Subscription (paid monthly)';
                                    item.cartItem.totalListPrice = item.cartItem.totalListPrice/12;
                                    item.cartItem.totalPrice = item.cartItem.totalPrice/12;
                                } else if(res[cartItemId]['productSellingModel'] == 'Evergreen Monthly'){
                                    item.model = 'Annual Subscription (paid upfront)';
                                } else {
                                    item.model = res[cartItemId]['productSellingModel'];
                                }
                                if(res[cartItemId]['discount'] > 0){
                                    isDiscountApplied = true;
                                    if(res[cartItemId]['productSellingModel'] == 'Term Monthly'){
                                        item.discount = res[cartItemId]['discount']/12 + res[cartItemId]['TotalPrice']/12;
                                        item.discountPercent = (res[cartItemId]['discount']/12 * 100)/item.discount + '%';
                                    }else{
                                        item.discount = res[cartItemId]['discount'] + res[cartItemId]['TotalPrice'];
                                        item.discountPercent = (res[cartItemId]['discount']*100)/item.discount + '%';
                                    }

                                }else if(item.cartItem.itemizedAdjustmentAmount && item.cartItem.itemizedAdjustmentAmount < 0){
                                    // isDiscountApplied = true;
                                    // item.discount = item.cartItem.totalPrice - item.cartItem.itemizedAdjustmentAmount;
                                    // item.discountPercent = ((item.cartItem.itemizedAdjustmentAmount*(-100))/item.cartItem.totalPrice )+'%' ;
                                }
                            }
                        });

                        this.isDiscountApplied = isDiscountApplied;
                        this.cartItems = cartItemsTmp;
                        //this.isCartEmpty = Array.isArray(this.cartItems) && this.cartItems.length === 0;
                        fireEvent(this.pageRef, CART_ITEMS_UPDATED_EVT);
                        refreshApex(this.cartItems);
                        this.spinnerValue = false;
                    })
                }
                this.isCartEmpty = Array.isArray(this.cartItems) && this.cartItems.length === 0;
                this.spinnerValue = false;
            })
            .catch((error) => {
                this.isCartEmpty = Array.isArray(this.cartItems) && this.cartItems.length === 0;
                const errorMessage = error.body.message;
                this.cartItems = undefined;
                this.spinnerValue = false;
                this.isCartClosed = isCartClosed(errorMessage);
            });
    }

    handleChangeSortSelection(event) {
        this.sortParam = event.target.value;
        this.updateCartItems();
    }

    handleCartUpdate() {
        this.dispatchEvent(
            new CustomEvent(CART_CHANGED_EVT, {
                bubbles: true,
                composed: true
            })
        );
        this.spinnerValue = true;
        fireEvent(this.pageRef, CART_ITEMS_UPDATED_EVT);

        refreshApex(this.cartItems);
        this.spinnerValue = false;
    }

    handleQuantityChanged(evt) {
        this.spinnerValue = true;
        const { cartItemId, quantity } = evt.detail;
        updateCartItems({
            communityId: communityId, 
            effectiveAccountId: this.resolvedEffectiveAccountId,
            cartItemId: cartItemId,
            quantity: quantity 
        })
            .then((cartItem) => {
                this.updateCartItemInformation(cartItem);
                this.spinnerValue = false;
            })
            .catch((e) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message:
                            `${errorLabel}`,
                        messageData: [cartItemId],
                        variant: 'error',
                        mode: 'dismissable'
                    })
                );
                this.spinnerValue = false;
                console.log(e);
            });
    }
    spinnerValue = false;
    handleCartItemDelete(evt) {
        const { cartItemId } = evt.detail;
        deleteCartItem({
            communityId,
            effectiveAccountId: this.effectiveAccountId,
            activeCartOrId: this.recordId,
            cartItemId
        })
            .then(() => {
                this.removeCartItem(cartItemId);

                this.navigateToCart(this.recordId);
            })
            .catch((e) => {
                console.log(e);
            });
    }

    handleClearCartButtonClicked() {
        deleteCart({
            communityId,
            effectiveAccountId: this.effectiveAccountId,
            activeCartOrId: this.recordId
        })
            .then(() => {
                this.spinnerValue = false;
                this.cartItems = undefined;
                this._cartItemCount = 0;
            })
            .then(() => {
                return createCart({
                    communityId,
                    effectiveAccountId: this.effectiveAccountId
                });
            })
            .then((result) => {
                this.navigateToCart(result.cartId);
                this.handleCartUpdate();
                this.spinnerValue = false;
            })
            .catch((e) => {
                this.spinnerValue = false;
                console.log(e);
            });
    }

    navigateToCart(cartId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: cartId,
                objectApiName: 'WebCart',
                actionName: 'view'
            }
        });
    }

    removeCartItem(cartItemId) {
        const removedItem = (this.cartItems || []).filter(
            (item) => item.cartItem.cartItemId === cartItemId
        )[0];
        const quantityOfRemovedItem = removedItem
            ? removedItem.cartItem.quantity
            : 0;
        const updatedCartItems = (this.cartItems || []).filter(
            (item) => item.cartItem.cartItemId !== cartItemId
        );
        this.cartItems = updatedCartItems;
        this._cartItemCount -= Number(quantityOfRemovedItem);
        this.handleCartUpdate();
    }

    updateCartItemInformation(cartItem) {
        let count = 0;
        const updatedCartItems = (this.cartItems || []).map((item) => {
            let updatedItem = { ...item };
            if (updatedItem.cartItem.Id === cartItem.Id) {
                updatedItem.cartItem = cartItem;
            }
            count += Number(updatedItem.cartItem.quantity);
            return updatedItem;
        });
        this.cartItems = updatedCartItems;
        this._cartItemCount = count;
        this.updateCartItems();
    }
}