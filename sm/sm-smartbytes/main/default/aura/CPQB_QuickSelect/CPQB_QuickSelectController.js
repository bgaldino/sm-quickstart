({
  doInit: function(component, event, helper) {
    console.log("CPQB_QuickSelectController | doInit");
    helper.getProductFamilyPicklist(component, event, helper);
    helper.getProductsHelper(component, event, helper);
    helper.createNewLineHelper(component, event, helper);
  },

  handleAddLine: function(component, event, helper) {
    console.log("CPQB_QuickSelectController | handleAddLine");
    var width = component.get("v.width");
    console.log("Current Width: ", width);
    helper.createNewLineHelper(component, event, helper);
  },

  handleQuoteGen: function(component, event, helper) {
    console.log("CPQB_QuickSelectController | handleQuoteGen");
    helper.genQuoteHelper(component, event, helper);
  },

  handleRemoveRow: function(component, event, helper) {
    console.log("CPQB_QuickSelectController | handleRemoveRow");
    var listProds = component.get("v.productLines");
    var index = event.getParam("removeRow");
    console.log("Removing: ");
    console.log(listProds[index]);
    listProds.splice(index, 1);
    component.set("v.productLines", listProds);
  },

  handleProductMap: function(component, event, helper) {
    console.log("CPQB_QuickSelectController | handleProductMap");
    helper.buildProductMap(component);
  },

  handleFilter: function(component, event, helper) {
    console.log("CPQB_QuickSelectController | handleFilter");
    var selectedFamily = component.get("v.productFamily");
    var unfilteredList = component.get("v.productList");
    var selectedCurrency = component.get("v.opptyCurrency");
    var unfilteredCurrencyList = component.get("v.opportunityCurrencies");
      
    if (!selectedFamily) {
      component.set("v.filteredProductList", unfilteredList);
      return;
    }
    var filteredList = [];
    for (var i = 0; i < unfilteredList.length; i++) {
      if (unfilteredList[i].Family == selectedFamily) {
        filteredList.push(unfilteredList[i]);
      }
    }
    component.set("v.filteredProductList", filteredList);
  }
});