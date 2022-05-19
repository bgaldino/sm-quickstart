import { LightningElement } from "lwc";

import getAllOrdersForCurrentUser from "@salesforce/apex/SM_MyOrdersController.getAllOrdersForCurrentUser";
export default class Sm_myOrders extends LightningElement {
  orders = [];

  connectedCallback() {
    this.getOrders();
  }
  getOrders() {
    getAllOrdersForCurrentUser({})
      .then((result) => {
        this.orders = [...result];
        console.log(result);
      })
      .catch((error) => console.error("Error when loading the orders", error));
  }
}
