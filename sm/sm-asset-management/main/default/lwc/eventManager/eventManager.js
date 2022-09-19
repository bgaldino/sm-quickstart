import { LightningElement, api, wire } from 'lwc';
import { subscribe, unsubscribe}  from 'lightning/empApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import currentUserId from '@salesforce/user/Id';
import { CurrentPageReference } from 'lightning/navigation';

export default class EventManager extends LightningElement {

    cancelSubscription = {};
    renewSubscription = {};
     @api cancelChannel = '/event/AssetCancelInitiatedEvent';
     @api renewChannel = '/event/AssetRenewInitiatedEvent';

    // Initializes the component
    connectedCallback() {
        // Register listener
        this.handleRenewSubscribe();
        this.handleCancelSubscribe();
    }

    disconnectedCallback() {
        this.unsubscribeEvents();
    }

    handleCancelSubscribe = () =>{
        // Callback invoked whenever a new event message is received
        const thisReference = this;
        const messageCallback = function(response) {
            let obj = JSON.parse(JSON.stringify(response));
            if(currentUserId === obj.data.payload.CreatedById){ //dispatch the users events instead of all events
                let message = 'Order created: ' + obj.data.payload.CancellationRecordId;

                let variant = 'success'
                if (obj.data.payload.AssetCancelErrorDetailEvents != null) {
                    message = 'Couldn’t cancel the asset: ' + obj.data.payload.AssetCancelErrorDetailEvents[0].ErrorMessage;
                    variant = 'error'
                }
                const evt = new ShowToastEvent({
                    message: message,
                    variant: variant,
                    mode : "sticky"
                });

                thisReference.dispatchEvent(evt);
            }
            // Response contains the payload of the new message received
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.cancelChannel, -1, messageCallback).then(response => {
            // Response contains the subscription information on cancel call
            this.cancelSubscription = response;
        });

    }

    
    handleRenewSubscribe = () => {
        // Callback invoked whenever a new event message is received
        const thisReference = this;
        const messageCallback = function(response) {
            let obj = JSON.parse(JSON.stringify(response));
            
            if(currentUserId === obj.data.payload.CreatedById){ //dispatch the users events instead of all events

                let message = 'Order created: ' + obj.data.payload.RenewalRecordId;
                let variant = 'success'
                if (obj.data.payload.AssetRenewErrorDetailEvents != null) {
                    message = 'Couldn’t renew the asset: ' + obj.data.payload.AssetRenewErrorDetailEvents[0].ErrorMessage;
                    variant = 'error'
                }
                const evt = new ShowToastEvent({
                    message: message,
                    variant: variant,
                    mode : "sticky"
                });

                thisReference.dispatchEvent(evt);
            }
            // Response contains the payload of the new message received
        };

        subscribe(this.renewChannel, -1, messageCallback).then(response => {
            // Response contains the subscription information on renew call
            this.renewSubscription = response;
        });
    }
    
    unsubscribeEvents() {
        unsubscribe(this.renewSubscription);
        unsubscribe(this.cancelSubscription);
        this.cancelSubscription = null;
        this.renewSubscription = null;
    }
}