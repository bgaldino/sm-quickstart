import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import getPaymentMethodsForCurrentUser from "@salesforce/apex/SM_PaymentMethodController.getPaymentMethodsForCurrentUser";
import makePayment from "@salesforce/apex/SM_PaymentTerminalController.makePayment";
import applyPayment from "@salesforce/apex/SM_PaymentController.applyPayment";

export default class Sm_paymentTerminal extends LightningElement {
  @api currencyIsoCode; // set in config
  @api gatewayId; // set in config
  @api invoiceId = null; // can be passed in if using a parent component
  @api invoiceAmount = null; //
  @track paymentCards = [];
  @track isValidCard = false;
  @track useNewCard = false;
  @track selectedCardId = null;
  @track amount = 0;
  @track isLoading = false;

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

  connectedCallback() {
    getPaymentMethodsForCurrentUser()
      .then((result) => {
        this.paymentCards = [...result];
      })
      .catch((e) => console.error("Error when loading the payment cards", e));
  }

  handleAmountChange(e) {
    this.amount = e.target.value;
  }

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
    this.card = { ...event.detail.value };
    this.isValidCard = true;
    this.dispatchValidityEvent(this.isValid());
  }

  cardIncompleteChangeHandler(event) {
    this.card = { ...event.detail.value };
    this.isValidCard = false;
    this.dispatchValidityEvent(this.isValid());
  }

  handleAddressChange(event) {
    this.address.street = event.target.street;
    this.address.city = event.target.city;
    this.address.country = event.target.country;
    this.address.province = event.target.province;
    this.address.postalCode = event.target.postalCode;
    this.dispatchValidityEvent(this.isValid());
  }

  async handleMakePayment() {
    this.isLoading = true;
    try {
      const paymentId = await makePayment({
        paymentCard: this.card,
        newCard: this.useNewCard,
        amount: this.amount,
        currencyIsoCode: this.currencyIsoCode,
        paymentMethodId: this.selectedCardId,
        gatewayId: this.gatewayId
      });
      // If we have an Invoice Id, apply the payment
      if (this.invoiceId) {
        const res = await applyPayment({
          paymentId,
          invoiceId: this.invoiceId,
          amount: this.amount
        });
      }
      this.isLoading = false;
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Thank you for your Payment",
          message: `Payment of ${this.amount} ${this.currencyIsoCode} has been made`,
          variant: "success",
          mode: "dismissible"
        })
      );
    } catch (error) {
      this.isLoading = false;
      window.console.log(error);
    }
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
      console.log("dispatching payment details");
      this.dispatchEvent(
        new CustomEvent("paymentdetails", {
          detail: {
            card: this.card,
            address: this.address,
            useNewCard: this.useNewCard,
            selectedCardId: this.selectedCardId,
            amount: this.amount
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
  // get paymentDisabled() {
  //   return !this.isValid();
  // }
}
