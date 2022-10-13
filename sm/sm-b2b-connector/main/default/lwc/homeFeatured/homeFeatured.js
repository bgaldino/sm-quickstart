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

        // FetchProductDetails()
        //     .then(result => {
        //         this.productsdetails = result;
        //         for (let i = 0; i < this.productsdetails.length; i++) {
        //         var prodData = JSON.stringify(this.productsdetails[i]);
        //         var prodobject = JSON.parse(prodData);
        //         this.productmap.push({Id : prodobject.Id});
                
        //         }
        //     })
        //     .catch(error => {
        //         console.log('error--> ' + JSON.stringify(error));
        //         console.log('error--> ' + error);
        // });
    } 

    getFeaturedProductData(){

        getFeaturedProduct().then(result => {

            console.log(JSON.stringify(result), '___result');
            
            for (let i = 0; i < result.length; i++) {
                
                    this.featuredProductData.push({Id:result[i].Id,
                                                   name:result[i].Name, 
                                                   price:result[i].PricebookEntries[0].UnitPrice,
                                                   feature1:result[i].Feature1__c, 
                                                   feature2:result[i].Feature2__c, 
                                                   feature3:result[i].Feature3__c, 
                                                   feature4:result[i].Feature4__c, 
                                                   feature5:result[i].Feature5__c, 
                                                   decription:result[i].Description,
                                                   sellingModalName:result[i].PricebookEntries[0].ProductSellingModel.Name,

                                                    });
                        }

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