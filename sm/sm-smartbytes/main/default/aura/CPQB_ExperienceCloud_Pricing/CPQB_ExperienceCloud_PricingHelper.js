({
    genQuoteHelper: function(component, event, helper) {
        var myProductId = '01t3c000005MP7jAAG'	;
        console.log("CPQB_ExperienceCloud_PricingHelper | genQuoteHelper");
        var urlEvent = $A.get("e.force:navigateToURL");
        var toastEvent = $A.get("e.force:showToast");
    
        component.set("v.showSpinner", true);
    
        var action = component.get("c.addProduct");
        

        var toastTitle = component.get("v.successMessage") ? component.get("v.successMessage") : "Success";
        console.log("Toast Title", toastTitle);
        var navToQuote = false; //component.get("v.navToQuote");
        console.log("Stay on record", navToQuote);
    
        action.setParams({
          accountId: '0013c00001rx2D1AAI',
          productId: myProductId,
          subTerm: 12
        });
        
        console.log('HERE HERE HERE');
    	
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
                messageTemplate: "Click on {0} or visit {1} for more information.",
              messageTemplateData: [
                {
                  url: "/partner/s/order-details?id=" + response.getReturnValue(),
                  label: "Order Details"
                },
                  {
                  url: "/partner/s/account-management?tabset-45d61=ff7cd",
                  label: "Account Management"
                }
              ]
            });
            toastEvent.fire();
    
            if (navToQuote) {
              return;
            } else {
              urlEvent.setParams({
                    url: "/partner/s/order-details?id=" + response.getReturnValue()
                }).fire();
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
	createItem: function (component, event, helper) {
        console.log('inside createItem');
        console.log(component);
        var action = component.get("c.fireTheQuickQuote");

        var toastEvent = $A.get("e.force:showToast");
        var urlEvent = $A.get("e.force:navigateToURL");

        component.set("v.showSpinner", true);

        action.setCallback(this, function (response) {
			
            var state = response.getState();
            console.log(state);
            console.log(response);
            if (state === "SUCCESS") {
                console.log("Quick Quote Process Started");
                console.log(response.getReturnValue());

                setTimeout(function () {
                    component.set("v.showSpinner", false);
                }, 1500);

                toastEvent.setParams({
                    "title": "Success",
                    "message": "Quick Quote Process Started",
                    "type": "success"
                });
                toastEvent.fire()

                urlEvent.setParams({
                    //"url": "/sfdcpage/%2Fapex%2FSBQQ__sb%3F%26id%3D" + response.getReturnValue()
                    "url" : "/partner/s/order-details?id=" + response.getReturnValue()
                });

                urlEvent.fire();

            } else {
                console.log("Error Creating Quick Quote!");

                setTimeout(function () {
                    component.set("v.showSpinner", false);
                }, 1500);

                toastEvent.setParams({
                    "title": "Error",
                    "message": "Error Creating Quick Quote!",
                    "type": "error"
                });
                toastEvent.fire()

            }
        });
        
        $A.enqueueAction(action);
    },
})