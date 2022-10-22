import { LightningElement, api, track, wire } from 'lwc';

import { resolve } from 'c/cmsResourceResolver';
import { getLabelForOriginalPrice, displayOriginalPrice } from 'c/cartUtils';
import productWithPricingModel from '@salesforce/apex/B2BGetInfo.productWithPricingModel';
import { refreshApex } from '@salesforce/apex';
import { fireEvent } from 'c/pubsub';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';

import { loadStyle } from 'lightning/platformResourceLoader';
import Colors from '@salesforce/resourceUrl/B2B_Colors';
import Fonts from '@salesforce/resourceUrl/B2B_Fonts';
import BoldFonts from '@salesforce/resourceUrl/B2B_Fonts_Bold';

import iconsImg from '@salesforce/resourceUrl/img';

const CART_CHANGED_EVT = 'cartchanged';
const CART_ITEMS_UPDATED_EVT = 'cartitemsupdated';
const QUANTITY_CHANGED_EVT = 'quantitychanged';
const SINGLE_CART_ITEM_DELETE = 'singlecartitemdelete';

export default class Items extends NavigationMixin(LightningElement) {

    @api currencyCode;

    @api isCartDisabled = false;
   
    @wire(CurrentPageReference)
    pageRef;


    @api
    get cartItems() {
        return this._providedItems;
    }

    set cartItems(items) {
        this._providedItems = items;
        const generatedUrls = [];
        this._items = (items || []).map((item) => {
            console.log('***item. ' + JSON.stringify(item));
            const newItem = { ...item };
            newItem.productUrl = '';
            newItem.productImageUrl = resolve(
                item.cartItem.productDetails.thumbnailImage.url
            );
            newItem.productImageAlternativeText =
                item.cartItem.productDetails.thumbnailImage.alternateText || '';

            const urlGenerated = this._canResolveUrls
                .then(() =>
                    this[NavigationMixin.GenerateUrl]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: newItem.cartItem.productId,
                            objectApiName: 'Product2',
                            actionName: 'view'
                        }
                    })
                )
                .then((url) => {
                    newItem.productUrl = url;
                });
            generatedUrls.push(urlGenerated);
               return newItem; 
        });

        Promise.all(generatedUrls).then(() => {
            this._items = Array.from(this._items);
        });
        
    }

    @track _items = [];
    _providedItems;
    _connectedResolver;
    _canResolveUrls = new Promise((resolved) => {
        this._connectedResolver = resolved;
    });

    @track quantityFieldValue;

    minus = `${iconsImg}#minus`;
    plus = `${iconsImg}#plus`;

    connectedCallback() {
        loadStyle(this, Fonts);
        loadStyle(this, BoldFonts);
        loadStyle(this, Colors);
        this._connectedResolver();
    }

    disconnectedCallback() {
        this._canResolveUrls = new Promise((resolved) => {
            this._connectedResolver = resolved;
        });
    }

    get displayItems() {
        return this._items.map((item) => {
            const newItem = { ...item };
            newItem.showNegotiatedPrice =
                this.showNegotiatedPrice &&
                (newItem.cartItem.totalPrice || '').length > 0;
            newItem.showOriginalPrice = displayOriginalPrice(
                this.showNegotiatedPrice,
                this.showOriginalPrice,
                newItem.cartItem.totalPrice,
                newItem.cartItem.totalListPrice
            );
            newItem.originalPriceLabel = getLabelForOriginalPrice(
                this.currencyCode,
                newItem.cartItem.totalListPrice
            );
            return newItem;
        });
    }

    get labels() {
        return {
            quantity: 'QTY',
            originalPriceCrossedOut: 'Original price (crossed out):'
        };
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

    handleDeleteCartItem(clickEvt) {
        const cartItemId = clickEvt.target.dataset.cartitemid;
        this.dispatchEvent(
            new CustomEvent(SINGLE_CART_ITEM_DELETE, {
                bubbles: true,
                composed: true,
                cancelable: false,
                detail: {
                    cartItemId
                }
            })
        );
    }

    handleQuantitySelectorBlur(blurEvent) {
        blurEvent.stopPropagation();
        const cartItemId = blurEvent.target.dataset.itemId;
        const quantity = blurEvent.target.value;
        this.dispatchEvent(
            new CustomEvent(QUANTITY_CHANGED_EVT, {
                bubbles: true,
                composed: true,
                cancelable: false,
                detail: {
                    cartItemId,
                    quantity
                }
            })
        );
    }

    handleOnlyNaturalkeyup(e) {
        if(e.target.value.length==1) {
            e.target.value=e.target.value.replace(/[^1-9]/g,'')
        } else {
            e.target.value=e.target.value.replace(/\D/g,'')
        }
    }

    handleOnlyNaturalAfterPaste(e) {
        if(e.target.value.length==1) {
            e.target.value=e.target.value.replace(/[^1-9]/g,'0')
        } else {
            e.target.value=e.target.value.replace(/\D/g,'')
        }
    }

    handleQuantitySelectorClick(clickEvent) {
        clickEvent.target.focus();
    }

    handleQuantityChange(quantity, cartItemId) {
        this.dispatchEvent(
            new CustomEvent(QUANTITY_CHANGED_EVT, {
                bubbles: true,
                composed: true,
                cancelable: false,
                detail: {
                    cartItemId,
                    quantity
                }
            })
        );
    }

    notifyCreateAndAddToList() {
        this.dispatchEvent(new CustomEvent('createandaddtolist'));
    }

    addQty(event){
        this.quantityFieldValue = parseInt(event.target.value) + 1;
        this.dispatchEvent(new CustomEvent('createandaddtolist'));
        this.handleQuantityChange(this.quantityFieldValue.toString(), event.target.dataset.itemId);
    }

    subQuanity(event){
        if(parseInt(event.target.value) > 1){
            this.quantityFieldValue = parseInt(event.target.value) - 1;
            this.dispatchEvent(new CustomEvent('createandaddtolist'));
            this.handleQuantityChange(this.quantityFieldValue.toString(), event.target.dataset.itemId);
        }
    }
}