import { LightningElement,api, wire, track } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import communityId from '@salesforce/community/Id';
import getProduct from '@salesforce/apex/B2BGetInfo.getProduct';
import getCartItemsByCartId from '@salesforce/apex/B2BGetInfo.getCartItemsByCartId';
import getCartItems from '@salesforce/apex/B2BCartControllerSample.getCartItems';
import updateCartItem from '@salesforce/apex/B2BCartControllerSample.updateCartItem';
import deleteCartItem from '@salesforce/apex/B2BCartControllerSample.deleteCartItem';
import deleteCart from '@salesforce/apex/B2BCartControllerSample.deleteCart';
import createCart from '@salesforce/apex/B2BCartControllerSample.createCart';
import updateCartItems from '@salesforce/apex/B2BGetInfo.updateCartItems';
import productWithPricingModel from '@salesforce/apex/B2BGetInfo.productWithPricingModel';
import errorLabel from '@salesforce/label/c.B2B_Negative_Or_Zero_Error';

import { transformData } from './b2bDataNormalizer';

import { fireEvent } from 'c/pubsub';
import { isCartClosed } from 'c/cartUtils';
import { refreshApex } from '@salesforce/apex';

const CART_CHANGED_EVT = 'cartchanged';
const CART_ITEMS_UPDATED_EVT = 'cartitemsupdated';
const QUANTITY_CHANGED_EVT = 'quantitychanged';

const LOCKED_CART_STATUSES = new Set(['Processing', 'Checkout']);

export default class B2b_cartItemsContent extends NavigationMixin(LightningElement) {
    @api recordId;

    @api effectiveAccountId;

    @wire(CurrentPageReference)
    pageRef;

    _cartItemCount = 0;

    @track cartItems = [];

    sortOptions = [
        { value: 'CreatedDateDesc', label: this.labels.CreatedDateDesc },
        { value: 'CreatedDateAsc', label: this.labels.CreatedDateAsc },
        { value: 'NameAsc', label: this.labels.NameAsc },
        { value: 'NameDesc', label: this.labels.NameDesc }
    ];
    categPath = [{"id":"0ZG8Z000000GsRzWAK","name":"Products"}, {"id":"0ZG8Z000000GsRzWAK","name":"Cart"}];

    pageParam = null;

    sortParam = 'CreatedDateDesc';

    isCartClosed = false;

    currencyCode;

    get isCartEmpty() {
        return Array.isArray(this.cartItems) && this.cartItems.length === 0;
    }

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
    /*displayData;
    _displayData;

    get displayData() {
        return this._displayData || {};
    }
    set displayData(data) {
        this._displayData = transformData(data, this._cardContentMapping);
    }*/
    _cardContentMapping;

    @api
    get cardContentMapping() {
        return this._cardContentMapping;
    }
    set cardContentMapping(value) {
        this._cardContentMapping = value;
    }

    connectedCallback() {
        this.updateCartItems();
    }
    /*getCartItemProduct(cartProduct){
         getProduct({
            communityId: communityId,
            productId: cartProduct,
            effectiveAccountId: this.resolvedEffectiveAccountId
        })
        .then((result) => {
            console.log('***result prod' + JSON.stringify(result) );
            return result;
        })
        .catch((e) => {
            console.log(e);
        });
    }
*/
    updateCartItems() {
        // console.log('DEB:: 1');
        return getCartItems({
            communityId: communityId,
            effectiveAccountId: this.resolvedEffectiveAccountId,
            activeCartOrId: this.recordId,
            pageParam: this.pageParam,
            sortParam: this.sortParam

        })
            .then((result) => {
                // console.log('DEB:: 2');
                let cartItemsTmp = result.cartItems;
                // console.log('DEB:: cartItemsTmp: ' + cartItemsTmp);
                // console.log('DEB:: JSON.stringify(cartItemsTmp): ' + JSON.stringify(cartItemsTmp));
                // console.log('DEB:: cartItemsTmp[0].cartItem.cartId: ' + cartItemsTmp[0].cartItem.cartId);

                // cartItemsTmp.forEach(item => {
                //     item.desc = 'TEST DESCRIPTION !@#';
                // });
                
                // console.log('***result ' + JSON.stringify(result) );
                this._cartItemCount = Number(
                    result.cartSummary.totalProductCount
                );
                this.currencyCode = result.cartSummary.currencyIsoCode;
                this.isCartDisabled = LOCKED_CART_STATUSES.has(
                    result.cartSummary.status
                );

                // if (cartItemsTmp[0].cartItem.cartId) {
                    // console.log('DEB:: 3');
                    return getCartItemsByCartId({
                        cartId: cartItemsTmp[0].cartItem.cartId
                    })
                    .then((res) => {
                        // console.log('DEB:: 4');
                        // console.log('DEB:: res: ' + res);
                        console.log('DEB:: JSON.stringify(res): ' + JSON.stringify(res));
                        // console.log('DEB:: res.get"0a98c000000kJcaAAE"): ' + res['0a98c000000kJcaAAE']['Product2']['Description']);
                        cartItemsTmp.forEach(item => {
                            // console.log('DEB:: 5');
                            // console.log('DEB:: JSON.stringify(item): ' + JSON.stringify(item));
                            // console.log('DEB:: JSON.stringify(item): ' + JSON.stringify(item));
                            // console.log('DEB:: JSON.stringify(item.cartItem): ' + JSON.stringify(item.cartItem));
                            let cartItemId = item['cartItem']['cartItemId'];
                            console.log('DEB:: cartItemId: ' + cartItemId);
                            // console.log('DEB:: 6');
                            if(res[cartItemId]) item.desc2 = res[cartItemId]['Product2']['Description'];
                            if(res[cartItemId]) item.entry = res[cartItemId]['B2B_PriceBookEntry_Id__c'];

                            if(res[cartItemId]){ 
                                if(res[cartItemId]['ProductSellingModel__c'] == 'Term Monthly'){
                                    item.model = 'Annual Subscription (paid monthly)';
                                } else if(res[cartItemId]['ProductSellingModel__c'] == 'Term Annual'){
                                    item.model = 'Annual Subscription (paid upfront)';
                                } else {
                                    item.model = res[cartItemId]['ProductSellingModel__c'];
                                }
                                if(res[cartItemId]['Discount__c'] > 0){

                                    item.discount = res[cartItemId]['Discount__c'] + res[cartItemId]['TotalPrice'];
                                    item.discountPercent = (res[cartItemId]['Discount__c']*100)/item.discount + '%';

                                }
                            }
                            // console.log('item.B2B_PriceBookEntry_Id__c ' + JSON.stringify(res[cartItemId]['B2B_PriceBookEntry_Id__c']));
                            //this.cartItems = [item];
                        });
                        

                        console.log('DEB:: 7');
                        this.cartItems = cartItemsTmp;
                        fireEvent(this.pageRef, CART_ITEMS_UPDATED_EVT);
                        refreshApex(this.cartItems);
                        // this.cartItems.push(item);
                    })
                // }
                
            //     cartItemsTmp.forEach(item => {

            //         return getProduct({
            //             communityId: communityId,
            //             productId: item.cartItem.productDetails.productId,
            //             effectiveAccountId: this.resolvedEffectiveAccountId
            //         })
            //         .then((res) => {
            //             this.displayData = res;
            //             item.desc2 = this.displayData.fields['Description'];
            //             this.cartItems = [item];
            //             console.log('***result ' + JSON.stringify(this.cartItems) );
            //         })
            //         .catch((e) => {
            //             console.log(e);
            //         });
                
            //     }
            //   );
              
                
            })
            .catch((error) => {
                const errorMessage = error.body.message;
                this.cartItems = undefined;
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
        fireEvent(this.pageRef, CART_ITEMS_UPDATED_EVT);
        refreshApex(this.cartItems);
      //  window.location.reload();
    }

    handleQuantityChanged(evt) {
        const { cartItemId, quantity } = evt.detail;
        console.log(communityId + ', ' + this.resolvedEffectiveAccountId + ', ' + this.recordId + ', ' + cartItemId + ', ' + quantity);
        /*updateCartItem({
            communityId: communityId,
            effectiveAccountId: this.resolvedEffectiveAccountId,
            activeCartOrId: this.recordId,
            cartItemId: cartItemId,
            cartItem: quantity 
        })*/ 
        updateCartItems({
            communityId: communityId, 
            effectiveAccountId: this.resolvedEffectiveAccountId,
            cartItemId: cartItemId,
            quantity: quantity 
        })
            .then((cartItem) => {
                this.updateCartItemInformation(cartItem);
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
                console.log("We stuck here");
                console.log(e);
            });
    }

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

                console.log('recordid___', this.recordId);
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
            })
            .catch((e) => {
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
        console.log("**** Cart " + JSON.stringify(cartItem));
      //  console.log("Cart Item - " + cartItem.cartItemId);
        let count = 0;
       // let id = cartItem.Id;
        const updatedCartItems = (this.cartItems || []).map((item) => {
            let updatedItem = { ...item };
          //  if (updatedItem.cartItem.cartItemId === cartItem.cartItemId) {
            if (updatedItem.cartItem.Id === cartItem.Id) {
                updatedItem.cartItem = cartItem;
            }
            count += Number(updatedItem.cartItem.quantity);
            return updatedItem;
        });
        this.cartItems = updatedCartItems;
        this._cartItemCount = count;
        /*this.dispatchEvent(
            new CustomEvent(QUANTITY_CHANGED_EVT, {
                bubbles: true,
                composed: true,
                cancelable: false,
                detail: {
                    id,
                    count
                }
            })
        );*/
        this.updateCartItems();
       // this.handleCartUpdate();
    }
}