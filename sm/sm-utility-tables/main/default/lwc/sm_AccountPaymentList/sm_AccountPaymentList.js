import getAccountPayments from "@salesforce/apex/SM_AccountPaymentListController.getAccountPayments";
import { LightningElement, api, wire } from "lwc";

const columns = [
  {
    label: "Payment Number",
    fieldName: "Link",
    type: "url",
    typeAttributes: { label: { fieldName: "PaymentNumber" } }
  },
  {
    label: "Total Applied",
    fieldName: "TotalApplied",
    type: "currency",
    typeAttributes: { currencyCode: "USD", currencyDisplayAs: "code" }
  },
  {
    label: "Total Unapplied",
    fieldName: "TotalUnapplied",
    type: "currency",
    typeAttributes: { currencyCode: "USD", currencyDisplayAs: "code" }
  },
  {
    label: "Net Applied",
    fieldName: "NetApplied",
    type: "currency",
    typeAttributes: { currencyCode: "USD", currencyDisplayAs: "code" }
  },
  {
    label: "Balance",
    fieldName: "Balance",
    type: "currency",
    typeAttributes: { currencyCode: "USD", currencyDisplayAs: "code" }
  },

  {
    label: "Created Date",
    fieldName: "CreatedDate",
    type: "date"
  }
];
export default class Sm_AccountPaymentList extends LightningElement {
  @api
  recordId;

  data = [];
  error = null;
  @wire(getAccountPayments, { accountId: "$recordId" })
  invs({ error, data }) {
    if (data) {
      let tempList = [];

      data.forEach((record) => {
        console.log(record);
        let tempRec = { ...record };
        tempRec.Link = `/${tempRec.Id}`;
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
