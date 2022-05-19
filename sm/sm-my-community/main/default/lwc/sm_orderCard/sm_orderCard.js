import { LightningElement, api } from "lwc";

export default class Sm_orderCard extends LightningElement {
  @api
  order;

  activeSections = ["lines"];

  get orderTitle() {
    return (
      "Order #" +
      this.order.orderNumber.substring(this.order.orderNumber.length - 3)
    );
  }
}
