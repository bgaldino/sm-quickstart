import { LightningElement, api} from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import Colors from '@salesforce/resourceUrl/B2B_Colors';
import Fonts from '@salesforce/resourceUrl/B2B_Fonts';
import BoldFonts from '@salesforce/resourceUrl/B2B_Fonts_Bold';

export default class B2b_searchPaginator extends LightningElement {
    @api pageNumber;

    @api pageSize;

    @api totalItemCount;

    handlePrevious() {
        this.dispatchEvent(new CustomEvent('previous'));
    }

    handleNext() {
        this.dispatchEvent(new CustomEvent('next'));
    }

    get currentPageNumber() {
        return this.totalItemCount === 0 ? 0 : this.pageNumber;
    }

    get isFirstPage() {
        return this.pageNumber === 1;
    }

    get isLastPage() {
        return this.pageNumber >= this.totalPages;
    }

    get totalPages() {
        return Math.ceil(this.totalItemCount / this.pageSize);
    }
    connectedCallback(){
        loadStyle( this, Fonts);
        loadStyle(this, BoldFonts);
        loadStyle(this, Colors);
    }
}