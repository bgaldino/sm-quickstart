/**
 Used for updating discount on the cart. When the cart is approved and discount applied this trigger
 will update the price on the cart line item to reflect on the cart page.
 */

trigger UpdateDiscountOnCart on Quote (after update) {
    
        if(Trigger.isAfter && Trigger.isUpdate){
        
          Map<Id,Quote> newMap = trigger.newMap;
          Map<Id,Quote> oldMap = trigger.oldMap;
          Set<Id> quoteId = new Set<id>();
         
        for(Quote qi : trigger.new){
            
            if(newMap.get(qi.id).Status != oldMap.get(qi.id).Status && newMap.get(qi.id).Status == 'Approved'){
                 quoteId.add(qi.id);
                
            }
   
        }
     	
      List<QuoteLineItem> qLineList = [SELECT ID, Subtotal, cartitemid__c, UnitPrice, QuoteId, TotalPrice, Discount FROM QuoteLineItem WHERE QuoteId IN: quoteId AND DISCOUNT > 0 WITH SECURITY_ENFORCED];
       
            if(qLineList.size() > 0){
                
                 updateCartItemfromQuoteLine.updateCartItemfromQuotelineItem(qLineList);
            }

    }

}