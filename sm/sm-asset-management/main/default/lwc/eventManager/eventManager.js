import { LightningElement, api } from 'lwc';
import { subscribe, unsubscribe}  from 'lightning/empApi';
import currentUserId from '@salesforce/user/Id';

export default class EventManager extends LightningElement {

    cancelSubscription = {};
    renewSubscription = {};
    amendSubscription = {};
     @api cancelChannel = '/event/AssetCancelInitiatedEvent';
     @api renewChannel = '/event/AssetRenewInitiatedEvent';
     @api amendChannel = '/event/AssetAmendInitiatedEvent';

    // Initializes the component
    connectedCallback() {
        // Register listener
        this.handleRenewSubscribe();
        this.handleCancelSubscribe();
        this.handleAmendSubscribe();
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
                
                thisReference.dispatchEvent(new CustomEvent('custevent', { detail: obj }));
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
                
                thisReference.dispatchEvent(new CustomEvent('custevent', { detail: obj }));
            }
            // Response contains the payload of the new message received
        };

        subscribe(this.renewChannel, -1, messageCallback).then(response => {
            // Response contains the subscription information on renew call
            this.renewSubscription = response;
        });
    }

    handleAmendSubscribe = () => {
        // Callback invoked whenever a new event message is received
        const thisReference = this;
        const messageCallback = function(response) {
            let obj = JSON.parse(JSON.stringify(response));
            
            if(currentUserId === obj.data.payload.CreatedById){ //dispatch the users events instead of all 

                thisReference.dispatchEvent(new CustomEvent('custevent', { detail: obj }));
            }
            // Response contains the payload of the new message received
        };

        subscribe(this.amendChannel, -1, messageCallback).then(response => {
            // Response contains the subscription information on renew call
            this.amendSubscription = response;
        });
    }
    
    unsubscribeEvents() {
        unsubscribe(this.renewSubscription);
        unsubscribe(this.cancelSubscription);
        unsubscribe(this.amendSubscription);
        this.cancelSubscription = null;
        this.renewSubscription = null;
        this.amendSubscription = null;
    }
}