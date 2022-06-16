({
    validateCode: function(component, event, helper) {
      console.log("productCodeQuickQuoteRowHelper | validateCode");
      var allCodes = component.get("v.allCodes");
      if (allCodes.length == 0) {
        return;
      }
  
      // Concat empty array to make sure we can use array methods
      var allValid = []
        .concat(component.find("productCode"))
        .reduce(function(validSoFar, inputCmp) {
          var rawVal = inputCmp.get("v.value");
          var theVal = rawVal
            .trim()
            .replace(/\*/g)
            .toLowerCase();
          if (!theVal) {
            // if no value clear custom validity and report
            inputCmp.setCustomValidity("");
            inputCmp.reportValidity();
  
            return true;
          }
          if (allCodes.indexOf(theVal) > -1) {
            console.log("Matched");
            inputCmp.setCustomValidity("");
            inputCmp.reportValidity();
          } else {
            console.log("Bad Match");
            inputCmp.setCustomValidity("Invalid Product Code");
            inputCmp.reportValidity();
          }
          return validSoFar && inputCmp.checkValidity();
        }, true);
  
      console.log(allValid);
    }
  });