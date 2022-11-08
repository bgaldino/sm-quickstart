import { LightningElement,track,api,wire} from 'lwc';
import { CurrentPageReference } from "lightning/navigation";
import { loadStyle } from 'lightning/platformResourceLoader';
import Colors from '@salesforce/resourceUrl/B2B_Colors';
import Fonts from '@salesforce/resourceUrl/B2B_Fonts';
import BoldFonts from '@salesforce/resourceUrl/B2B_Fonts_Bold';
import getFeaturedProduct from '@salesforce/apex/B2B_HomeFeaturedProduct.getFeaturedProducts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class HomeFeatured extends LightningElement {
    @wire(CurrentPageReference)
    currentPageReference;
    
    productsdetails;
    ListPrice;
    PriceValues;
    price;

    _title = 'Error';
    message = 'Something Went Wrong.';
    variant = 'error';

    @track productmap=[];
    @track featuredProductData = [];

    siteUrl;
    
    connectedCallback(){
        loadStyle( this, Fonts);
        loadStyle(this, BoldFonts);
        loadStyle(this, Colors);
        this.sfdcBaseURL = window.location.origin;
        this.getFeaturedProductData();

    } 

    getFeaturedProductData(){

        getFeaturedProduct().then(result => {
            this.featuredProductData = result;

        }).catch(error =>{
             console.log(error, 'error===>>');
             this.showNotification();
        })


    }

    showNotification() {
        const evt = new ShowToastEvent({
            title: this._title,
            message: this.message,
            variant: this.variant,
        });
        this.dispatchEvent(evt);
    }


}