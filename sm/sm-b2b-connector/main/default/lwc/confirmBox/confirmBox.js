import { LightningElement, api} from 'lwc';
import iconsImg from '@salesforce/resourceUrl/smb2b_img';
import LOCALE from '@salesforce/i18n/locale';

export default class ConfirmBox extends LightningElement {

   minus = `${iconsImg}#minus`;
    plus = `${iconsImg}#plus`;

  @api
  nextbillingdate;
  modalText;
  _isRenewal;
  @api
  enddate;

  @api
  totalqty;

  @api
  productname;
  @api
  startdate;

  @api
  isamendadd;

  @api
  isamendsub;

  @api
  isamend;

    @api 
    get isrenewal(){

      console.log(this.isrenewal, 'is renewal____');
      return this.modalText;
     
    }

      prodQuanity = 1;

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

    addQty(){
       
        this.prodQuanity = this.prodQuanity + 1;

    }

     subQuanity(){
     
            if(this.prodQuanity > 1){
                this.prodQuanity = this.prodQuanity - 1;

            }
       
    }

    handleOnlyNaturalkeyup(e) {
        if(e.target.value.length==1) {
            e.target.value=e.target.value.replace(/[^1-9]/g,'')
        } else {
            e.target.value=e.target.value.replace(/\D/g,'')
        }
        this.handleQuantityChange(e);
    }

        handleQuantityChange(event) {
        if (event.target.value) {
            this.prodQuanity = event.target.value;
          
        }
    }

    handleAmend(){
      console.log('1');
      if(this.isamendadd == true){
        console.log('2');
         let data = {changeQuantity: this.prodQuanity, isAdd: true};
          console.log('3');
         const selectedEvent = new CustomEvent("handleamend", {
            detail: data
            });
          this.dispatchEvent(selectedEvent);
          console.log('3');

        }else{

          let data = {changeQuantity: this.prodQuanity, isAdd: false};
          const selectedEvent = new CustomEvent("handleamend", {
            detail: data
            });
          this.dispatchEvent(selectedEvent);

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