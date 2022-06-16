({
  getProductsHelper: function(component, event, helper) {
    console.log("CPQB_QuickSelectHelper | getProductsHelper");
    var action = component.get("c.initializeProducts");
    var toastEvent = $A.get("e.force:showToast");
    component.set("v.showSpinner", true);
    action.setCallback(this, function(response) {
      var state = response.getState();
      var productModelList = response.getReturnValue();
      console.log(productModelList);

      if (state === "SUCCESS") {
        console.log("Success, Product List retrieved!");
        component.set("v.productList", productModelList);
        component.set("v.filteredProductList", productModelList);
        component.set("v.showSpinner", false);
      } else if (state === "ERROR") {
        var errors = response.getError();
        component.set("v.showSpinner", false);
        this.handleErrors(errors);
      } else {
        console.log("Error! Product List not retrieved");
        toastEvent.setParams({
          title: "Quick Quote Error",
          message: "Error loading Product list",
          type: "error"
        });
        toastEvent.fire();
        component.set("v.showSpinner", false);
      }
    });
    $A.enqueueAction(action);
  },

  createNewLineHelper: function(component, event, helper) {
    console.log("CPQB_QuickSelectHelper | createNewLineHelper");
    var pcs = component.get("v.productLines");
    pcs.push({ code: "", quant: 1 });
    console.log(pcs);
    component.set("v.productLines", pcs);
  },

  genQuoteHelper: function(component, event, helper) {
    console.log("CPQB_QuickSelectHelper | genQuoteHelper");
    var urlEvent = $A.get("e.force:navigateToURL");
    var toastEvent = $A.get("e.force:showToast");

    component.set("v.showSpinner", true);

    var action = component.get("c.addProduct");
    var models = component.get("v.productLines");
    var toastTitle = component.get("v.successMessage")
      ? component.get("v.successMessage")
      : "Success";
    console.log("Toast Title", toastTitle);
    var navToQuote = component.get("v.navToQuote");
    console.log("Stay on record", navToQuote);

    action.setParams({
      recordId: component.get("v.recordId"),
      models: JSON.stringify(models),
      subTerm: component.get("v.subscriptionTerm")
    });

    action.setCallback(this, function(response) {
      var state = response.getState();

      if (state === "SUCCESS") {
        console.log("Success");

        setTimeout(function() {
          component.set("v.showSpinner", false);
        }, 500);

        toastEvent.setParams({
          title: toastTitle,
          type: "success",
          message: "This is a required message",
          messageTemplate: "New {0} was created.",
          messageTemplateData: [
            {
              url: "/" + response.getReturnValue(),
              label: "Quote"
            }
          ]
        });
        toastEvent.fire();

        if (navToQuote) {
          return;
        } else {
          urlEvent
            .setParams({
              url:
                "/apex/sbqq__sb?scontrolCaching=1&id=" +
                response.getReturnValue()
            })
            .fire();
        }
      } else if (state === "ERROR") {
        var errors = response.getError();
        component.set("v.showSpinner", false);
        this.handleErrors(errors);
      } else {
        console.log("Error in Quick Quote");
        toastEvent.setParams({
          title: "Quick Quote Error",
          type: "error"
        });
        toastEvent.fire();
        setTimeout(function() {
          component.set("v.showSpinner", false);
        }, 1500);
      }
    });

    $A.enqueueAction(action);
  },
  getProductFamilyPicklist: function(component, event, helper) {
    console.log("CPQB_QuickSelectHelper | getProductFamilyPicklist");
    var action = component.get("c.getPickListValuesIntoList");
    action.setParams({
      objectType: "Product2",
      selectedField: "Family"
    });
    component.set("v.showSpinner", true);
    action.setCallback(this, function(response) {
      var state = response.getState();
      console.log(response.getReturnValue());

      if (state === "SUCCESS") {
        console.log("Success, Product List retrieved!");
        component.set("v.productFamilyList", response.getReturnValue());
        component.set("v.showSpinner", false);
      } else if (state === "ERROR") {
        var errors = response.getError();
        component.set("v.showSpinner", false);
        this.handleErrors(errors);
      } else {
        console.log("Error! Product List not retrieved");
        component.set("v.showSpinner", false);
      }
    });
    $A.enqueueAction(action);
  },
  buildProductMap: function(component) {
    console.log("CPQB_QuickSelectHelper | buildProductMap");
    var pList = component.get("v.productList");
    var pMap = {};
    for (var i = 0; i < pList.length; i++) {
      pMap[pList[i].Id] = pList[i].Name;
    }
    console.log(pMap);
    component.set("v.productMap", pMap);
  },
  handleErrors: function(errors) {
    // Configure error toast
    let toastParams = {
      title: "Error",
      mode: "sticky",
      message: "Unknown error", // Default error message
      type: "error"
    };
    // Pass the error message if any
    if (errors && Array.isArray(errors) && errors.length > 0) {
      toastParams.message = errors[0].message;
    }
    // Fire error toast
    let toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams(toastParams);
    toastEvent.fire();
  }
});