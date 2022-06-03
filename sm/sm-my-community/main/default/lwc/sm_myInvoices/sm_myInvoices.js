import { LightningElement } from "lwc";

import getAllInvoicesForCurrentUser from "@salesforce/apex/SM_MyInvoicesController.getAllInvoicesForCurrentUser";
import getPaymentMethodsForCurrentUser from "@salesforce/apex/SM_PaymentMethodController.getPaymentMethodsForCurrentUser";

export default class Sm_myInvoices extends LightningElement {
  invoices = [];
  unPaidInvoices = [];
  paidInvoices = [];
  paymentCards = [];
  connectedCallback() {
    this.getInvoices();
    this.getPaymentMethodsForCurrentUser();
  }
  getInvoices() {
    window.console.log("fetching Invoices");
    getAllInvoicesForCurrentUser()
      .then((result) => {
        window.console.log(result);
        this.invoices = [...result];
        this.paidInvoices = this.invoices.filter((i) => i.isPayed);
        this.unPaidInvoices = this.invoices.filter((i) => !i.isPayed);
      })
      .catch((error) =>
        console.error("Error when loading the invoices", error)
      );
  }

  getPaymentMethodsForCurrentUser() {
    getPaymentMethodsForCurrentUser({})
      .then((result) => {
        window.console.log(result);
        this.paymentCards = result;
      })
      .catch((error) =>
        console.error("Error when loading the payment cards", error)
      );
  }
}
