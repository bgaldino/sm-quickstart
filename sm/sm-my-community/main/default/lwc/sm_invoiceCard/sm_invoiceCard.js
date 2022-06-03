import { LightningElement, api, track } from "lwc";
import createPayment from "@salesforce/apex/SM_PaymentController.createPayment";
import applyPayment from "@salesforce/apex/SM_PaymentController.applyPayment";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
export default class Sm_invoiceCard extends LightningElement {
  isLoading = false;
  useNewCard = false;
  selectedCardId = "";
  card = {};
  isValidCard = false;
  @api paymentGatewayId;
  @api paymentCards;
  @track _invoice;
  @api
  get invoice() {
    return this._invoice;
  }
  set invoice(aValue) {
    this._invoice = JSON.parse(JSON.stringify(aValue));
  }

  activeSections = ["lines"];

  cardCompleteChangeHandler(event) {
    this.card = event.detail;
    this.isValidCard = true;
    console.log(JSON.stringify(this.card));
  }

  cardIncompleteChangeHandler(event) {
    this.card = event.detail;
    this.isValidCard = false;
  }

  async payInvoiceHandler() {
    try {
      this.isLoading = true;
      window.console.log(
        "paymentCard",
        JSON.stringify(this.card),
        "invoice",
        JSON.stringify(this._invoice),
        "paymentMethodId",
        this.selectedCardId,
        "newCard",
        this.useNewCard
      );
      let paymentMethodId = this.selectedCardId;
      let paymentId = await createPayment({
        amount: this._invoice.totalAmount,
        paymentMethodId: paymentMethodId,
        paymentGatewayId: this.paymentGatewayId
      });
      //  if (this.useNewCard) {
      //   paymentId = await createPayement({
      //     paymentCard: this.card.value,
      //     invoice: this._invoice,
      //     paymentMethodId: this.selectedCardId,
      //     newCard: this.useNewCard
      //   });
      //      }

      console.log(paymentId);
      console.log(paymentMethodId);
      console.log(this._invoice);
      // Apply payment to invoice
      const paymentLineId = await applyPayment({
        paymentId: paymentId,
        invoiceId: this._invoice.id,
        amount: this._invoice.totalAmount
      });
      console.log(paymentLineId);
      // update invoice amount to mark as paid
      this._invoice.netPaymentsApplied = this._invoice.totalAmount;
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Payment successful",
          message: "Thank you for your payment",
          variant: "success",
          mode: "dismissible"
        })
      );

      this.closePayPopupHandler();
    } catch (error) {
      console.error("Error While Paying the invoice", error);
    } finally {
      this.isLoading = false;
    }
  }

  selectCardHandler(event) {
    this.selectedCardId = event.target.value;
    console.log(this.selectedCardId);
  }

  useNewCardHandler() {
    this.useNewCard = !this.useNewCard;
    this.selectedCardId = "";
    this.isValidCard = false;
  }
  openPayPopupHandler() {
    const menu = this.template.querySelector(".js-pay-pop");
    menu.open();
  }

  closePayPopupHandler() {
    const menu = this.template.querySelector(".js-pay-pop");
    menu.close();
  }

  get invoiceTitle() {
    return (
      "Invoice #" +
      this._invoice.documentNumber.substring(
        this._invoice.documentNumber.length - 3
      )
    );
  }

  get isOverdue() {
    return this.overdueDays > 0 && this._invoice.balance > 0;
  }
  get overdueDays() {
    let dueDate = new Date(this._invoice.dueDate);

    // To calculate the no. of days between two dates
    return Math.ceil((Date.now() - dueDate.getTime()) / (1000 * 3600 * 24));
  }
  get overdueLabel() {
    return `Overdue by ${this.overdueDays} days`;
  }

  get isPayed() {
    return this._invoice.balance === 0;
  }

  get disablePay() {
    return !this.isValidCard && !this.selectedCardId;
  }
}
