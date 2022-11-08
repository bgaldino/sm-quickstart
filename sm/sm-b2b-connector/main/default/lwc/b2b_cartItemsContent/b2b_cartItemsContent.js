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

    updateCartItems() {
        return getCartItems({
            communityId: communityId,
            effectiveAccountId: this.resolvedEffectiveAccountId,
            activeCartOrId: this.recordId,
            pageParam: this.pageParam,
            sortParam: this.sortParam

        })
            .then((result) => {
                let cartItemsTmp = result.cartItems;
                this._cartItemCount = Number(
                    result.cartSummary.totalProductCount
                );
                this.currencyCode = result.cartSummary.currencyIsoCode;
                this.isCartDisabled = LOCKED_CART_STATUSES.has(
                    result.cartSummary.status
                );
                    return getCartItemsByCartId({
                        cartId: cartItemsTmp[0].cartItem.cartId
                    })
                    .then((res) => {
                        cartItemsTmp.forEach(item => {
                            let cartItemId = item['cartItem']['cartItemId'];
                            if(res[cartItemId]) item.desc2 = res[cartItemId]['productDescription'];
                            if(res[cartItemId]) item.entry = res[cartItemId]['priceBookEntryId'];

                            if(res[cartItemId]){ 
                                if(res[cartItemId]['productSellingModel'] == 'Term Monthly'){
                                    item.model = 'Annual Subscription (paid monthly)';
                                } else if(res[cartItemId]['productSellingModel'] == 'Evergreen Monthly'){
                                    item.model = 'Annual Subscription (paid upfront)';
                                } else {
                                    item.model = res[cartItemId]['productSellingModel'];
                                }
                                if(res[cartItemId]['discount'] > 0){

                                    item.discount = res[cartItemId]['discount'] + res[cartItemId]['TotalPrice'];
                                    item.discountPercent = (res[cartItemId]['discount']*100)/item.discount + '%';

                                }
                            }
                        });

                        this.cartItems = cartItemsTmp;
                        fireEvent(this.pageRef, CART_ITEMS_UPDATED_EVT);
                        refreshApex(this.cartItems);
                    })
  
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
    }

    handleQuantityChanged(evt) {
        const { cartItemId, quantity } = evt.detail;
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