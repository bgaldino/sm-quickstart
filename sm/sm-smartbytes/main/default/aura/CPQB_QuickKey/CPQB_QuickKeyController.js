({
  doInit: function(component, event, helper) {
    console.log("CPQB_QuickKeyController | doInit");
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
    helper.getAllProductCodesHelper(component, event, helper);
    helper.createNewLineHelper(component, event, helper);
  },

  handleAddLine: function(component, event, helper) {
    console.log("CPQB_QuickKeyController | handleAddLine");
    helper.createNewLineHelper(component, event, helper);
  },

  handleProdCode: function(component, event, helper) {
    console.log("CPQB_QuickKeyController | handleProdCode");
    helper.addProductHelper(component, event, helper);
  },

  handleRemoveRow: function(component, event, helper) {
    console.log("CPQB_QuickKeyController | handleRemoveRow");
    var listProds = component.get("v.productMetas");
    var index = event.getParam("removeRow");
    console.log("Removing: ");
    console.log(listProds[index]);
    listProds.splice(index, 1);
    component.set("v.productMetas", listProds);
  }
});