/**
 * @description       : 
 * @author            : Prabhat Kumar
 * @group             : 
 * @last modified on  : 05-20-2022
 * @last modified by  : Prabhat Kumar
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   05-20-2022   Prabhat Kumar  Initial Version
**/
global without sharing class UpdateCartItemfromQuoteLine {

    private static final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.DISCOUNT_UPDATE);
    
     /**
     * @description Update the Cart Item with Discount amount from Quote Line item.
     * @param quoteLineItems List of quote line items.
     * @return void.
     */
    global static void updateCartItemfromQuotelineItem(List<QuoteLineItem> quoteLineItems)
    {
      
        
        Set<Id> cartItemIds = new Set<id>();
        Set<id> quoteId = new set<id>();
        
        Map<string, QuoteLineItem> mapQuoteLineItem = new Map<string, QuoteLineItem>();
        for(QuoteLineItem qi : quoteLineItems){
            
            cartItemIds.add(qi.cartitemid__c);
            mapQuoteLineItem.put(qi.cartitemid__c, qi);
            quoteId.add(qi.QuoteId);

            
        }
        
          //Apply discount if the quote is apporved.
        List<Quote> q = [SELECT ID, STATUS FROM QUOTE WHERE ID IN: quoteId AND STATUS = 'Approved' WITH SECURITY_ENFORCED];
        if(q.size() > 0){
        //Query Cart item and update the price if discount applied.
            String cartItemSOQL = 'SELECT ' + RSM_Utils.getAllObjectFields(String.valueOf(CartItem.getSObjectType())) +
                ' FROM ' + String.valueOf(CartItem.getSObjectType()) +
                ' WHERE Id IN : cartItemIds LIMIT 49999';
            
            List<CartItem> cartItemLst = (List<CartItem>)Database.query(cartItemSOQL);
            List<CartItem> updatedCartItemLst = new List<CartItem>();
            
        if(cartItemLst.size() > 0){
            for(CartItem ci : cartItemLst){
                
                ci.ListPrice = mapQuoteLineItem.get(ci.id).TotalPrice;
                    ci.SalesPrice = mapQuoteLineItem.get(ci.id).TotalPrice;
                ci.Sku = 'Quote Update';
                ci.AdjustmentAmount = 0;
                ci.AdjustmentTaxAmount = 0;
                ci.TotalAdjustmentAmount = 0;
                ci.TotalPriceAfterAllAdjustments = 0;
                ci.TotalLineAmount = mapQuoteLineItem.get(ci.id).TotalPrice;
                ci.TotalListPrice = mapQuoteLineItem.get(ci.id).TotalPrice;
                ci.TotalPrice = mapQuoteLineItem.get(ci.id).TotalPrice;
                ci.UnitAdjustedPrice = mapQuoteLineItem.get(ci.id).TotalPrice;
                ci.Discount__c =  mapQuoteLineItem.get(ci.id).Discount > 0 ? (mapQuoteLineItem.get(ci.id).UnitPrice - mapQuoteLineItem.get(ci.id).TotalPrice) : 0;
                updatedCartItemLst.add(ci);
               
                
            }

            try{
           
                DMLManager.updateAsSystem(updatedCartItemLst);
           
            } catch(Exception e) {
                logger.error(e);
            } finally {
                logger.flush();
            }

            
        }
     }
     
  }

}