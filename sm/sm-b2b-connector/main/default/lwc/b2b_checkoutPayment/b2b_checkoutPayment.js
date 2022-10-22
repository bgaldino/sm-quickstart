import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import Colors from '@salesforce/resourceUrl/B2B_Colors';
import Fonts from '@salesforce/resourceUrl/B2B_Fonts';
import BoldFonts from '@salesforce/resourceUrl/B2B_Fonts_Bold';

import communityId from '@salesforce/community/Id';

export default class B2b_checkoutPayment extends LightningElement {
    @api
    get recordId() {
       return this._recordId;
    }
    set recordId(value) {
        this._recordId = value;
    }

    @api
    get effectiveAccountId() {
        return this._effectiveAccountId;
    }
    set effectiveAccountId(newId) {
        this._effectiveAccountId = newId;
    }

    get resolvedEffectiveAccountId() {
        const effectiveAcocuntId = this.effectiveAccountId || '';
        let resolved = null;
        if (
            effectiveAcocuntId.length > 0 &&
            effectiveAcocuntId !== '000000000000000'
        ) {
            resolved = effectiveAcocuntId;
        }
        return resolved;
    }
    categPath = [{"id":"0ZG8Z000000GsRzWAK","name":"Checkout"}];
    get path() {
        return {
            journey: this.categPath.map(
            (category) => ({
               // id: category.id,
                name: category.name
            })
        )
    };
    }
 
    connectedCallback() {
        loadStyle(this, Fonts);
        loadStyle(this, BoldFonts);
        loadStyle(this, Colors);
    }
}