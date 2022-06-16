/**
 * Created by scheck on 2019-05-08.
 */
({
  handleConsumptionSchedules: function(component, event, helper) {
    console.log("CPQB_ConsumptionUploaderHelper | handleConsumptionSchedules");
    var action = component.get("c.getOIConsumptionSchedules");
    action.setParams({
      orderId: component.get("v.recordId")
    });

    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var map = response.getReturnValue();
        console.log(map);
        component.set("v.oItemsConsumptionMap", map);
      } else {
        console.debug(response.error[0].message);
      }
    });

    $A.enqueueAction(action);
  },

  validateUsageHelper: function(component, event, helper) {
    var toastEvent = $A.get("e.force:showToast");
    var usageRecord = component.get("v.usageRecord");
    //Validation
    if (
      $A.util.isEmpty(usageRecord.blng__StartDateTime__c) ||
      $A.util.isUndefined(usageRecord.blng__StartDateTime__c)
    ) {
      toastEvent
        .setParams({
          title: "Error Creating Usage",
          message: "Start Date is Required",
          type: "error"
        })
        .fire();
      return false;
    }
    if (
      $A.util.isEmpty(usageRecord.blng__EndDateTime__c) ||
      $A.util.isUndefined(usageRecord.blng__EndDateTime__c)
    ) {
      toastEvent
        .setParams({
          title: "Error Creating Usage",
          message: "End Date is Required",
          type: "error"
        })
        .fire();
      return false;
    }
    if (
      $A.util.isEmpty(usageRecord.blng__Quantity__c) ||
      $A.util.isUndefined(usageRecord.blng__Quantity__c)
    ) {
      toastEvent
        .setParams({
          title: "Error Creating Usage",
          message: "Quantity is Required",
          type: "error"
        })
        .fire();
      return false;
    }
    if (
      $A.util.isEmpty(usageRecord.blng__MatchingId__c) ||
      $A.util.isUndefined(usageRecord.blng__MatchingId__c)
    ) {
      toastEvent
        .setParams({
          title: "Error Creating Usage",
          message: "Order Product (Matching ID) is Required",
          type: "error"
        })
        .fire();
      return false;
    }
    return true;
  },

  handleOrderItems: function(component, event, helper) {
    console.log("CPQB_ConsumptionUploaderHelper | handleOrderItems");
    let action = component.get("c.getUsageOrderItems");
    action.setParams({
      orderId: component.get("v.recordId")
    });

    action.setCallback(this, function(response) {
      let state = response.getState();
      let data = response.getReturnValue();
      console.log("Usage OrderItems: ", data);
      if (state === "SUCCESS") {
        component.set("v.orderItems", data);
      }
    });
    $A.enqueueAction(action);
  },

  setConsumptionMap: function(component, orderItemNumber) {
    console.log("CPQB_ConsumptionUploaderHelper | setConsumptionMap");

    var consumpMap = component.get("v.oItemsConsumptionMap");
    console.log("Consumption Map: ", consumpMap);
    console.log("Order Product Number: ", orderItemNumber);

    var mapUOMtoAttrs = null;
    if (consumpMap.hasOwnProperty(orderItemNumber)) {
      mapUOMtoAttrs = consumpMap[orderItemNumber];
      console.log("Consumption Schedule to Attributes: ", mapUOMtoAttrs);
    }
    if (mapUOMtoAttrs) {
      component.set("v.consumption", mapUOMtoAttrs);
      component.set("v.hasConsumption", true);
      component.set("v.usageRecord.blng__MatchingAttribute__c", null);
      component.set("v.usageRecord.blng__UnitOfMeasure__c", null);
    } else {
      component.set("v.hasConsumption", false);
      component.set("v.usageRecord.blng__MatchingAttribute__c", null);
      component.set("v.usageRecord.blng__UnitOfMeasure__c", null);
    }
  },

  handleInitUsageRecord: function(component, event, helper) {
    console.log("CPQB_ConsumptionUploaderHelper | handleInitUsageRecord");
    component.set("v.hasConsumption", false);

    var dt = new Date();

    var futureDays = component.get("v.daysInFuture");
    if (futureDays) {
      dt.setDate(dt.getDate() + futureDays);
    }
    var today = dt.toISOString();

    var defaultQty = component.get("v.defaultQuantity");
    var newUsage = component.get("v.usageRecord");

    newUsage.blng__StartDateTime__c = today;
    newUsage.blng__EndDateTime__c = today;
    newUsage.blng__Quantity__c = defaultQty ? defaultQty : null;
    newUsage.blng__MatchingId__c = "";
    newUsage.blng__UnitOfMeasure__c = "";
    newUsage.blng__MatchingAttribute__c = "";
    console.log("New Usage: ", newUsage);

    //resetting the Values in the form
    component.set("v.usageRecord", newUsage);
  }
});