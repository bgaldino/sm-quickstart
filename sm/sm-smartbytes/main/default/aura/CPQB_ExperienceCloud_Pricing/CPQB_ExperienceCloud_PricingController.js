({
    doInit: function (component, event, helper) {
        // Check if the current User is logged in
        var action = component.get('c.isRendered');
        action.setCallback(this, function (result) {
            component.set('v.rendered', result.getReturnValue());
            console.log(result.getReturnValue());
        });
        $A.enqueueAction(action);

    },
	handleClick: function (component, event, helper) {
       	console.log("Modifying...");
        helper.genQuoteHelper(component, event, helper);
    },
})