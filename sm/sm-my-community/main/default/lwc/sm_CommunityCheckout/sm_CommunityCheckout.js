import { api, LightningElement, track, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";

// load user data and payment methods
import getCurrentUserInfo from "@salesforce/apex/SM_CommunityCheckoutController.getCurrentUserInfo";
import getPaymentMethodsForCurrentUser from "@salesforce/apex/SM_PaymentMethodController.getPaymentMethodsForCurrentUser";

// methods for buy now
import placeOrder from "@salesforce/apex/SM_CommunityCheckoutController.placeOrder";
import placeQuote from "@salesforce/apex/SM_CommunityCheckoutController.placeQuote";
import convertQuoteToOrder from "@salesforce/apex/SM_CommunityCheckoutController.convertQuoteToOrder";
import buyNowFromDraftOrder from "@salesforce/apex/SM_BuyNowFromOrder.buyNowFromDraftOrder";
import createNewPaymentMethod from "@salesforce/apex/SM_PaymentMethodController.createNewPaymentMethod";

// https://salesforce.stackexchange.com/questions/289584/the-better-way-to-import-cometd-library-into-lwc
// CometD as static resource to listen for platform events
import { loadScript } from "lightning/platformResourceLoader";
import cometdlwc from "@salesforce/resourceUrl/sm_cometd";
import getSessionId from "@salesforce/apex/SM_CommunityCheckoutController.getSessionId";

export default class Sm_CommunityCheckout extends NavigationMixin(
  LightningElement
) {
  // config, set in builder
  @api pricebookId = null;
  @api gatewayId = null;

  @track selectedProducts = [];
  @track paymentCards = [];

  @track quoteId = null;
  @track orderId = null;

  // general app info
  @track user = {};
  @track isLoading = false;
  @track currentStage = 1;
  @track cantCheckout = true;

  // Payments
  @track selectedPaymentMethodId = null;
  @track card = {};
  @track address = {};
  @track useNewCard = false;

  // CometD and events
  @api eventChannel = "/event/BuyNowComplete__e";
  cometdlib;
  eventSub;
  libInitialized = false;
  @track sessionId;
  @track error;
  startTime; // timing requests

  @wire(getSessionId)
  wiredSessionId({ error, data }) {
    if (data) {
      this.sessionId = data;
      this.error = undefined;
      loadScript(this, cometdlwc).then(() => {
        this.initializecometd();
      });
    } else if (error) {
      console.log(error);
      this.error = error;
      this.sessionId = undefined;
    }
  }

  connectedCallback() {
    getCurrentUserInfo()
      .then((res) => (this.user = { ...res }))
      .catch((e) => console.error("Error when loading current user info", e));

    getPaymentMethodsForCurrentUser()
      .then((result) => {
        this.paymentCards = [...result];
      })
      .catch((e) => console.error("Error when loading the payment cards", e));
  }

  disconnectedCallback() {
    console.log("disconnectedCallback");
    if (this.eventSub && this.cometdlib) {
      const res = this.cometdlib.unsubscribe(this.eventSub);
      console.log(res);
      console.log("Cleaned up event sub");
    }
  }

  initializecometd() {
    if (this.libInitialized) {
      return;
    }

    this.libInitialized = true;

    //inintializing cometD object/class
    this.cometdlib = new window.org.cometd.CometD();

    //Calling configure method of cometD class, to setup authentication which will be used in handshaking
    this.cometdlib.configure({
      url: `${window.location.protocol}//${window.location.hostname}/cometd/53.0/`,
      requestHeaders: { Authorization: `OAuth ${this.sessionId}` },
      appendMessageTypeToURL: false,
      logLevel: "debug"
    });

    this.cometdlib.websocketEnabled = false;

    this.cometdlib.handshake((status) => {
      if (status.successful) {
        // Successfully connected to the server.
        // Now it is possible to subscribe or send messages
        console.log("Successfully connected to server with cometd");
        if (this.eventChannel) {
          this.eventSub = this.cometdlib.subscribe(
            this.eventChannel,
            this.handleMessage
          );
          console.log(`Subscribed to ${this.eventChannel}`);
        }
      } else {
        /// Cannot handshake with the server, alert user.
        console.error("Error in handshaking: " + JSON.stringify(status));
      }
    });
  }

  handleMessage = (message) => {
    // log messages
    // message.data.payload.Invoice_Id__c
    // message.data.payload.Original_Order_Id__c

    const requestTime = new Date().getTime() - this.startTime;
    console.log(`Buy Now in: ${requestTime} ms`);
    console.log("Got event message!", JSON.parse(JSON.stringify(message)));
    this.isLoading = false;
    this.navigateOnFinish();
  };

  navigateOnFinish() {
    const pageRef = {
      type: "comm__namedPage",
      attributes: {
        name: "My_Orders__c"
      }
    };

    this[NavigationMixin.Navigate](pageRef);
  }

  handleProductSelect(event) {
    this.selectedProducts = [...event.detail];
  }

  async handlePaymentMethod() {
    this.isLoading = true;
    const buyNow = await buyNowFromDraftOrder({
      orderId: this.orderId,
      paymentMethodId: this.selectedPaymentMethodId,
      gatewayId: this.gatewayId
    });
    console.log(buyNow);
    // failsafe to stop loading
    await new Promise((resolve) => setTimeout(resolve, 7000));
    this.isLoading = false;
  }

  async handlePlaceOrder() {
    this.isLoading = true;
    console.log("Placing Order");
    const orderId = await placeOrder({
      products: this.selectedProducts,
      address: this.user.address,
      pricebookId: this.pricebookId
    });
    console.log(orderId);
    this.orderId = orderId;
    this.isLoading = false;
    this.currentStage = 3;
  }

  async handleAddToCart() {
    this.isLoading = true;
    console.log("Adding to cart");
    const quoteId = await placeQuote({
      products: this.selectedProducts,
      address: this.user.address,
      pricebookId: this.pricebookId
    });
    console.log(quoteId);
    this.quoteId = quoteId;
    this.isLoading = false;
    this.currentStage = 2;
  }

  async handleBuyNowFromCart() {
    this.isLoading = true;
    this.startTime = new Date().getTime();
    const orderId = await convertQuoteToOrder({ quoteId: this.quoteId });
    console.log(orderId);
    this.orderId = orderId;
    const res = await buyNowFromDraftOrder({
      orderId: orderId,
      paymentMethodId: this.selectedPaymentMethodId,
      gatewayId: this.gatewayId
    });
    console.log(JSON.parse(JSON.stringify(res)));
    // failsafe to stop loading
    await new Promise((resolve) => setTimeout(resolve, 7000));
    this.isLoading = false;
  }

  handleValidCheckout(e) {
    this.cantCheckout = !e;
  }

  handleCheckoutDetails(e) {
    this.cantCheckout = false;
    this.selectedPaymentMethodId = e.detail.selectedCardId;
    this.card = e.detail.card.value;
    this.useNewCard = e.detail.useNewCard;
    this.address = e.detail.address;
  }

  async handleCheckout() {
    this.isLoading = true;
    this.startTime = new Date().getTime();

    if (this.useNewCard) {
      this.selectedPaymentMethodId = await createNewPaymentMethod({
        paymentCard: this.card,
        paymentGatewayId: this.gatewayId
      });
    }

    const res = await buyNowFromDraftOrder({
      orderId: this.orderId,
      paymentMethodId: this.selectedPaymentMethodId,
      gatewayId: this.gatewayId
    });
    console.log(JSON.parse(JSON.stringify(res)));
    // failsafe to stop loading
    await new Promise((resolve) => setTimeout(resolve, 7000));
    this.isLoading = false;
  }

  get buyDisabled() {
    return this.selectedProducts.length === 0;
  }

  get showCatalog() {
    return this.currentStage === 1;
  }

  get showCart() {
    return this.currentStage === 2;
  }

  get showCheckout() {
    return this.currentStage === 3;
  }
}
