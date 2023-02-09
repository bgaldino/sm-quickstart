import getAccountInvoices from "@salesforce/apex/SM_AccountInvoiceListController.getAccountInvoices";
import { LightningElement, api, wire, track } from "lwc";

const columns = [
  {
    label: "Document Number",
    fieldName: "Link",
    type: "url",
    sortable: true,
    typeAttributes: { label: { fieldName: "DocumentNumber" } }
  },
  {
    label: "Total Amount",
    fieldName: "TotalAmount",
    type: "currency",
    sortable: true,
    typeAttributes: { currencyCode: "USD", currencyDisplayAs: "code" }
  },
  {
    label: "Balance",
    fieldName: "Balance",
    type: "currency",
    sortable: true,
    typeAttributes: { currencyCode: "USD", currencyDisplayAs: "code" }
  },
  {
    label: "Settled Date",
    fieldName: "FullSettlementDate",
    type: "date",
    sortable: true
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
    type: "date",
    sortable: true
  }
];

export default class Sm_AccountInvoiceList extends LightningElement {
  @api
  recordId;

  @track data = [];
  @track columns = columns;
  @track sortBy;
  @track sortDirection;

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

  doSorting(event) {
    this.sortBy = event.detail.fieldName;
    this.sortDirection = event.detail.sortDirection;
    this.sortData(this.sortBy, this.sortDirection);
  }

  sortData(fieldname, direction) {
    let parseData = JSON.parse(JSON.stringify(this.data));
    // Return the value stored in the field
    let keyValue = (a) => {
      return a[fieldname];
    };
    // cheking reverse direction
    let isReverse = direction === "asc" ? 1 : -1;
    // sorting data
    parseData.sort((x, y) => {
      x = keyValue(x) ? keyValue(x) : ""; // handling null values
      y = keyValue(y) ? keyValue(y) : "";
      // sorting values based on direction
      return isReverse * ((x > y) - (y > x));
    });
    this.data = parseData;
  }
  //columns = columns;
}

//    Id,
//      DocumentNumber,
//      BillingAccountId,
//      CreatedDate,
//      Balance,
//      TotalAmount,
//      ReferenceEntityId,
//      ReferenceEntity.Name;
