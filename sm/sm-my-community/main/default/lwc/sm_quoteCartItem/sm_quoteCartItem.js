import { LightningElement, track, api } from "lwc";

export default class Sm_quoteCartItem extends LightningElement {
  @track _product;

  @api
  get product() {
    return this._product;
  }
  set product(aValue) {
    this._product = JSON.parse(JSON.stringify(aValue));
  }

  @api
  get discount() {
    return this._product.discount / 100;
  }

  @api
  get hasDiscount() {
    return this._product.discount > 0;
  }
}
