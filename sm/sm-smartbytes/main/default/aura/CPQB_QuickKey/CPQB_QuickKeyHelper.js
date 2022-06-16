({
  getAllProductCodesHelper: function(component, event, helper) {
    console.log("CPQB_QuickKeyHelper | getAllProductCodesHelper");
    var action = component.get("c.initProdCodes");

    action.setCallback(this, function(response) {
      var state = response.getState();
      console.log(response.getReturnValue());

      if (state === "SUCCESS") {
        console.log("Success, product codes retrieved!");
        component.set("v.allCodes", response.getReturnValue());
      } else {
        console.log("Error! Product Codes not retrieved");
      }
    });
    $A.enqueueAction(action);
  },

  createNewLineHelper: function(component, event, helper) {
    console.log("CPQB_QuickKeyHelper | createNewLineHelper");
    var pcs = component.get("v.productMetas");
    pcs.push({ code: "", quant: 1 });
    console.log(pcs);
    component.set("v.productMetas", pcs);
  },

  addProductHelper: function(component, event, helper) {
    console.log("CPQB_QuickKeyHelper | addProductHelper");
    var urlEvent = $A.get("e.force:navigateToURL");
    var toastEvent = $A.get("e.force:showToast");

    component.set("v.showSpinner", true);

    var action = component.get("c.addProduct");
    var models = component.get("v.productMetas");

    action.setParams({
      recordId: component.get("v.recordId"),
      models: JSON.stringify(models),
      startDate: component.get("v.startDate"),
      subTerm: component.get("v.subscriptionTerm")
    });

    action.setCallback(this, function(response) {
      var state = response.getState();

      if (state === "SUCCESS") {
        console.log("Success");

        setTimeout(function() {
          component.set("v.showSpinner", false);
        }, 500);

        toastEvent
          .setParams({
            title: "Quick Key Success",
            message: "Products added, navigating to the quote!",
            type: "success"
          })
          .fire();

        urlEvent.setParams({
          url:
            "/apex/sbqq__sb?scontrolCaching=1&id=" + response.getReturnValue()
        }).fire();

      } else {
          
        console.log("Error in Quick Key");
        toastEvent
        .setParams({
          title: "Quick Key Error",
          message: "Error adding Products",
          type: "error"
        })
        .fire();
        setTimeout(function() {
          component.set("v.showSpinner", false);
        }, 1500);
      }
    });

    $A.enqueueAction(action);
  }
});