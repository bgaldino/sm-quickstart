public with sharing class B2B_ProceedToCheckout {
    @AuraEnabled
    public static Map<String, Object> getActiveCartStatus() {

        Map<String, Object> response = new Map<String, Object>();
        response.put('isActive', true);

        WebCart currentCart = [SELECT Id, Cart_Type__c, Quote__c,Status FROM WebCart LIMIT 1];
        if (currentCart != null) {
            response.put('cartId', currentCart.Id);
            response.put('cartType', currentCart.Cart_Type__c);
            if(currentCart.Quote__c != null){
                response.put('isQuoteExist', true);
            }else{
                response.put('isQuoteExist', false);
            }
            if (!currentCart.Status.equalsIgnoreCase('active')) {
                response.put('isActive', false);
            }
        }

        return response;
    }

   @AuraEnabled
   public static  Map<String,Object> createQuotes(String cartId,String cartType){
       Map<String,Object> reqData = new Map<String,Object>();
       Map<String,Object> responseData = new Map<String,Object>();
       reqData.put('cartId', cartId);
       reqData.put('cartType', cartType);
       reqData.put('quoteMsg', 'B2B Quote');
       try{
           String baseUrl = String.valueOf(Url.getOrgDomainUrl().toExternalForm());
           String endPointUrl;
           if(String.isNotBlank(baseUrl)){
               endPointUrl = baseUrl + '/services/apexrest/r1sm/B2BCartToQuoteRestService/';
           }
           String accessTokenVal = 'cgcvu6787vbkbgvfcdxsdyui'; //B2B_CreateUserAccessToken.getAccessToken(true);
           String auth = B2B_SetupConstants.BEARER+' '+accessTokenVal;
           
           Map<String,String> request = new Map<String,String>();
           request.put(B2B_SetupConstants.AUTHORIZATION,auth);
           request.put(B2B_SetupConstants.ENDPOINT,endPointUrl);
           request.put(B2B_SetupConstants.BODY,JSON.serialize(reqData));
           request.put(B2B_SetupConstants.METHOD,B2B_SetupConstants.POST);
           request.put(B2B_SetupConstants.CONTENT,B2B_SetupConstants.APPLICATION_JSON);
           String response = B2B_RestApiCalls.httpCallOut(request);
          responseData.put('isSuccess',true);
          responseData.put('jobId',response.replace('"', ''));     
        }
       catch(Exception e){

       }
       return responseData;
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