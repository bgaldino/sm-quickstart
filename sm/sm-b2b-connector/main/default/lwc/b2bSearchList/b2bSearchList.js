import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import Colors from '@salesforce/resourceUrl/B2B_Colors';
import Fonts from '@salesforce/resourceUrl/B2B_Fonts';
import BoldFonts from '@salesforce/resourceUrl/B2B_Fonts_Bold';

export default class B2bSearchList extends LightningElement {

    @api displayData;

    @api config;
    

    get image() {
        return this.displayData.image || {};
    }

    get fields() {
        return (this.displayData.fields || []).map(({ name, value }, id) => ({
            id: id + 1,
            tabIndex: id === 0 ? 0 : -1,
            // making the first field bit larger
            class: id
                ? 'slds-truncate slds-text-heading_small'
                : 'slds-truncate slds-text-heading_medium',
             value:
                name === 'Name' || name === 'Description'
                    ? value
                    : `${name}: ${value}`
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
        let isReruccing = false;
        for (let i = 0; i < this.displayData.fields.length; i++) {
          
           if(this.displayData.fields[i].name==='RecurringProduct__c' && this.displayData.fields[i].value==='true'){
               isReruccing = true;
           }
         }
        
       return isReruccing;
   }
  
    get cardContainerClass() {
        return 'card-layout-list';
    }
    get description() {
        return this.displayData.description || {};
    }

    connectedCallback(){
        loadStyle( this, Fonts);
        loadStyle(this, BoldFonts);
        loadStyle(this, Colors);
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
                    currencyCode : this.currency
                }
            })
        );
    }

    notifyShowDetail(evt) {
        evt.preventDefault();

        this.dispatchEvent(
            new CustomEvent('showdetail', {
                bubbles: true,
                composed: true,
                detail: { productId: this.displayData.id
                
                }
            })
        );
    }
}