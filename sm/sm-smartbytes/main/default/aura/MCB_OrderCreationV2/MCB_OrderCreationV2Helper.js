({
  getAllProductCodesHelper: function(component, event, helper) {
    console.log("CPQB_MCBHelper | getAllProductCodesHelper");
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
    console.log("CPQB_MCBHelper | createNewLineHelper");
    var pcs = component.get("v.productMetas");
    pcs.push({ code: "", quant: 1, charge: "Recurring", freq: "Monthly", type: "Advance", price: 0 });
    console.log(pcs);
    component.set("v.productMetas", pcs);
  },

  addProductHelper: function(component, event, helper) {
    console.log("CPQB_MCBHelper | addProductHelper"); 
    //var urlEvent = $A.get("e.force:navigateToURL");
    var navEvent = $A.get("e.force:navigateToSObject");    
    var toastEvent = $A.get("e.force:showToast");

    component.set("v.showSpinner", true);

    var action = component.get("c.addProduct");
    var models = component.get("v.productMetas");
    console.log("startDate: " + component.get("v.startDate"));

    action.setParams({
      recordId: component.get("v.recordId"),
      startDate: component.get("v.startDate"),
      //startDate: '2021-16-12',
      status: component.get("v.status"),
      poNumber: component.get("v.poNumber"),
      description: component.get("v.description"),
      models: JSON.stringify(models)
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
            message: "Products added, navigating to the order!",
            type: "success"
          })
          .fire();

        // urlEvent.setParams({
        //   url:
        //     response.getReturnValue()
        // }).fire();
          navEvent.setParams({
            "recordId": response.getReturnValue()
          }).fire();

      } else {
          
        console.log("Error in Quick Key Order");
        toastEvent
        .setParams({
          title: "Error in Quick Key Order",
          message: "Error adding Products to Order",
          type: "error"
        })
        .fire();
        setTimeout(function() {
          component.set("v.showSpinner", false);
        }, 1500);
      }
    });

    $A.enqueueAction(action);
  },

  navigateToList: function (component, event, helper) {
    console.log("CPQB_MCBHelper | navigateToList"); 
    var baseURL = window.location.hostname;
    console.log("baseURL: " + baseURL); 
    //baseURL = 'https://' + baseURL + component.get("c.getListViews");
    //console.log("baseURL updated: " + baseURL);
    //window.open(baseURL,'_blank');
    ////window.open('https://smartbytes.lightning.force.com/lightning/o/Product2/list?filterName=' + component.get("c.getListViews"),'_blank');
    window.open('https://' + baseURL + '/lightning/o/Product2/list?filterName=' + '00B3c000009xlDmEAI','_blank');
  }

});