({
  doInit: function(component, event, helper) {
    var filteredList = component.get("v.filteredProductList");
    component.set("v.finalProductList", filteredList);
  },
  handleRemoveLine: function(component, event, helper) {
    console.log("CPQB_QuickSelectRowController | handleRemoveLine");
    // Fire a remove event to handle in parent cmp to splice the array
    var idx = component.get("v.index");
    var deleteEvent = component.getEvent("deleteRow");
    deleteEvent
      .setParams({
        removeRow: idx
      })
      .fire();
  },

  handleUpdateList: function(component, event, helper) {
    console.log("ProductList Updated");
    var existingProductId = component.get("v.productCode");
    console.log("existing product ID =", existingProductId);
    var pMap = component.get("v.productMap");
    var filteredMap = component.get("v.filteredProductMap");
    var filteredList = component.get("v.filteredProductList");
    if (!filteredMap[existingProductId] && existingProductId) {
      console.log("value not in filteredMap");
      var pName = pMap[existingProductId];
      filteredList.unshift({ Name: pName, Id: existingProductId });
    } else {
      console.log("value in filteredMap");
    }
    component.set("v.finalProductList", filteredList);
  }
});