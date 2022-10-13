public with sharing class B2B_ProceedToCheckout {
    @AuraEnabled
    public static Map<String, Object> getActiveCartStatus() {

        Map<String, Object> response = new Map<String, Object>();
        response.put('isActive', true);

        WebCart currentCart = [SELECT Id, Cart_Type__c, Quote__c,Status FROM WebCart LIMIT 1];//new B2B_Util().getActiveCart();
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
               endPointUrl = baseUrl + '/services/apexrest/B2BCartToQuoteRestService/';
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
     /*  List<AsyncApexJob> aajob = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors
                               FROM AsyncApexJob WHERE ID =: jobId];

                               System.debug('aajob _____ ' + aajob);

       if(!aajob.isEmpty()){

           queueStatus = aajob[0].Status;
       }             */           
       return  queueStatus;
   }

   @AuraEnabled
   public static void createRenewalQuote(){
     /*  try {

            List<Opportunity> lstRenewlOpp = [SELECT Id, Amount, Pricebook2Id, SBQQ__PrimaryQuote__c, StageName, CloseDate, AccountId, Account.Name, Name, SBQQ__RenewedContract__c,SBQQ__AmendedContract__c
            FROM Opportunity ORDER BY CREATEDDATE DESC LIMIT 1];

              Opportunity oppObj;

              system.debug(lstRenewlOpp + 'lstRenewlOpp>>>');

               oppObj = lstRenewlOpp[0];
               Opportunity cloneOppObj = oppObj.clone(false, true, false, false); //Record is read-only ,get around this by deep-cloning 
               //cloneOppObj.SBQQ__Contracted__c = true;
               cloneOppObj.CloseDate = system.today().addDays(365);
               insert cloneOppObj;

               //change opp name
               lstRenewlOpp[0].Name = 'Trial to buy -' + lstRenewlOpp[0].Account.Name;
               update lstRenewlOpp;


           
       } catch (Exception e) {
           throw new AuraHandledException(e.getMessage());
       }*/
   }
 
   @future (callout=true)
   public static void deleteExistingQuotes(String quoteId){
       try{
           Map<String, Object> flowInput = new Map<String, Object>();
           flowInput.put('QuoteId', quoteId);
         /*  Flow.Interview.LEB2B_purgeQuoteAndOrder purgeQuoteRelatedData = new Flow.Interview.LEB2B_purgeQuoteAndOrder(flowInput);
           purgeQuoteRelatedData.start();
           */
       }
       catch(Exception ex){
           System.debug('ex ' +ex);
         
       }
   }
}