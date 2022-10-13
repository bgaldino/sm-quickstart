import { LightningElement, api, wire} from 'lwc';
import basePath from '@salesforce/community/basePath';
import { listContent } from 'lightning/cmsDeliveryApi';
import communityId from '@salesforce/community/Id';
import { loadStyle } from 'lightning/platformResourceLoader';
import Colors from '@salesforce/resourceUrl/B2B_Colors';
import Fonts from '@salesforce/resourceUrl/B2B_Fonts';
import BoldFonts from '@salesforce/resourceUrl/B2B_Fonts_Bold';

export default class B2B_HomePageHero extends LightningElement {
 
    @api imageUrl;
    @api heading;
    @api subHeading;
    @api description;
    @api backgroundColor;
    @api button1;
    @api button2;
    @api button1Link;
    @api button2Link;
    @api imageSize;
   
    contentKeys = [undefined];
     
    get scale(){
         return `transform: scale(${this.imageSize}%);`;
    }
    get colorBackground() {
        return `background-color:${this.backgroundColor};`;
    }

    @api get cmsContentId() {
        return this.contentKeys[0];
    }
    set cmsContentId(id) {
        this.contentKeys = [id];
    }

    @wire(listContent, { communityId: communityId, contentKeys: '$contentKeys' })
    onListContent(results) {
        const content = results.data;
        if (!this.imageUrl && content && content.items) {
            this.imageUrl = basePath.replace('/s', '') + content.items[0]?.contentNodes?.source?.url;
        }
    }

    connectedCallback(){
        loadStyle( this, Fonts);
        loadStyle(this, BoldFonts);
        loadStyle(this, Colors);
    }
}