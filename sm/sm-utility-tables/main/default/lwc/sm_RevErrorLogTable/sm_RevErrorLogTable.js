import { LightningElement, wire } from "lwc";
import getErrorLogs from "@salesforce/apex/SM_RevErrorLogTableController.getErrorLogs";

const columns = [
  {
    label: "Name",
    fieldName: "Link",
    type: "url",
    typeAttributes: { label: { fieldName: "ErrorLogNumber" }, target: "_blank" }
  },
  {
    label: "Error Code",
    fieldName: "ErrorCode",
    type: "text"
  },
  {
    label: "Error Message",
    fieldName: "ErrorMessage",
    type: "text"
  },
  {
    label: "Primary Record",
    fieldName: "PrimaryRecLink",
    type: "url",
    typeAttributes: {
      label: { fieldName: "PrimaryRecName" },
      target: "_blank"
    }
  },
  {
    label: "Created Date",
    fieldName: "CreatedDate",
    type: "date"
  }
];

export default class Sm_RevErrorLogTable extends LightningElement {
  logs = [];
  error = null;
  @wire(getErrorLogs)
  errorLogs({ error, data }) {
    if (data) {
      let tempList = [];

      data.forEach((record) => {
        let tempRec = { ...record };
        tempRec.Link = `/${tempRec.Id}`;
        tempRec.PrimaryRecLink = `/${tempRec.PrimaryRecordId}`;
        tempRec.PrimaryRecName = record.PrimaryRecord.Name;
        tempList.push(tempRec);
      });

      this.logs = [...tempList];
      this.error = undefined;
    } else if (error) {
      this.error = error;
    }
  }
  columns = columns;
}
