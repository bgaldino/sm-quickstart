import { LightningElement, api} from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import Colors from '@salesforce/resourceUrl/B2B_Colors';
import Fonts from '@salesforce/resourceUrl/B2B_Fonts';
import BoldFonts from '@salesforce/resourceUrl/B2B_Fonts_Bold';

export default class Footer_demo extends LightningElement {
    @api title;
    @api description;
    @api button;
    @api buttonLink;
    @api backgroundColor;
    @api backgroundColorLighter;
    @api backgroundColorDarker;
    @api facebook;
    @api instagram;
    @api twitter;
    @api L1_Title;
    @api L1_I1_Text;
    @api L1_I1_Link
    @api L1_I2_Text;
    @api L1_I2_Link
    @api L1_I3_Text;
    @api L1_I3_Link
    @api L2_Title;
    @api L2_I1_Text;
    @api L2_I1_Link;
    @api L2_I2_Text;
    @api L2_I2_Link;
    @api L2_I3_Text;
    @api L2_I3_Link;
    @api L2_I4_Text;
    @api L2_I4_Link;
    @api L2_I5_Text;
    @api L2_I5_Link;
    @api L3_Title;
    @api L3_I1_Text;
    @api L3_I1_Link;
    @api L3_I2_Text;
    @api L3_I2_Link;
    @api L3_I3_Text;
    @api L3_I3_Link;
    @api L3_I4_Text;
    @api L3_I4_Link;
    @api L4_Title;
    @api L4_I1_Text;
    @api L4_I1_Link;
    @api L4_I2_Text;
    @api L4_I2_Link;
    @api L4_I3_Text;
    @api L4_I3_Link;

    get colorBackground() {
        return `background:linear-gradient(314.11deg, ${this.backgroundColorDarker} -6.95%, ${this.backgroundColorLighter} 190.01%);`;
    }
    get colorfooterBackground() {
        return `background-color:${this.backgroundColor};`;
    }

    connectedCallback(){
        loadStyle( this, Fonts);
        loadStyle(this, BoldFonts);
        loadStyle(this, Colors);
    }
}