import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import Colors from '@salesforce/resourceUrl/B2B_Colors';
import Fonts from '@salesforce/resourceUrl/B2B_Fonts';
import BoldFonts from '@salesforce/resourceUrl/B2B_Fonts_Bold';

import iconsImg from '@salesforce/resourceUrl/img';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {
    FlowAttributeChangeEvent,
    FlowNavigationNextEvent,
    FlowNavigationBackEvent
  } from "lightning/flowSupport";

export default class B2b_checkoutOrderReview extends LightningElement {

    isChecked = true;
    lock = `${iconsImg}#lock`;
    check = `${iconsImg}#check`;

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

    chanheConfirmation(event){
        this.isChecked = event.target.checked;
    }

    confirmOrder(event){
        if(this.isChecked == true){
        setTimeout(() => {
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }, 500);
        } else {
            const event = new ShowToastEvent({
                title: 'Please, confirm terms',
                message: 'Please, confirm terms',
                variant: 'error',
            });
            this.dispatchEvent(event);
        }
    }
}