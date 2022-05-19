({
  onInit: function (cmp, event, helper) {
    cmp.set("v.isLoading", true);
    var action = cmp.get("c.getAssetCancellationEffectiveDate");
    action.setParams({ assetId: cmp.get("v.recordId") });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log("** parsing response");
        console.log("****", response.getReturnValue());
        if (response.getReturnValue()) {
          cmp.set("v.cancelDate", response.getReturnValue());
        } else {
          var message = "error";
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "error",
            mode: "sticky",
            title: "Error",
            message: message
          });
          toastEvent.fire();
          cmp.set("v.isLoading", false);
        }
      } else if (state === "ERROR") {
        console.log("** parsing errors");
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            message = "Error: " + errors[0].message;
            console.log("Error message: " + errors[0].message);
          }
        } else {
          message = "Error: unknown error";
          console.log("Unknown error");
        }
      }
      cmp.set("v.isLoading", false);
    });
    console.log("* sending request");
    $A.enqueueAction(action);

    var action2 = cmp.get("c.canCancelAsset");
    action2.setParams({ assetId: cmp.get("v.recordId") });
    action2.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log("** parsing response");
        console.log("****", response.getReturnValue());
        cmp.set("v.canCancel", response.getReturnValue());
        cmp.set("v.isLoading", false);
      } else if (state === "ERROR") {
        console.log("** parsing errors");
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
      }
      cmp.set("v.isLoading", false);
    });
    console.log("* sending request");
    $A.enqueueAction(action2);
  },

  handleClose: function () {
    $A.get("e.force:closeQuickAction").fire();
  },

  handleCancel: function (cmp) {
    cmp.set("v.isLoading", true);
    console.log("* cancelling asset");
    var action = cmp.get("c.initAssetCancellation");
    var toastEvent = $A.get("e.force:showToast");
    action.setParams({ assetId: cmp.get("v.recordId") });
    action.setCallback(this, function (response) {
      var state = response.getState();
      var message = "Complete.";
      if (state === "SUCCESS") {
        console.log("** parsing response");
        message = "Response: " + response.getReturnValue();
        var results = JSON.parse(response.getReturnValue());
        console.log("****", results);
        if (results == null) {
          message = "Success!";

          toastEvent.setParams({
            type: "success",
            mode: "sticky",
            title: "Success",
            message: "Cancelling Asset"
          });
          toastEvent.fire();
        } else {
          message = results[0].errorCode + " : " + results[0].message;
          toastEvent.setParams({
            type: "error",
            mode: "sticky",
            title: "Error",
            message: message
          });
          toastEvent.fire();
        }
        cmp.set("v.isLoading", false);
        $A.get("e.force:closeQuickAction").fire();
      } else if (state === "ERROR") {
        console.log("** parsing errors");
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            message = "Error: " + errors[0].message;
            console.log("Error message: " + errors[0].message);
          }
        } else {
          message = "Error: unknown error";
          console.log("Unknown error");
        }
      }
      cmp.set("v.message", message);
    });
    console.log("* sending request");
    $A.enqueueAction(action);
  }
});
