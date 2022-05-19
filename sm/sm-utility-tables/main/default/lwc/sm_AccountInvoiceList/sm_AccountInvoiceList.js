import getAccountInvoices from "@salesforce/apex/SM_AccountInvoiceListController.getAccountInvoices";
import { LightningElement, api, wire } from "lwc";

const columns = [
  {
    label: "Document Number",
    fieldName: "Link",
    type: "url",
    typeAttributes: { label: { fieldName: "DocumentNumber" } }
  },
  {
    label: "Total Amount",
    fieldName: "TotalAmount",
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
    label: "Reference Record",
    fieldName: "PrimaryRecLink",
    type: "url",
    typeAttributes: {
      label: { fieldName: "PrimaryRecName" }
    }
  },
  {
    label: "Created Date",
    fieldName: "CreatedDate",
    type: "date"
  }
];

export default class Sm_AccountInvoiceList extends LightningElement {
  @api
  recordId;

  data = [];
  error = null;
  @wire(getAccountInvoices, { accountId: "$recordId" })
  invs({ error, data }) {
    if (data) {
      let tempList = [];

      data.forEach((record) => {
        console.log(record);
        let tempRec = { ...record };
        tempRec.Link = `/${tempRec.Id}`;

        tempRec.PrimaryRecLink = `/${tempRec?.ReferenceEntityId}` || "";
        tempRec.PrimaryRecName = record?.ReferenceEntity?.Name || "";

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

//    Id,
//      DocumentNumber,
//      BillingAccountId,
//      CreatedDate,
//      Balance,
//      TotalAmount,
//      ReferenceEntityId,
//      ReferenceEntity.Name;
