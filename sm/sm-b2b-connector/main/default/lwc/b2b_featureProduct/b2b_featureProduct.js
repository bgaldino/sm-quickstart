import { LightningElement,track,api,wire} from 'lwc';
import { CurrentPageReference } from "lightning/navigation";
import { loadStyle } from 'lightning/platformResourceLoader';
import Colors from '@salesforce/resourceUrl/B2B_Colors';
import Fonts from '@salesforce/resourceUrl/B2B_Fonts';
import BoldFonts from '@salesforce/resourceUrl/B2B_Fonts_Bold';
import { NavigationMixin } from 'lightning/navigation';

export default class B2b_featureProduct extends NavigationMixin(LightningElement) {

    @api productId;
    @api productName;
    @api productPrice;
    @api featureOne;
    @api featureTwo;
    @api featureThree;
    @api featureFour;
    @api featureFive;
    @api description;
    @api pricingModal;
    @track product = [];
    @api sellingModal;
    @wire(CurrentPageReference)
    currentPageReference;
    
    productsdetails;
    ListPrice;
    PriceValues;
    price;

    siteUrl;
    
    connectedCallback(){
        loadStyle( this, Fonts);
        loadStyle(this, BoldFonts);
        loadStyle(this, Colors);
        this.sfdcBaseURL = window.location.origin;

        console.log(window.screen.height, '___', window.screen.width)
       
    } 


    handleShowDetail(evt) {
        evt.stopPropagation();

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: evt.currentTarget.dataset.id,
                actionName: 'view'
            }
        });
    }

    handleClick(event){
        var prodId = event.currentTarget.dataset.id;
        let productName = event.currentTarget.dataset.name.replace(/\s+/g, '-').toLowerCase();
        console.log('baseurl-->'+this.sfdcBaseURL);
        location.href =this.sfdcBaseURL+'/s/'+ 'product' + '/' + productName + '/' + prodId;
    }
}