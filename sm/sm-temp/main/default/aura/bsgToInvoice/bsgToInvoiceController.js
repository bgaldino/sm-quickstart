({
	onInit : function(cmp) {
		var action = cmp.get('c.bsgToInvoice');
        action.setParams({orderId  : cmp.get('v.recordId')});
        action.setCallback(this, function(response){
            var state = response.getState();
            var message = 'Complete.';
            console.log('E2E' + state);
            
            if (state === "SUCCESS") {
                message = 'Response: ' + response.getReturnValue();
                var results = JSON.parse(response.getReturnValue());
                console.log('****', results);
                if(results[0].isSuccess) {
                    message = "Success!";
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "success",
                        "mode": "sticky",
                        "title": "Success!",
                        "message": "Success!"
                    });
                    toastEvent.fire();
                } else {
                    message = results[0].errors[0].statusCode + ' : ' + results[0].errors[0].message;
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "error",
                        "mode": "sticky",
                        "title": "Error!",
                        "message": message
                    });
                    toastEvent.fire();
                }
                $A.get("e.force:closeQuickAction").fire(); // if you want to self-close
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        message = 'Error: ' + errors[0].message;
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    message = 'Error: unknown error';
                    console.log("Unknown error");
                }
            }
            cmp.set('v.message', message);
        });
        $A.enqueueAction(action);
	}
})