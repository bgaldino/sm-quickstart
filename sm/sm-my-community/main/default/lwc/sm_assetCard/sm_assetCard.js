import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
export default class Sm_assetCard extends LightningElement {
  @api
  asset;

  get isActive() {
    return this.asset.lifecycleEndDate == null;
  }

  get isOneTime() {
    return this.asset.lifecycleEndDate == null && this.asset.currentMrr === 0;
  }
  get isOngoingEvergreen() {
    return this.asset.lifecycleEndDate == null && this.asset.currentMrr !== 0;
  }
  get isOngoingTerm() {
    return this.asset.lifecycleEndDate != null && this.asset.currentMrr !== 0;
  }

  get subscriptionTerm() {
    if (this.asset.lifecycleEndDate && this.asset.lifecycleStartDate) {
      let startDate = new Date(this.asset.lifecycleStartDate);
      let endDate = new Date(this.asset.lifecycleEndDate);

      // To calculate the no. of days between two dates
      return this.monthDiff(startDate, endDate);
    }
    return null;
  }

  monthDiff(d1, d2) {
    let months;
    months = (d2.getFullYear() - d1.getFullYear()) * 12;
    months -= d1.getMonth();
    months += d2.getMonth();
    return months <= 0 ? 0 : months;
  }

  handleMenuSelect(event) {
    console.log(JSON.parse(JSON.stringify(event.detail)));
    const actionName = event.detail.value;
    switch (actionName) {
      case "cancel":
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Cancellation Request Received",
            message: "",
            variant: "success",
            mode: "dismissible"
          })
        );
        break;
      default:
    }
  }
}
