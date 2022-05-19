import { LightningElement, api, track } from "lwc";

import updatePricing from "@salesforce/apex/SM_ProductCatalogController.updatePricing";
export default class Sm_productCatalogCard extends LightningElement {
  @track _product;
  isLoading = false;

  @api
  get product() {
    return this._product;
  }
  set product(aValue) {
    this._product = JSON.parse(JSON.stringify(aValue));
  }

  get sellingModelType() {
    return this._product.options.find(
      (o) => o.value === this._product.productSellingModelId
    ).label;
  }

  get hasOneSellingModel() {
    return this._product.options.length === 1;
  }

  get pricingTermLabel() {
    if (this.sellingModelType.startsWith("Term")) {
      return "Per Month For 12 Months";
    }
    if (this.sellingModelType.startsWith("Evergreen")) {
      return "Per Month";
    }
    if (this.sellingModelType.startsWith("One")) {
      return "Single payment";
    }
    return null;
  }

  get pricingSelectDisabled() {
    return this._product.options.length === 1;
  }

  handleSelectionChange(event) {
    this.product.isSelected = event.target.checked;
    this.changeProduct();
  }

  handleSellingModelChange(event) {
    window.console.log(event.target.value);
    this._product.productSellingModelId = event.target.value;
    this.updatePricing();
  }

  handleQuantityChange(event) {
    this._product.quantity = event.target.value;
    if (this._product.quantity > 0) {
      this.updatePricing();
    }
  }

  async updatePricing() {
    try {
      this.isLoading = true;
      window.console.log("Before Pricing Update");
      window.console.log(this._product);
      this._product = await updatePricing({ productWrapper: this._product });
      window.console.log("After Pricing Update");
      window.console.log(this._product);
      this.changeProduct();
    } catch (error) {
      console.error("error while update pricing", error);
    } finally {
      this.isLoading = false;
    }
  }

  changeProduct() {
    this.dispatchEvent(
      new CustomEvent("changeproduct", {
        detail: this._product
      })
    );
  }
}
