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
    component.set(
      "v.productEnd",
      `${date.getFullYear() + 1}-${(date.getMonth() + 1)
        .toString()
        .padStart(2, "0")}-${date
        .getDate()
        .toString()
        .padStart(2, "0")}`
    );
    //Initialize Values
    component.set(
      "v.productChargeType",
      'One-Time'
    );
    component.set(
      "v.productBillingFreq",
      ''
    );
    component.set(
      "v.productBillingType",
      ''
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
      var product = component.get("v.selectedLookUpRecord");
      console.log(
        ` product: ` + product +
        ` product.Name: ` + product.Name +
        ` product.ProductCode: ` + product.ProductCode + 
        ` productChargeType: ` + product.SBQQ__ChargeType__c +
        ` productBillingFreq: ` + product.SBQQ__BillingFrequency__c +
        ` productBillingType: ` + product.SBQQ__BillingType__c +
        ` productPrice: ` + product.Standard_Pricebook_Price__c +
        ` productSubTerm: ` + product.SBQQ__SubscriptionTerm__c
      );
      component.set(
        "v.productQuant",
        1
      );
      component.set(
        "v.productSubTerm",
        product.SBQQ__SubscriptionTerm__c
      );
      
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
      component.set(
        "v.productEnd",
        `${date.getFullYear() + 1}-${(date.getMonth() + 1)
          .toString()
          .padStart(2, "0")}-${date
          .getDate()
          .toString()
          .padStart(2, "0")}`
      );

      if(product.Name){ // if record was selected
        component.set(
          "v.productCode",
          product.ProductCode
        );
        component.set(
          "v.productChargeType",
          product.SBQQ__ChargeType__c
        );
        component.set(
          "v.productBillingFreq",
          product.SBQQ__BillingFrequency__c
        );
        component.set(
          "v.productBillingType",
          product.SBQQ__BillingType__c
        );
        
        if(component.get("v.productChargeType") === "One-Time"){
          // var q = component.get("v.productQuant");
          component.set(
            "v.productPrice",
            product.Standard_Pricebook_Price__c * component.get("v.productQuant")
          );
        } 
        else if(component.get("v.productEnd") > component.get("v.productStart") ){ // product exists, end date is not null & valid

          helper.calculateProration(component, event, helper); // convert dates for proration calculation

          component.set(
            "v.productPrice",
            product.Standard_Pricebook_Price__c * component.get("v.productQuant") * component.get("v.productProration")
          );
        } else { // product exists & recurring, end date doesn't meet expectations
          component.set(
            "v.productPrice",
            product.Standard_Pricebook_Price__c * component.get("v.productQuant")
          );
        }
      }
    },

    doUpdatePrice: function (component, event, helper) {
      console.log("CPQB_QuickKeyOrderRowController | doUpdatePrice");
      //update values based on input
      var product = component.get("v.selectedLookUpRecord");
      console.log(
        ` product: ` + product +
        ` product.Name: ` + product.Name +
        ` product.ProductCode: ` + product.ProductCode + 
        ` productChargeType: ` + product.SBQQ__ChargeType__c +
        ` productBillingFreq: ` + product.SBQQ__BillingFrequency__c +
        ` productBillingType: ` + product.SBQQ__BillingType__c +
        ` productPrice: ` + product.Standard_Pricebook_Price__c +
        ` productSubTerm: ` + product.SBQQ__SubscriptionTerm__c
      );
      if(product.Name){ // if record was selected
        if(component.get("v.productChargeType") === "One-Time"){
          // var q = component.get("v.productQuant");
          component.set(
            "v.productPrice",
            product.Standard_Pricebook_Price__c * component.get("v.productQuant")
          );
        } 
        else if(component.get("v.productEnd") > component.get("v.productStart") ){ // product exists, end date is not null & valid

          console.log(`PRE OPERATION: Product Code: ` + component.get("v.productCode") + `, productSubTerm: ` + component.get("v.productSubTerm"));

          helper.calculateProration(component, event, helper); // convert dates for proration calculation

          console.log(`POST OPERATION: Product Code: ` + component.get("v.productCode") + `, productSubTerm: ` + component.get("v.productSubTerm"));

          component.set(
            "v.productPrice",
            product.Standard_Pricebook_Price__c * component.get("v.productQuant") * component.get("v.productProration")
          );
        } else { // product exists & recurring, end date doesn't meet expectations
          component.set(
            "v.productPrice",
            product.Standard_Pricebook_Price__c * component.get("v.productQuant")
          );
        }
      }
    },

    doAdjustInput: function (component, event, helper) {
      console.log("CPQB_QuickKeyOrderRowController | doAdjustInput");
      // for adjustments
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