({
	doInit : function(component, event, helper) {
        
        var sPageURL = decodeURIComponent(window.location.search.substring(1)); //You get the whole decoded URL of the page.
        var sURLVariables = sPageURL.split('&'); //Split by & so that you get the key value pairs separately in a list
        var sParameterName;
        var i;

        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('='); //to split the key from the value.

            if (sParameterName[0] === 'id') { //lets say you are looking for param name - firstName
                sParameterName[1] === undefined ? 'Not found' : sParameterName[1];
            }
        }
        console.log('Param name: '+sParameterName[0]);
        console.log('Param value: '+sParameterName[1]);
        
        var quoteId = sParameterName[1];
        
       var action = component.get('c.getQuoteDetails');
        action.setCallback(this, function (result) {
            
            console.log(result.getReturnValue());
            var quote = result.getReturnValue();
            console.log(quote.Name);
            console.log(quote.Name.substr(2,5));
            component.set('v.quote', quote);
            component.set('v.Name', quote.Name.substr(2,5));
            component.set('v.quoteStartDate', quote.SBQQ__StartDate__c);
            
            
            
            
            
        });
        action.setParams({
          quoteId: quoteId
        });
        $A.enqueueAction(action);

        
	}
})