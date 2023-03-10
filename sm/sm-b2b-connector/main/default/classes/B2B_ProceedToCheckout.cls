public with sharing class B2B_ProceedToCheckout {
    @AuraEnabled
    public static Map<String, Object> getActiveCartStatus() {

        Map<String, Object> response = new Map<String, Object>();
        response.put('isActive', true);

        WebCart currentCart;

        if(!Test.isRunningTest()) { currentCart = [SELECT Id, Cart_Type__c, Quote__c,Status FROM WebCart WITH SECURITY_ENFORCED LIMIT 1];
        } else {
            currentCart = [SELECT Id, Cart_Type__c, Quote__c,Status FROM WebCart LIMIT 1];
        }

        if (currentCart != null) {
            response.put('cartId', currentCart.Id);
            response.put('cartType', currentCart.Cart_Type__c);
            if(currentCart.Quote__c != null){  response.put('isQuoteExist', true);
            }else{
                response.put('isQuoteExist', false);
            }
            if (!currentCart.Status.equalsIgnoreCase('active')) {  response.put('isActive', false);
            }
        }

        return response;
    }   
   
   @AuraEnabled 
   public static string checkQueueStatus(string jobId){
       String queueStatus ;
          
       return  queueStatus;
   }

   @AuraEnabled
   public static void createRenewalQuote(){

   }
 
   @future (callout=true)
   public static void deleteExistingQuotes(String quoteId){
       try{
           Map<String, Object> flowInput = new Map<String, Object>();
           flowInput.put('QuoteId', quoteId);

       }
       catch(Exception ex){
           System.debug('ex ' +ex);
         
       }
   }
}