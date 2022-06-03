({
	onInit : function(cmp) {
        var date = new Date();
        cmp.set("v.cancelDate", date.toISOString());
    },
    
    handleCancel: function(cmp) {
        console.log("* cancelling asset");
		var action = cmp.get('c.cancelAssetOnDate');
        action.setParams({assetId : cmp.get('v.recordId'), cancelDate: cmp.get('v.cancelDate')});
        action.setCallback(this, function(response){
            var state = response.getState();
            var message = 'Complete.';
            if (state === "SUCCESS") {
                console.log('** parsing response');
                message = 'Response: ' + response.getReturnValue();
                var results = JSON.parse(response.getReturnValue());
                console.log('****', results);
                if(results.requestId != null) {
                    message = "Success!";
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "success",
                        "mode": "sticky",
                        "title": "Success!",
                        "message": "Good job everybody!"
                    });
                    toastEvent.fire();
                } else {
                    message = results[0].errorCode + ' : ' + results[0].message;
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
                console.log("** parsing errors");
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
        console.log("* sending request");
        $A.enqueueAction(action);
	}
})