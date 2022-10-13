({
    myAction : function(component, event, helper) {
        var action =  component.get("c.lightDownloadInvoice");
        action.setParams({invoiceId : component.get("v.recordId")});
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            var res = response.getReturnValue();
            if (state === "SUCCESS")
            {
                var url = '/servlet/servlet.FileDownload?file=' + res;
                window.open(url,"_blank");
                $A.get("e.force:closeQuickAction").fire();
                // Display the total in a "toast" status message
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Success",
                    "message": "Invoice downloaded.",
                    "type": "success"
                });
                resultsToast.fire();
            }else{
                $A.get("e.force:closeQuickAction").fire();
                // Display the total in a "toast" status message
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "ERROR",
                    "message": "Contact your admin",
                    "type": "error"
                });
                resultsToast.fire();
            }
        }));
        $A.enqueueAction(action);
    }
})