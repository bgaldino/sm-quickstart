import { LightningElement } from "lwc";
import getAllAssets from "@salesforce/apex/SM_MyAssetsController.getAllAssetsForCurrentUser";

export default class Sb_myAssets extends LightningElement {
  assets = [];
  hasAssets = false;

  connectedCallback() {
    this.getAssets();
  }
  getAssets() {
    getAllAssets({})
      .then((result) => {
        this.assets = result;
        this.hasAssets = true;
        console.log("Assets are:", this.assets);
      })
      .catch((error) => console.error("Error when loading the assets", error));
  }
}
