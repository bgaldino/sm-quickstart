import getBillingSchedules from "@salesforce/apex/SM_AssetBillingScheduleListController.getBillingSchedules";
import { LightningElement, api, wire } from "lwc";

const columns = [
  {
    label: "Billing Schedule",
    fieldName: "Link",
    type: "url",
    typeAttributes: { label: { fieldName: "name" } }
  },
  {
    label: "Order",
    fieldName: "RefEntityLink",
    type: "url",
    typeAttributes: { label: { fieldName: "refEntityName" } }
  },
  {
    label: "Order Product",
    fieldName: "RefEntityItemLink",
    type: "url",
    typeAttributes: { label: { fieldName: "refEntityItemName" } }
  },
  {
    label: "Total Amount",
    fieldName: "totalAmount",
    type: "currency",
    typeAttributes: { currencyCode: "USD", currencyDisplayAs: "code" }
  },
  {
    label: "Start Date",
    fieldName: "startDate",
    type: "date"
  },
  {
    label: "End Date",
    fieldName: "endDate",
    type: "date"
  }
];
export default class Sm_AssetBillingScheduleList extends LightningElement {
  @api
  recordId;

  data = [];
  error = null;
  @wire(getBillingSchedules, { assetId: "$recordId" })
  bs({ error, data }) {
    if (data) {
      let tempList = [];

      data.forEach((record) => {
        console.log(record);
        let tempRec = { ...record };
        tempRec.Link = `/${tempRec.id}`;
        tempRec.RefEntityLink = `/${tempRec.refEntityId}`;
        tempRec.RefEntityItemLink = `/${tempRec.refEntityItemId}`;
        tempList.push(tempRec);
      });
      console.table(tempList);
      this.data = [...tempList];
      this.error = undefined;
      console.log("Finished");
    } else if (error) {
      this.error = JSON.stringify(error);
    }
  }
  columns = columns;
}
