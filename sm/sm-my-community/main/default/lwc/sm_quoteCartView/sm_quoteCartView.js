import { LightningElement, api, wire, track } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";

import getAllCartItemsByQuoteId from "@salesforce/apex/SM_QuoteCartViewController.getAllCartItemsByQuoteId";
import convertQuoteToOrder from "@salesforce/apex/SM_CommunityCheckoutController.convertQuoteToOrder";

import getPaymentMethodsForCurrentUser from "@salesforce/apex/SM_PaymentMethodController.getPaymentMethodsForCurrentUser";
import buyNowFromDraftOrder from "@salesforce/apex/SM_BuyNowFromOrder.buyNowFromDraftOrder";

export default class Sm_quoteCartView extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  @api gatewayId;

  cartItems = [];
  // no edit access

  @track cartTotal = 0;
  connectedCallback() {
    this.getPaymentMethodsForCurrentUser();
  }

  paymentCards = [];
  @track selectedCardId = null;

  currentPageReference = null;
  urlStateParameters = null;
  isLoading = true;

  selectCardHandler(event) {
    this.selectedCardId = event.target.value;
    console.log(this.selectedCardId);
  }

  get canBuyNow() {
    return this.selectedCardId == null;
  }

  getPaymentMethodsForCurrentUser() {
    getPaymentMethodsForCurrentUser({})
      .then((result) => {
        this.paymentCards = result;
      })
      .catch((error) =>
        console.error("Error when loading the payment cards", error)
      );
  }

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      this.urlStateParameters = currentPageReference.state;
      window.console.log(this.urlStateParameters);
      this.setParametersBasedOnUrl();
    }
  }

  setParametersBasedOnUrl() {
    this.recordId = this.recordId
      ? this.recordId
      : this.urlStateParameters.c__ID;
    console.log("recordId ", this.recordId);
    this.getCartItems();
  }

  getCartItems() {
    console.log("recId", this.recordId);
    getAllCartItemsByQuoteId({ quoteId: this.recordId })
      .then((data) => {
        this.cartItems = JSON.parse(JSON.stringify(data));
        this.getCartTotal();
        this.isLoading = false;
      })
      .catch((error) => {
        console.error("Error when loading the cart", error);
        this.isLoading = false;
      });
  }

  getCartTotal() {
    if (this.cartItems.length > 0) {
      this.cartTotal = this.cartItems
        .map((ci) => ci.totalPrice)
        .reduce((previousValue, currentValue) => previousValue + currentValue);
    }
  }

  // Dummy to send toast event
  handleDiscountRequest() {
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Submitted Request",
        message: "A Sales Rep will be in touch",
        variant: "success",
        mode: "dismissible"
      })
    );
  }

  async handleBuyNowFromQuote() {
    this.isLoading = true;
    // convert the quote & quotelines to order and order products
    let orderId = await convertQuoteToOrder({ quoteId: this.recordId });
    window.console.log(
      "orderId: ",
      orderId,
      "paymentId: ",
      this.selectedCardId,
      "gatewayId: ",
      this.gatewayId
    );

    buyNowFromDraftOrder({
      orderId: orderId,
      paymentMethodId: this.selectedCardId,
      gatewayId: this.gatewayId
    });
    // wait event to let buyNow flow run
    await new Promise((resolve) => setTimeout(resolve, 4000));
    this.isLoading = false;

    this.dispatchEvent(
      new ShowToastEvent({
        title: "Success",
        message: "Thank you for your order",
        variant: "success",
        mode: "dismissible"
      })
    );
    const pageRef = {
      type: "comm__namedPage",
      attributes: {
        name: "My_Orders__c"
      }
    };
    this[NavigationMixin.Navigate](pageRef);
  }
}
