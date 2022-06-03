import { LightningElement, track, api } from "lwc";

export default class Sm_checkoutDetails extends LightningElement {
  @api
  paymentCards = [];

  @track isValidCard = false;

  @track
  address = {
    street: "",
    city: "",
    country: "",
    province: "",
    postalCode: ""
  };
  @track
  card = {
    type: "",
    value: {
      cardNumber: "",
      cardHolderName: "",
      cardCVV: "",
      cardExpiry: "",
      cardType: ""
    }
  };
  @track
  useNewCard = false;

  @track
  selectedCardId = null;

  useNewCardHandler() {
    this.useNewCard = !this.useNewCard;
    this.selectedCardId = null;
    this.isValidCard = false;
    this.dispatchValidityEvent(this.isValid());
  }

  selectCardHandler(event) {
    this.selectedCardId = event.target.value;
    this.dispatchValidityEvent(this.isValid());
  }

  cardCompleteChangeHandler(event) {
    this.card = { ...event.detail };
    this.isValidCard = true;
    this.dispatchValidityEvent(this.isValid());
  }

  cardIncompleteChangeHandler(event) {
    this.card = { ...event.detail };
    this.isValidCard = false;
    this.dispatchValidityEvent(this.isValid());
  }

  handleAddressChange(event) {
    // this.address = { ...event.target };
    this.address.street = event.target.street;
    this.address.city = event.target.city;
    this.address.country = event.target.country;
    this.address.province = event.target.province;
    this.address.postalCode = event.target.postalCode;
    // console.log(this.address);
    this.dispatchValidityEvent(this.isValid());
  }

  dispatchValidityEvent(e) {
    window.console.log("dispatchValid");
    window.console.log(e);
    // window.console.log("address", JSON.parse(JSON.stringify(this.address)));
    // window.console.log("card", JSON.parse(JSON.stringify(this.card)));
    // window.console.log(
    //   "useNewCard",
    //   JSON.parse(JSON.stringify(this.useNewCard))
    // );
    // window.console.log(
    //   "selectedCardId",
    //   JSON.parse(JSON.stringify(this.selectedCardId))
    // );
    // this.dispatchEvent(new CustomEvent("checkoutvalid", e));
    if (e) {
      console.log("dispatching checkout details");
      this.dispatchEvent(
        new CustomEvent("checkoutdetails", {
          detail: {
            card: this.card,
            address: this.address,
            useNewCard: this.useNewCard,
            selectedCardId: this.selectedCardId
          }
        })
      );
    }
  }

  @api
  isValid() {
    return (
      this.template.querySelector(".address-input").checkValidity() &&
      (this.isValidCard === true || this.selectedCardId !== null)
    );
  }
}
