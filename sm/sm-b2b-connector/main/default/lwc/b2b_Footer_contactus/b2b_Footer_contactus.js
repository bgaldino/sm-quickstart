import { LightningElement, api} from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import Colors from '@salesforce/resourceUrl/B2B_Colors';
import Fonts from '@salesforce/resourceUrl/B2B_Fonts';
import BoldFonts from '@salesforce/resourceUrl/B2B_Fonts_Bold';

export default class B2b_Footer_contactus extends LightningElement {

    @api title;
    @api description;
    @api button;
    @api buttonLink;
    @api backgroundColorLighter;
    @api backgroundColorDarker;

    get colorBackground() {
        return `background:linear-gradient(314.11deg, ${this.backgroundColorDarker} -6.95%, ${this.backgroundColorLighter} 190.01%);`;
    }

    connectedCallback(){
        loadStyle( this, Fonts);
        loadStyle(this, BoldFonts);
        loadStyle(this, Colors);
    }
}