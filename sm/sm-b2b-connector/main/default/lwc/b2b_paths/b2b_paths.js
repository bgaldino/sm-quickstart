import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import { loadStyle } from 'lightning/platformResourceLoader';
import Colors from '@salesforce/resourceUrl/B2B_Colors';
import Fonts from '@salesforce/resourceUrl/B2B_Fonts';
import BoldFonts from '@salesforce/resourceUrl/B2B_Fonts_Bold';

const homePage = {
    name: 'Home',
    type: 'standard__namedPage',
    attributes: {
        pageName: 'home'
    }
};

export default class B2b_paths extends NavigationMixin(LightningElement) {
    _categoryPath;
    _resolvedCategoryPath = [];

    @api
    get categoryPath() {
        return this._categoryPath;
    }

    set categoryPath(newPath) {
        this._categoryPath = newPath;
        this.resolveCategoryPath(newPath || []);
    }

    _resolveConnected;
    _connected = new Promise((resolve) => {
        this._resolveConnected = resolve;
    });

    resolveCategoryPath(newPath) {
        const path = [homePage].concat(
            newPath.map((level) => ({
                name: level.name,
                type: 'standard__recordPage',
                attributes: {
                    actionName: 'view',
                    recordId: level.id
                }
            }))
        );
        this._connected
            .then(() => {
                const levelsResolved = path.map((level) =>
                    this[NavigationMixin.GenerateUrl]({
                        type: level.type,
                        attributes: level.attributes
                    }).then((url) => ({
                        name: level.name,
                        url: url
                    }))
                );

                return Promise.all(levelsResolved);
            })
            .then((levels) => {
                this._resolvedCategoryPath = levels;
            });
    }

    connectedCallback(){
        loadStyle(this, Fonts);
        loadStyle(this, BoldFonts);
        loadStyle(this, Colors);
        this._resolveConnected();
    }

disconnectedCallback() {
    this._connected = new Promise((resolve) => {
        this._resolveConnected = resolve;
    });
}

}