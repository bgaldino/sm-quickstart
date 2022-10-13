import { LightningElement, api, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import Colors from '@salesforce/resourceUrl/B2B_Colors';
import Fonts from '@salesforce/resourceUrl/B2B_Fonts';
import BoldFonts from '@salesforce/resourceUrl/B2B_Fonts_Bold';

import iconsImg from '@salesforce/resourceUrl/img';

import getUser from '@salesforce/apex/B2BGetInfo.getCheckoutUser';
import getCountriesAndStates from "@salesforce/apex/B2BGetInfo.getCountriesAndStates";
import setBillingAddress from "@salesforce/apex/B2BGetInfo.setBillingAddress";
import setShippingAddress from "@salesforce/apex/B2BGetInfo.setShippingAddress";

import { ShowToastEvent } from "lightning/platformShowToastEvent";
import {
    FlowAttributeChangeEvent,
    FlowNavigationNextEvent,
    FlowNavigationBackEvent
  } from "lightning/flowSupport";

export default class B2b_checkoutAccountInformation extends LightningElement {
    CompanyName = '';
    serviceAddressIsCompanyAddress = true;
    isChecked = true;

    country;
    countriesWithRequiredState;
    countries;
    states;
    areStatesAvailable;
    
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
  /*  @wire (getUser, {
        effectiveAccountId: '$effectiveAccountId'
    })*/
    currentUser = {};
    address = {};
    usersContact = [];

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

    info = `${iconsImg}#info`;
    add = `${iconsImg}#add`;
    
    handleChange(event){
        const inputId = event.currentTarget.id.split('-')[0];
        if(!event.target.value){
            this.template.querySelector('[data-id=' + inputId + ']').className = 'form-control';
        } else if(event.target.value){
            this.template.querySelector('[data-id=' + inputId + ']').className ='form-control not-empty';
        } 
    }

    handleCountryChange(event) {
        this.country = event.detail.value;
        this.findStates(this.country);
        this.address.state = '';
    }

    findStates(country) {
        const countryShortValue = this.countries.find(loopCountry => {
            return loopCountry.value === country;
        }).shortValue;
        this.states = this.statesByCountries[countryShortValue];
        this.areStatesAvailable = this.states.length > 0;
        if(!this.states) {
            this.state = "";
        }
    }
 
    connectedCallback() {
        loadStyle(this, Fonts);
        loadStyle(this, BoldFonts);
        loadStyle(this, Colors);
        this.getAddressPicklists();
       // this.getCurrentUserInfo();
    }
   /* renderedCallback() { 
      this.template.querySelectorAll('label[data-id]').forEach(element => {
            console.log('***id ' + element.id.split('-')[0]);
            const inputId = element.id.split('-')[0];
            if(inputId){
            console.log('***elem ' + element.querySelector('input').value);
            if(!element.querySelector('input').value){
                this.template.querySelector('[data-id=' + inputId + ']').className = 'form-control';
            } else if(element.querySelector('input').value){
                this.template.querySelector('[data-id=' + inputId + ']').className ='form-control not-empty';
            } 
        }
        });
    }*/

    getAddressPicklists(){
        return getCountriesAndStates({})
            .then(countriesAndStates => {
               // console.log('***res ' + JSON.stringify(countriesAndStates.countries));
                this.countries = JSON.parse(JSON.stringify(countriesAndStates.countries));
                
                this.countries.forEach(country => {
                    country.shortValue = country.value;
                    country.value = country.label;
                });

                this.statesByCountries = JSON.parse(JSON.stringify(countriesAndStates.statesByCountries));
                Object.keys(this.statesByCountries).forEach(country => {
                    this.statesByCountries[country].forEach(state => {
                        state.shortValue = state.value;
                        state.value = state.label;
                    });
                });
                if(this.country) this.findStates(this.country);
                this.getCurrentUserInfo();
              // return this.countries;
            })
            .catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    title: ERROR,
                    message: error.message || error.body.message || (error.body.pageErrors?.length > 0 && error.body.pageErrors[0].message) || INTERNAL_ERROR,
                    variant: 'error'
                }),);
            });
    }

    getCurrentUserInfo(){
        getUser({
            effectiveAccountId: this.effectiveAccountId
        })
        .then((result) => {
            this.currentUser = result;
            this.usersContact = result.Contact;
            this.address = JSON.parse(JSON.stringify(result.Address));
          //  console.log('**this.countries ' + JSON.stringify(this.countries));
            this.countries.forEach(country => {
                   if(country.shortValue == result.Address.countryCode){
                    this.address.country = country.label;
                    let defaultState = this.statesByCountries[country.shortValue];
                    defaultState.forEach(state => {
                        if(state.shortValue == this.address.stateCode){
                        this.address.state = state.label;
                    }
                    });
                   }
            }); 
            if(this.address.country) this.findStates(this.address.country);
        })
        .catch((error) => {
            this.error = error;
            console.log(error);
        });
    }

    handleCheckbox(event){
        this.isChecked = event.target.checked;
        if(this.isChecked == false){
            this.serviceAddressIsCompanyAddress = false;
        } else {
            this.serviceAddressIsCompanyAddress = true;
        }
    }

    saveAddresses(event){
        console.log('**billing ' + this.template.querySelector("[data-field='country-billing']").value);
    setBillingAddress({Street: this.template.querySelector("[data-field='street-billing']").value,
                    Country: this.template.querySelector("[data-field='country-billing']").value,
                    State: this.template.querySelector("[data-field='state-billing']").value,
                    City: this.template.querySelector("[data-field='city-billing']").value,
                    ZipCode: this.template.querySelector("[data-field='zip-billing']").value,
                    cartId: this.recordId
    });
    if(this.serviceAddressIsCompanyAddress = true){
        setShippingAddress({Street: this.template.querySelector("[data-field='street-billing']").value,
                    Country: this.template.querySelector("[data-field='country-billing']").value,
                    State: this.template.querySelector("[data-field='state-billing']").value,
                    City: this.template.querySelector("[data-field='city-billing']").value,
                    ZipCode: this.template.querySelector("[data-field='zip-billing']").value,
                    Name: this.currentUser.Name,
                    cartId: this.recordId
        });
    } else {
        console.log('**shipping ' + this.template.querySelector("[data-field='country-shipping']").value);
        setShippingAddress({Street: this.template.querySelector("[data-field='street-shipping']").value,
                    Country: this.template.querySelector("[data-field='country-shipping']").value,
                    State: this.template.querySelector("[data-field='state-shipping']").value,
                    City: this.template.querySelector("[data-field='city-shipping']").value,
                    ZipCode: this.template.querySelector("[data-field='zip-shipping']").value,
                    Name: this.currentUser.Name,
                    cartId: this.recordId
        });
    }
    setTimeout(() => {
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
      }, 500);
    }

}