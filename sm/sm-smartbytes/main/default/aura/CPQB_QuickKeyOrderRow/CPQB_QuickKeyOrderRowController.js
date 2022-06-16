({
  doRowInit: function(component, event, helper) {
    console.log("CPQB_QuickKeyOrderRowController | doRowInit");
    // Set Start Date to today
    var date = new Date();
    component.set(
      "v.productStart",
      `${date.getFullYear()}-${(date.getMonth() + 1)
        .toString()
        .padStart(2, "0")}-${date
        .getDate()
        .toString()
        .padStart(2, "0")}`
    );
    //Initialize Values
    component.set(
      "v.productChargeType",
      'Recurring'
    );
    component.set(
      "v.productBillingFreq",
      'Monthly'
    );
    component.set(
      "v.productBillingType",
      'Advance'
    );
  },


    debounceCodeInput: function (component, event, helper) {
      // clear out validity setting if the user starts typing
      var inputCmp = component.find("productCode");
      inputCmp.setCustomValidity("");
      inputCmp.reportValidity();
      // Cleanup search term and check if we need to
      // proceed with search (has the search term changed?)
      var delay = 300;
  
      // Cancel previous timeout if any
      var searchTimeout = component.get('v.searchTimeout');
  
      if (searchTimeout) {
  
        clearTimeout(searchTimeout);
      }
      // Set new timeout
      searchTimeout = window.setTimeout(
        $A.getCallback(() => {
          // Send search request
          helper.validateCode(component, event, helper);
          // Clear timeout
          component.set('v.searchTimeout', null);
        }),
        delay // Wait before sending search request
      );
      component.set('v.searchTimeout', searchTimeout);
    },
  
    doUpdateInput: function (component, event, helper) {
      console.log("CPQB_QuickKeyOrderRowController | doUpdateInput");
      //update values based on input
      var chargeType = component.get("v.productChargeType");
      if(chargeType == 'Recurring'){
        component.set(
          "v.productBillingFreq",
          'Monthly'
        );
        component.set(
          "v.productBillingType",
          'Advance'
        );
      }
      if(chargeType == 'One-Time'){
        component.set(
          "v.productBillingFreq",
          ''
        );
        component.set(
          "v.productBillingType",
          ''
        );
      }
      if(chargeType == 'Usage'){
        component.set(
          "v.productBillingFreq",
          'Monthly'
        );
        component.set(
          "v.productBillingType",
          'Arrears'
        );
      }
    },
  
    handleRemoveLine: function (component, event, helper) {
      console.log("CPQB_QuickKeyRowController | handleRemoveLine");
      // Fire a remove event to handle in parent cmp to splice the array
      var idx = component.get("v.index");
      var deleteEvent = component.getEvent("deleteRow");
      deleteEvent.setParams({
        removeRow: idx
      }).fire();
    }
  });