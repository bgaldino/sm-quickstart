import { LightningElement, api} from 'lwc';
import LOCALE from '@salesforce/i18n/locale';

export default class ConfirmBox extends LightningElement {

  @api
  nextbillingdate;
  modalText;
  _isRenewal;
  @api
  enddate;

  @api
  productname;
  @api
  startdate;


    @api 
    get isrenewal(){

      console.log(this.isrenewal, 'is renewal____');
      return this.modalText;
     
    }

    set isrenewal(value) {
      console.log(this.enddate, this.nextbillingdate, 'date____')
      if(value === true){
        this._isRenewal = true;
        this.modalText = 'The Renewal will be effective from ' + this.startdate + ' To ' + this.enddate + '. Do you want to Renew the Subscription ?';
      }else{
        this._isRenewal = false;
        this.modalText = 'Your Subscription for ' + this.productname + ' will be cancelled effective from ' + this.nextbillingdate + '.';

      }
   }



    closeModal() {

    const selectedEvent = new CustomEvent("closemodal", {

        detail: false

      });
  
      this.dispatchEvent(selectedEvent);
    }
    submitDetails() {
      console.log('renewal___');
      if(this._isRenewal === false){
        const selectedEvent = new CustomEvent("cancelasset", {
            detail: false
            });
          this.dispatchEvent(selectedEvent);

      }else{

        const selectedEvent = new CustomEvent("renewasset", {
          detail: false
          });

        this.dispatchEvent(selectedEvent);
        
      }
    }
    
}