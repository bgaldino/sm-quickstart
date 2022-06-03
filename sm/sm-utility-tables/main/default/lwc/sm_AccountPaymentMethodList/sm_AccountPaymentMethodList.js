import getAccountCardPayments from "@salesforce/apex/SM_AccountPaymentMethodListController.getAccountCardPayments";
import { LightningElement, api, wire } from "lwc";

const columns = [
  {
    label: "Nickname",
    fieldName: "Link",
    type: "url",
    typeAttributes: { label: { fieldName: "NickName" } }
  },
  {
    label: "Status",
    fieldName: "Status",
    type: "text"
  },
  {
    label: "Last Four",
    fieldName: "CardLastFour",
    type: "text"
  },
  {
    label: "Card Type",
    fieldName: "CardType",
    type: "text"
  },
    {
    label: "Gateway",
    fieldName: "GatewayLink",
    type: "url",
    typeAttributes: { label: { fieldName: "PaymentGatewayName" } }
  },
];

export default class Sm_AccountPaymentMethodList extends LightningElement {
    @api
  recordId;

  data = [];
  error = null;
  @wire(getAccountCardPayments, { accountId: "$recordId" })
  cards({ error, data }) {
    if (data) {
      let tempList = [];

      data.forEach((record) => {
        console.log(record);
        let tempRec = { ...record };
        tempRec.Link = `/${record.Id}`;
        tempRec.PaymentGatewayName = record.PaymentGateway.PaymentGatewayName;
        tempRec.GatewayLink = `/${record.PaymentGatewayId}`;

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