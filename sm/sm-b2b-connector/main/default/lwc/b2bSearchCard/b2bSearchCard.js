import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import Description from '@salesforce/schema/Product2.Description';
import { loadStyle } from 'lightning/platformResourceLoader';
import Colors from '@salesforce/resourceUrl/B2B_Colors';
import Fonts from '@salesforce/resourceUrl/B2B_Fonts';
import BoldFonts from '@salesforce/resourceUrl/B2B_Fonts_Bold';

let fieldd = [Description]
export default class B2bSearchCard extends LightningElement {

    @api recordId;
    @wire(getRecord, { recordId:`$recordId`, fieldd })
    product2;

    get description() {
        return getFieldValue(this.product2.data, Description);
    }
 
    @api displayData;

    @api config;

    get image() {
        return this.displayData.image || {};
    }
    get description() {
        return this.displayData.description || {};
    }

    get records() { 
        return (this.displayData.fields || []).map(({ name, value }, id) => ({
                id: id + 1,
                tabIndex: id === 0 ? 0 : -1,
                class: id
                    ? 'slds-truncate slds-text-heading_small'
                    : 'slds-truncate slds-text-heading_medium',
                show:name!=='RecurringProduct__c',
                value: 
                         name === 'Name' || name === 'Description'
                        ? value
                        : `${name}: ${value}`,
        }));
    }

    get showImage() {
        return !!(this.config || {}).showImage;
    }

    get actionDisabled() {
        return !!(this.config || {}).actionDisabled;
    }

    get listingPrice() {
        return this.displayData.prices.price;
    }

    get priceBookEntryId() {
        return this.displayData.prices.priceBookEntryId;
    }

    get canShowListingPrice() {
        const prices = this.displayData.prices;

        return (
            prices.price
        );
    }

    get currency() {
        return this.displayData.prices.currencyIsoCode;
    }

     get recurringProduct() {
         
         let isReruccing = true;
         for (let i = 0; i < this.displayData.fields.length; i++) {
           
            if(this.displayData.fields[i].name==='RecurringProduct__c' && this.displayData.fields[i].value==='true'){
                isReruccing = true;
            }
          }
        return isReruccing;
    }

    get cardContainerClass() {
        return this.config.resultsLayout === 'grid'
            ? 'slds-box card-layout-grid'
            : 'card-layout-list';
    }

    connectedCallback(){
        loadStyle(this, Fonts);
        loadStyle(this, BoldFonts);
        loadStyle(this, Colors);
        console.dir(this.displayData.id)
    }

    notifyAction() {
        this.dispatchEvent(
            new CustomEvent('calltoaction', {
                bubbles: true,
                composed: true,
                detail: {
                    productId: this.displayData.id,
                    productName: this.displayData.name,
                    pricebookEntryId: this.priceBookEntryId,
                    price: this.price,
                    currencyCode : this.currency,
                    Description:this.displayData.name
                }
            })
        );
    }

    notifyShowDetail(evt) {
        evt.preventDefault();
        console.log('Display Data--> prod det '+this.displayData.id)
          console.log(Description)
          
        this.dispatchEvent(

            new CustomEvent('showdetail', {
                bubbles: true,
                composed: true,
                detail: { productId: this.displayData.id }
            })
        );
    }
}