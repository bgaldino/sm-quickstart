import { LightningElement, api } from 'lwc';
import getOrderSummary from '@salesforce/apex/RSM_CartController.getOrderSummary';
const CART_CHANGED_EVT = 'cartchanged';
export default class B2b_orderConfirmationHeader extends LightningElement {
    @api recordId;
    

    categPath = [{"id":"0ZG8Z000000GsRzWAK","name":"Order Confirmation"}];
    get path() {
        return {
            journey: this.categPath.map(
            (category) => ({
                name: category.name
            })
        )
    };
    }
    
    orderNumber

    connectedCallback(){
        this.getOrder();
        this.dispatchEvent(
            new CustomEvent(CART_CHANGED_EVT, {
                bubbles: true,
                composed: true
            })
        );
    }

    getOrder(){
        getOrderSummary({
            orderSummaryId: this.recordId
        })
            .then((orderSummary) => {
                this.orderNumber = orderSummary.OrderNumber;
            })
            .catch((e) => {
                console.log(e);
            });
    }

}