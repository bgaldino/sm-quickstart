import { LightningElement, api } from "lwc";

export default class Sm_invoiceCardLines extends LightningElement {
  @api
  invoiceLines = [];

  @api
  currencyIsoCode;
}
