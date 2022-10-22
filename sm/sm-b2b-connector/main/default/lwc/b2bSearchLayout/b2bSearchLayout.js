import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import Colors from '@salesforce/resourceUrl/B2B_Colors';
import Fonts from '@salesforce/resourceUrl/B2B_Fonts';
import BoldFonts from '@salesforce/resourceUrl/B2B_Fonts_Bold';

export default class B2bSearchLayout extends LightningElement {
   
   @api displayData;

   @api config;

   get layoutContainerClass() {
       return this.config.resultsLayout === 'grid'
           ? 'layout-grid'
           : 'layout-list';
   }

   get isGridLayout(){
       return this.config.resultsLayout === 'grid'
           ? true 
           : false; 
   }

   get isListLayout(){
       return this.config.resultsLayout === 'list'
           ? true 
           : false; 
   }
   connectedCallback(){
    loadStyle(this, Fonts);
    loadStyle(this, BoldFonts);
    loadStyle(this, Colors);
}
}