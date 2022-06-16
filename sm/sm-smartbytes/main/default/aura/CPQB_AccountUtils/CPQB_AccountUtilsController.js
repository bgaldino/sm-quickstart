({
  handleReset: function(component, event, helper) {
    // Get the values from the form
    var recordId = component.get("v.recordId");
    var delCPs = component.get("v.deleteCPs");
    var toastEvent = $A.get("e.force:showToast");

    component.set("v.showSpinner", true);
    //Calling the Apex Function
    var action = component.get("c.resetAccount");

    //Setting the Apex Parameter
    action.setParams({
      accId: recordId,
      deleteCP: delCPs
    });

    //Setting the Callback
    action.setCallback(this, function(a) {
      //get the response state
      var state = a.getState();

      //check if result is successful
      if (state == "SUCCESS") {
        setTimeout(function() {
          component.set("v.showSpinner", false);
        }, 500);

        toastEvent.setParams({
          title: "Success",
          message: "Account Reset",
          type: "success"
        });
        toastEvent.fire();

        // Fire Refresh event
        $A.get("e.force:refreshView").fire();
        // Close the action panel
        $A.get("e.force:closeQuickAction").fire();
      } else if (state == "ERROR") {
        let errors = response.getError();
        let message = "Unknown error"; // Default error message
        // Retrieve the error message sent by the server
        if (errors && Array.isArray(errors) && errors.length > 0) {
          message = errors[0].message;
        }
        // Display the message
        console.error(message);

        setTimeout(function() {
          component.set("v.showSpinner", false);
        }, 1000);

        toastEvent.setParams({
          title: "Error Refreshing Account",
          message: message,
          type: "error"
        });
        toastEvent.fire();
      }
    });

    //adds the server-side action to the queue
    $A.enqueueAction(action);
  },
  handleQuoteReset: function(component, event, helper) {
    // Get the values from the form
    var recordId = component.get("v.recordId");
    var delCPs = component.get("v.deleteCPs");
    var toastEvent = $A.get("e.force:showToast");
    var urlEvent = $A.get("e.force:navigateToURL");

    component.set("v.showSpinner", true);
    //Calling the Apex Function
    var action = component.get("c.resetAccountAndQuote");

    //Setting the Apex Parameter
    action.setParams({
      accId: recordId,
      deleteCP: delCPs
    });

    //Setting the Callback
    action.setCallback(this, function(a) {
      //get the response state
      var state = a.getState();

      //check if result is successful
      if (state == "SUCCESS") {
        setTimeout(function() {
          component.set("v.showSpinner", false);
        }, 500);

        toastEvent.setParams({
          title: "Success",
          message: "Account Reset and Quick Quote",
          type: "success"
        });
        toastEvent.fire();

        urlEvent
          .setParams({
            url: "/apex/sbqq__sb?scontrolCaching=1&id=" + a.getReturnValue()
          })
          .fire();
      } else if (state == "ERROR") {
        let errors = a.getError();
        let message = "Unknown error"; // Default error message
        // Retrieve the error message sent by the server
        if (errors && Array.isArray(errors) && errors.length > 0) {
          message = errors[0].message;
        }
        // Display the message
        console.error(message);

        setTimeout(function() {
          component.set("v.showSpinner", false);
        }, 1000);

        toastEvent.setParams({
          title: "Error Refreshing Account",
          message: message,
          type: "error"
        });
        toastEvent.fire();
      }
    });

    //adds the server-side action to the queue
    $A.enqueueAction(action);
  },
  handleBillingReset: function(component, event, helper) {
    // Get the values from the form
    var recordId = component.get("v.recordId");
    var delCPs = component.get("v.deleteCPs");
    var toastEvent = $A.get("e.force:showToast");
    var urlEvent = $A.get("e.force:navigateToURL");

    component.set("v.showSpinner", true);
    //Calling the Apex Function
    var action = component.get("c.resetBillingAccount");

    //Setting the Apex Parameter
    action.setParams({
      accId: recordId,
      deleteCP: delCPs
    });

    //Setting the Callback
    action.setCallback(this, function(a) {
      //get the response state
      var state = a.getState();

      //check if result is successful
      if (state == "SUCCESS") {
        setTimeout(function() {
          component.set("v.showSpinner", false);
        }, 500);

        toastEvent.setParams({
          title: "Success",
          message: "Account Reset for Billing",
          type: "success"
        });
        toastEvent.fire();

        // Fire Refresh event
        $A.get("e.force:refreshView").fire();
        // Close the action panel
        $A.get("e.force:closeQuickAction").fire();
          
      } else if (state == "ERROR") {
        let errors = a.getError();
        let message = "Unknown error"; // Default error message
        // Retrieve the error message sent by the server
        if (errors && Array.isArray(errors) && errors.length > 0) {
          message = errors[0].message;
        }
        // Display the message
        console.error(message);

        setTimeout(function() {
          component.set("v.showSpinner", false);
        }, 1000);

        toastEvent.setParams({
          title: "Error Refreshing Account",
          message: message,
          type: "error"
        });
        toastEvent.fire();
      }
    });

    //adds the server-side action to the queue
    $A.enqueueAction(action);
  }
});