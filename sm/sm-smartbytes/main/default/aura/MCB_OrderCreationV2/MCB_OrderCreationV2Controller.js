({
  doInit: function(component, event, helper) {
    console.log("CPQB_MCBController | doInit");
    var pbId = component.get("v.pricebookId");
    console.log("Pricebook Id: ", pbId);
    // Set Start Date to today
    var date = new Date();
    component.set(
      "v.startDate",
      `${date.getFullYear()}-${(date.getMonth() + 1)
        .toString()
        .padStart(2, "0")}-${date
        .getDate()
        .toString()
        .padStart(2, "0")}` 
    );
    //Set Status to Draft
    component.set(
      "v.status",
      'Draft'
    );
    //Set PO Number to ""
    component.set(
      "v.poNumber",
      ''
    );
    //Set Description to "Enter description here."
    component.set(
      "v.description",
      ''
    );
    helper.getAllProductCodesHelper(component, event, helper);
    helper.createNewLineHelper(component, event, helper);
  },

  handleAddLine: function(component, event, helper) {
    console.log("CPQB_MCBController | handleAddLine");
    helper.createNewLineHelper(component, event, helper);
  },

  handleProdCode: function(component, event, helper) {
    console.log("CPQB_MCBController | handleProdCode");
    helper.addProductHelper(component, event, helper);
  },

  handleOpenNewWindowWithRecordId : function(component, event, helper) {
    console.log("CPQB_MCBController | handleOpenNewWindowWithRecordId");
    helper.navigateToList(component, event, helper);
  },

  handleRemoveRow: function(component, event, helper) {
    console.log("CPQB_MCBController | handleRemoveRow");
    var listProds = component.get("v.productMetas");
    var index = event.getParam("removeRow");
    console.log("Removing: ");
    console.log(listProds[index]);
    listProds.splice(index, 1);
    component.set("v.productMetas", listProds);
  }
});