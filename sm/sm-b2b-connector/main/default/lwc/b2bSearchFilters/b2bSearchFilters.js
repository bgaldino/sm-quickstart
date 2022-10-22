import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import Colors from '@salesforce/resourceUrl/B2B_Colors';
import Fonts from '@salesforce/resourceUrl/B2B_Fonts';
import BoldFonts from '@salesforce/resourceUrl/B2B_Fonts_Bold';

export default class B2bSearchFilters extends LightningElement {

    @api
    get displayData() {
        return this._displayData;
    }
    set displayData(value) {
        this._displayData = value;
        this.facets = value || [];
    }

    @api
    clearAll() {
        this._refinementMap.clear();
        this._facets = [];
        this._mruFacet = undefined;
    }

    get facets() {
        return this._facets || [];
    }
    set facets(value) {
        this._facets = value
            .map((facet) => this.mergeFacetIfMatch(this._mruFacet, facet))
            .map((facet) => ({
                ...facet,
                values: facet.values.map((val) => ({
                    ...val,
                    displayLabel: `${val.displayName }`,
                    displaycount:val.productCount

                }))
            }));

        if (this._facets.length === 0 && this._mruFacet) {
            this._facets = [this._mruFacet];
        }
    }
    
    get activeSections() {
        return this._sections
            ? this._sections
            : (this.facets || []).map((facet) => facet.id);
    }

    mergeFacetIfMatch(mruFacet, facet) {
        let resultFacet;
        if (mruFacet && mruFacet.id === facet.id) {
            const mruValues = (mruFacet || {}).values || [];
            const facetValues = (facet || {}).values || [];

            const mergedMap = [...mruValues, ...facetValues].reduce(
                (map, value) => {
                    map.set(value.nameOrId, { ...value });
                    return map;
                },
                new Map()
            );

            resultFacet = {
                ...facet,
                values: Array.from(mergedMap.values())
            };
        } else {
            resultFacet = { ...facet };
        }
        return resultFacet;
    }

    handleCheckboxChange(evt) {
        const facets = this.facets;
        const { filterId, facetId } = evt.target.dataset;
        const [currentFacet] = facets.filter((item) => item.id === facetId);

        if (this._refinementMap.has(facetId)) {
            const values = this._refinementMap.get(facetId);
            if (evt.detail.checked) {
                values.add(filterId);
            } else {
                values.delete(filterId);
            }
        } else {
            this._refinementMap.set(facetId, new Set([filterId]));
        }

        this._mruFacet = currentFacet;

        const refinements = facets.map(
            ({ id, attributeType, nameOrId, type }) => ({
                nameOrId,
                type,
                attributeType,
                values: this._refinementMap.has(id)
                    ? Array.from(this._refinementMap.get(id))
                    : []
            })
        );

        this.dispatchEvent(
            new CustomEvent('facetvalueupdate', {
                bubbles: true,
                composed: true,
                detail: { refinements }
            })
        );
    }

    handleSectionToggle(event) {
        this._sections = event.detail.openSections;
    }

    connectedCallback(){
        loadStyle(this, Fonts);
        loadStyle(this, BoldFonts);
        loadStyle(this, Colors);
    }

     _displayval=[];
    _displayData;
    _facets = [];
    _mruFacet;
    _refinementMap = new Map();
    _sections;
}