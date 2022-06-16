({
    validateCode: function(component, event, helper) {
      console.log("productCodeQuickOrderRowHelper | validateCode");
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
    },

    calculateProration: function(component, event, helper) {
      console.log("CPQB_MCBHelper | calculateProration");
      
      console.log(`Start Date: ` + component.get("v.productStart") + `, End Date: ` + component.get("v.productEnd"));
      
      var splitDate = component.get("v.productEnd").split('-');
      if(splitDate.count == 0){
        return null;
      }

      var year = splitDate[0];
      var month = splitDate[1];
      var day = splitDate[2]; 

      var endDate = month + '/' + day + '/' + year;

      splitDate = component.get("v.productStart").split('-');
      if(splitDate.count == 0){
        return null;
      }

      year = splitDate[0];
      month = splitDate[1];
      day = splitDate[2]; 

      var startDate = month + '/' + day + '/' + year;

      console.log(`Only For Proration Calculation: Start Date: ${startDate}, End Date: ${endDate}.`);

      var date1 = new Date(startDate); 
      var date2 = new Date(endDate); 

      // To calculate the time difference of two dates 
      var Difference_In_Time = date2.getTime() - date1.getTime(); 

      console.log(`Product Code: ` + component.get("v.productCode") + `, productSubTerm: ` + component.get("v.productSubTerm"));
      var pSubTerm = component.get("v.productSubTerm");

      var pSubTermDays = 365/(12/pSubTerm);
     
      var proration = Difference_In_Time / (1000*60*60*24*(pSubTermDays));
      console.log(`proration: ` + proration);
      
      component.set(
        "v.productProration",
        proration
      );
    }
  });