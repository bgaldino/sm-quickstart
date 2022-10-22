/* eslint-disable @lwc/lwc/no-async-operation */
import { LightningElement, api, wire } from 'lwc';
import communityId from '@salesforce/community/Id';
import { NavigationMixin } from 'lightning/navigation';
import { transformData } from './b2bDataNormalizer';

import productSearch from '@salesforce/apex/B2B_SearchController.productSearchIterable';
import getProductPrices from '@salesforce/apex/B2B_SearchController.getProductPrices';
import getPrices from '@salesforce/apex/B2B_RelatedProductsController.getProductPrices';
import relatedProducts from '@salesforce/apex/B2B_RelatedProductsController.getRelatedProductsWithCategoriesByProductId';

import { loadStyle } from 'lightning/platformResourceLoader';
import Colors from '@salesforce/resourceUrl/B2B_Colors';
import Fonts from '@salesforce/resourceUrl/B2B_Fonts';
import BoldFonts from '@salesforce/resourceUrl/B2B_Fonts_Bold';

export default class B2b_RelatedProducts extends NavigationMixin(LightningElement) {
    currentUrl = window.location.href;
  
    _displayData;
    _cardContentMapping;
    productIds = [];

    pageNumber = 1;
    refinements = [];
    relatedProduct = [];
    filteredList =[];
    _recordId;
    productPrice = [];
    pricesList = [];

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
        console.log('*** related acc ' + resolved);
        return resolved;
    }
 
    connectedCallback() {
        loadStyle(this, Fonts);
        loadStyle(this, BoldFonts);
        loadStyle(this, Colors);
        this.triggerProductSearch();
    }

    triggerProductSearch() {
        relatedProducts({
            productId:this.recordId
        })
            .then((result) => { 
                const productIds = [];
                const categoryIds = [];
                for(var key in result) {
                    productIds.push(key);
                    categoryIds.push(result[key]);
                }
                this.relatedProduct = productIds;

                categoryIds.forEach(categoryId => {
                
                    const searchQuery = JSON.stringify({
                        refinements: this.refinements,
                        includeQuantityRule:true,
    
                        page: this.pageNumber - 1,
                        pageSize: 200,
                        grouping :{groupingOption:'VariationParent'},
                        includePrices: true,
                        categoryId: categoryId,
                    });
      
                    productSearch({
                        communityId: communityId,
                        searchQuery: searchQuery,
                        effectiveAccountId: this.resolvedEffectiveAccountId
                    })
                    .then((result) => {
                        let resData = result;
              
                        /*return getPrices({productId : this.getProductIds(resData)})
                        .then(res => {
                        this.mergeProductPrices(resData, res);*/
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
                        // })
                    })
                    .catch((error) => {
                        this.error = error;
                    })
                
                });
            })
            .catch((error) => {
                this.error = error;
            });
    }
    getProductIds(result) {
        let test = (result.productsPage.products || []).map((product) => product.id);
        return test;
      }

    mergeProductPrices(result, prices) {
        (result.productsPage.products || []).forEach((product) => {
         //   console.log('product'+ JSON.stringify(product));
          if (prices.hasOwnProperty(product.id)) {
         //   console.log('prod --'+ prices[product.id]);
            product.price = prices[product.id];
        //    product.negotiatedPrice = prices[product.id];
       //     product.listingPrice = product.unitPrice;
            
          //  console.log('After Price --'+ JSON.stringify(product));
          }
        });
      }
 
    handleClick(event) {
        let productName = event.target.name;
        let productid = (event.target.id).split('-')[0];;
        let productUrl = this.currentUrl.split('/s/');
        let newUrl = productUrl[0] + '/s/product/' + productName + '/' + productid;
        window.location.href = newUrl;
    }

}