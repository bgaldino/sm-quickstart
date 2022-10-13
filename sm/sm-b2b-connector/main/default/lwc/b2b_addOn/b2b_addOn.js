import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import Colors from '@salesforce/resourceUrl/B2B_Colors';
import Fonts from '@salesforce/resourceUrl/B2B_Fonts';
import BoldFonts from '@salesforce/resourceUrl/B2B_Fonts_Bold';

import communityId from '@salesforce/community/Id';
import { NavigationMixin } from 'lightning/navigation';
import { transformData } from './b2bDataNormalizer';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getPrices from '@salesforce/apex/B2B_RelatedProductsController.getProductPrices';
import productSearchIterable from '@salesforce/apex/B2B_SearchController.productSearchIterable';
import addOnProducts from '@salesforce/apex/B2B_RelatedProductsController.getAddOnProductsCategoryIdsByProductId';
import addToCart from '@salesforce/apex/B2BGetInfo.addToCart';
import getCartSummary from '@salesforce/apex/B2BGetInfo.getCartSummary';

export default class B2b_addOn  extends NavigationMixin(LightningElement) {

    _displayData;
    _cardContentMapping;
    productIds = [];
    cartSummary;
    currentUrl = window.location.href;

    pageNumber = 1;
    refinements = [];
    relatedProduct = [];
    filteredList =[];
    _recordId;
    productPrice = [];
    pricesList = [];
    limitResults = 2;
    showMore = true;
    showLess = false;
    showButton = false;

    @api
    get recordId() {
       return this._recordId;
    }
    set recordId(value) {
        this._recordId = value;
    }

    @api
    get cardContentMapping() {
        return this._cardContentMapping;
    }
    set cardContentMapping(value) {
        this._cardContentMapping = value;
    }

    @api displayData;

    get displayData() {
        return this._displayData || {};
    }
    set displayData(data) {
        this._displayData = transformData(data, this._cardContentMapping);
    }

    @api
    get effectiveAccountId() {
        return this._effectiveAccountId;
    }
    set effectiveAccountId(newId) {
        this._effectiveAccountId = newId;
    }

    get resolvedEffectiveAccountId() {
        const effectiveAcocuntId = this.effectiveAccountId || '';
        let resolved = null;
        if (
            effectiveAcocuntId.length > 0 &&
            effectiveAcocuntId !== '000000000000000'
        ) {
            resolved = effectiveAcocuntId;
        }
        return resolved;
    }

    connectedCallback() {
        loadStyle(this, Fonts);
        loadStyle(this, BoldFonts);
        loadStyle(this, Colors);
        this.updateCartInformation();
        this.triggerProductSearch();
    }

    triggerProductSearch() {
        
        addOnProducts({
            productId: this.recordId,
        })
            .then((result) => {
                const productIds = [];
                const categoryIds = [];
                for(var key in result) {
                    productIds.push(key);
                    categoryIds.push(result[key]);
                }

                var shortResult = productIds;
                if(shortResult.length > 2) {
                    this.showButton = true;
                }
                this.relatedProduct = shortResult;

                let uniqueCategories = [...new Set(categoryIds)];

                uniqueCategories.forEach(categoryId => {
                
                    const searchQuery = JSON.stringify({
                        refinements: this.refinements,
                        includeQuantityRule:true,
    
                        page: this.pageNumber - 1,
                        pageSize: 200,
                        grouping :{groupingOption:'VariationParent'},
                        includePrices: true,
                        categoryId: categoryId
                    });
                
                    return productSearchIterable({
                        communityId: communityId,
                        searchQuery: searchQuery,
                        effectiveAccountId: this.resolvedEffectiveAccountId
                    })
                    .then((result) => {
                        let resData = result;

                        return getPrices({productId : this.getProductIds(resData)})
                        .then(res => {
                            this.mergeProductPrices(resData, res);
                            this.displayData = resData;

                            let tmpArray = [];

                            this.filteredList = this.filteredList.concat(
                                this.displayData.layoutData.filter(item => {
                                    return this.relatedProduct.includes(item.id);
                                })
                            ).filter((product) => {
                                if (tmpArray.indexOf(product.id) === -1) {
                                    tmpArray.push(product.id);
                                    return true
                                }
                                return false;
                            });
                            // this.filteredList = this.displayData.layoutData.filter(item => {
                            //     return this.relatedProduct.includes(item.id);
                            // });
                        })              
                    })
                    .catch((error) => {
                        this.error = error;
                        console.log(error);
                    });
                })
            })
            .catch((error) => {
                this.error = error;
                console.log(error);
            });
    }
    getProductIds(result) {
        let test = (result.productsPage.products || []).map((product) => product.id);
        return test;
    }

    mergeProductPrices(result, prices) {
        (result.productsPage.products || []).forEach((product) => {
          if (prices.hasOwnProperty(product.id)) {
            product.price = prices[product.id];
          }
        });
    }

    addItemsAction(event){
        this.template.querySelector('.content-list').classList.add('more');
        this.showMore = false;
        this.showLess = true;
    }
    lessItemsAction(event){
        this.template.querySelector('.content-list').classList.remove('more');
        this.showMore = true;
        this.showLess = false;
    }

    updateCartInformation() {
        getCartSummary({
            communityId: communityId,
            effectiveAccountId: this.resolvedEffectiveAccountId
        })
            .then((result) => {
                this.cartSummary = result;
                console.log('*** cart ' + JSON.stringify(result));
            })
            .catch((e) => {
                console.log(e);
            });
    }
      
    notifyAction(evt) {
        let productName = evt.target.name;
        let productid = (evt.target.id).split('-')[0];
        let productUrl = this.currentUrl.split('/s/');

        let newUrl = productUrl[0] + '/s/product/' + productName + '/' + productid;

        window.location.href = newUrl;
    }

}