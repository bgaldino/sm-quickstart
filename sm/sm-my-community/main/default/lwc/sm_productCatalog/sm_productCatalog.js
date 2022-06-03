import { LightningElement, track, api } from "lwc";

// Apex Controller
import getActiveProducts from "@salesforce/apex/SM_ProductCatalogController.getActiveProducts";

export default class Sm_productCatalog extends LightningElement {
  @track
  products = [];

  @api
  pricebookId = null;

  isLoading = true;

  connectedCallback() {
    this.getActiveProducts();
  }

  getActiveProducts() {
    if (!this.pricebookId) return;
    getActiveProducts({ pricebookId: this.pricebookId })
      .then((data) => {
        this.products = JSON.parse(JSON.stringify(data));
        this.isLoading = false;
      })
      .catch((error) => {
        console.error("Error when loading the products", error);
        this.isLoading = false;
      });
  }

  handleChangeproduct(event) {
    this.products.splice(event.detail.id, 1);
    this.products.splice(event.detail.id, 0, event.detail);
    const selectedProducts = this.products.filter((p) => p.isSelected);

    const changeEvent = new CustomEvent("productsselected", {
      detail: selectedProducts
    });
    this.dispatchEvent(changeEvent);
  }
}
