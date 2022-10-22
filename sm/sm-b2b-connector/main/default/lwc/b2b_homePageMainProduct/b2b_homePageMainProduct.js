import { LightningElement } from 'lwc';
import img from '@salesforce/resourceUrl/D3Mark';
import img1 from '@salesforce/resourceUrl/Supplier360';
import { loadStyle } from 'lightning/platformResourceLoader';
import Colors from '@salesforce/resourceUrl/B2B_Colors';
import Fonts from '@salesforce/resourceUrl/B2B_Fonts';
import BoldFonts from '@salesforce/resourceUrl/B2B_Fonts_Bold';

export default class B2b_homePageMainProduct extends LightningElement {

    image1=img;
    image2=img1;
    connectedCallback(){
        loadStyle( this, Fonts);
        loadStyle(this, BoldFonts);
        loadStyle(this, Colors);
    }
}