/**
 * Created by scheck on 2019-05-08.
 */
({
  init: function(component, event, helper) {
    console.log("CPQB_ConsumptionUploaderController | init");

    helper.handleInitUsageRecord(component, event, helper);
    helper.handleConsumptionSchedules(component, event, helper);
    helper.handleOrderItems(component, event, helper);
  },

  create: function(component, event, helper) {
    console.log("CPQB_ConsumptionUploaderController | create");
    var toastEvent = $A.get("e.force:showToast");

    //getting the candidate information
    var usageRecord = component.get("v.usageRecord");
    usageRecord.blng__EndDateTime__c = usageRecord.blng__StartDateTime__c;
    console.log(
      "--- Usage Record to be Created: ",
      JSON.stringify(usageRecord)
    );

    var isValid = helper.validateUsageHelper(component, event, helper);
    if (!isValid) {
      console.log("Invalid Usage Record");
      return;
    }

    component.set("v.showSpinner", true);

    var action = component.get("c.createRecord");
    action.setParams({
      usageRecord: usageRecord
    });

    //Setting the Callback
    action.setCallback(this, function(response) {
      //get the response state
      var state = response.getState();

      //check if result is successful
      if (state == "SUCCESS") {
        setTimeout(function() {
          component.set("v.showSpinner", false);
        }, 500);

        toastEvent
          .setParams({
            title: "Success",
            message: "Usage created!",
            type: "success"
          })
          .fire();

        helper.handleInitUsageRecord(component, event, helper);
        // Fire Refresh event
        $A.get("e.force:refreshView").fire();
      } else {
        console.error(response);
        var errors = response.getError();
        var message = "Unknown error"; // Default error message
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
          title: "Error Creating Usage",
          message: message,
          type: "error"
        });
        toastEvent.fire();
      }
    });

    //adds the server-side action to the queue
    $A.enqueueAction(action);
  },

  updateOrderProduct: function(component, event, helper) {
    console.log("CPQB_ConsumptionUploaderController | updateOrderProduct");
    let newUsage = component.get("v.usageRecord");
    newUsage.blng__MatchingId__c = component
      .find("orderProduct")
      .get("v.value");

    helper.setConsumptionMap(
      component,
      component.find("orderProduct").get("v.value")
    );
    console.log("Matching Id: ", newUsage.blng__MatchingId__c);
    component.set("v.usageRecord", newUsage);
  },

  updateConsumption: function(component, event, helper) {
    console.log("CPQB_ConsumptionUploaderController | updateConsumption");
    var matchAttrUOM = component.get("v.matchAttrUOM");
    console.log("Matching Attribute and UOM:", matchAttrUOM);
    var newUsage = component.get("v.usageRecord");

    var UOM = matchAttrUOM.split("---")[0];
    var matchingAttr = matchAttrUOM.split("---")[1];
    console.log("UOM: ", UOM);
    console.log("Matching Attribute: ", matchingAttr);

    newUsage.blng__UnitOfMeasure__c = UOM;
    newUsage.blng__MatchingAttribute__c = matchingAttr;
    console.log("Unit of Measure: ", newUsage.blng__UnitOfMeasure__c);
    console.log("Matching Attribute: ", newUsage.blng__MatchingAttribute__c);
    component.set("v.usageRecord", newUsage);
  }
});