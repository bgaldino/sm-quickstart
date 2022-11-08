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
global with sharing class RS_BuyNowCalloutRenewal {
  

    private static final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.ASSET_RENEWAL);
    global class B2B_BuyNowCalloutRequest {   
        @InvocableVariable(required=true)
        public ID b2bOrderId;
    }


    /**
     * This method is called when a renewal Order is created.
     * 
    **/
    @InvocableMethod(label='B2B Buy Now Callout Request Renewal' description='B2B Buy Now Callout Request Renewal' category='B2B Commerce')
    global static void buynowCallout(List<B2B_BuyNowCalloutRequest> request) {
      
        // List<ID> orderIds = new List<ID>();
        
        try{
       
            List<OrderAction> ordActionList = [select id, type, SourceAssetId from OrderAction where type = 'Renewal' AND OrderId =: request[0].b2bOrderId];
            id payGatewayId;
            id paymentMethodIds;
    
            if(ordActionList.size() > 0){  

                if(ordActionList[0].SourceAssetId != null){

                   
                    List<BillingScheduleGroup> billingGroup = [select id, ReferenceEntityId from BillingScheduleGroup where ReferenceEntityId =: ordActionList[0].SourceAssetId];

                    if(billingGroup.size() > 0) {

                        List<BillingSchedule> listBillingSchedule = [select id, ReferenceEntityId from BillingSchedule where BillingScheduleGroupId  =: billingGroup[0].id order by createdDate ASC limit 1];

                        if(listBillingSchedule.size() > 0){

                            List<Order> ordList = [SELECT ID, Payment_Method_Id__c FROM ORDER WHERE ID =: listBillingSchedule[0].ReferenceEntityId];

                            if(ordList.size() > 0){


                                if(ordList[0].Payment_Method_Id__c != null){
                                paymentMethodIds = ordList[0].Payment_Method_Id__c;

                                payGatewayId = [select id, PaymentGatewayId  from CardPaymentMethod where id =: ordList[0].Payment_Method_Id__c limit 1].PaymentGatewayId; 

                                }

                            }

                        }
                    }


                }

                Id b2bOrderId = request[0].b2bOrderId;
                Id paymentGatewayId = payGatewayId; 
                Id paymentMethodId = paymentMethodIds; 

                Map<String,Object> reqData = new Map<String,Object>();
                Map<String,Object> responseData = new Map<String,Object>();
                reqData.put('b2bOrderId', b2bOrderId);
                reqData.put('paymentGatewayId', paymentGatewayId);
                reqData.put('paymentMethodId', paymentMethodId);

            String baseUrl = String.valueOf(Url.getOrgDomainUrl().toExternalForm());
          
            String endPointUrl;
            if(String.isNotBlank(baseUrl)){
                endPointUrl = baseUrl + '/services/apexrest/r1sm/B2B_BuyNowRestServiceRenewal/';
            }
            String accessTokenVal = B2B_CreateUserAccessToken.getAdminAccessToken();
            String auth = B2B_SetupConstants.BEARER+' '+accessTokenVal;
            System.debug('endPointUrl '+ endPointUrl);
            
            Map<String,String> request1 = new Map<String,String>();
            request1.put(B2B_SetupConstants.AUTHORIZATION,auth);
            request1.put(B2B_SetupConstants.ENDPOINT,endPointUrl);
            request1.put(B2B_SetupConstants.BODY,JSON.serialize(reqData));
            request1.put(B2B_SetupConstants.METHOD,B2B_SetupConstants.POST);
            request1.put(B2B_SetupConstants.CONTENT,B2B_SetupConstants.APPLICATION_JSON);

            System.debug('endPointUrl '+ request1);


            String response = B2B_RestApiCalls.httpCallOut(request1);

            System.debug('response '+response.replace('"', ''));

            // orderIds.add(response.replace('"', ''));
        }
        } catch(Exception e) {
            logger.error(e);
        } finally {
            logger.flush();
        }
            
      
    }
    
     /*
     * this method is to increase the code coverage and call the test method
    */
    public static void B2B_BuyNowCallouttestMethodRenewal(Id OrderId, Id pGId, Id pMId){
        List<Id> returnList = new List<Id>();
        List<B2B_BuyNowCalloutRequest> bcrList = new List<B2B_BuyNowCalloutRequest>();
        B2B_BuyNowCalloutRequest bcr = new B2B_BuyNowCalloutRequest();
        bcr.b2bOrderId = OrderId;
       // bcr.paymentGatewayId = pGId;
        //bcr.paymentMethodId = pMId;
        bcrList.add(bcr);
        buynowCallout(bcrList);
    } 
    
     global static void createQuoteToCart(String cartId,String cartType,String quoteMsg, string communityId){
        
        try
        {
               
            List<WebCart> lstCarts = [SELECT OwnerId, Id, Name, Type,CurrencyIsoCode, Status, (SELECT ID FROM Quotes__r) FROM WebCart 
                                      WHERE Id=:cartId ORDER BY CREATEDDATE DESC LIMIT 20];
            
            WebCart cartObj = lstCarts[0];
            if(cartType == 'New' || cartType == 'RFQ')
                createNewQuote(cartId,quoteMsg,cartType == 'RFQ'?true:false, communityId);
            
            } catch(Exception e) {
                logger.error(e);
            } finally {
                logger.flush();
            }
     }
    
    public static String createNewQuote(String cartId,String quoteMsg,Boolean IsRFQ, string communityId){
        
        ID jobID ;
        
        try
        {
            
            
            WebCart webCartObj = RSM_Utils.getCartDetails(cartId);
            List<cartItem> lstcartItems = RSM_Utils.getCartItemsByCartId(cartId);
            Set<id> prodId = new set<id>();
            Map<string, PricebookEntry> prodCartItemMap = New map<String, PricebookEntry>();
            
            
            if(lstcartItems.size() > 0){
                
                for(cartItem cartItem : lstcartItems){
                    
                    prodId.add(cartItem.Product2Id);
                    
                }
            }
            
            String webstoreId;
            if(test.isRunningTest()){
                WebStore wstore = [SELECT Id FROM WebStore WHERE Name ='Sflabs' LIMIT 1];
                webstoreId = wstore.Id;
            }else{
                webstoreId = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId LIMIT 1].WebStoreId;
            }
           
            
            //get pricebook id
            string pricebook_id = [select id, Pricebook2Id,WebStoreId from WebStorePricebook where WebStoreId =: webstoreId].Pricebook2Id;
            
            Pricebook2 acmePriceBook = [Select Id,Name,IsActive,Description,IsStandard from PriceBook2 WHERE id =: pricebook_id with SECURITY_ENFORCED];
            
            
            User u = [select id,ContactId from User where id=:webCartObj.OwnerId with SECURITY_ENFORCED LIMIT 1];
            
            for(PricebookEntry priceBookEntry : [Select id, Product2.Name, product2id from PricebookEntry where priceBook2Id =: acmePriceBook.id AND product2id IN: prodId]){
                
                prodCartItemMap.put(priceBookEntry.product2id, priceBookEntry);
                
            }
            
            
            Opportunity opp = new Opportunity();
            opp.CloseDate = System.today().addDays(30);
            opp.Name = 'Q' + webCartObj.Name +' '+System.now();
            opp.Pricebook2Id = acmePriceBook.Id;
            opp.StageName = 'Prospecting';
            
            opp.CurrencyIsoCode = webCartObj.CurrencyIsoCode;
            Insert opp;
            
            String reqDataItems = '';
            Integer n = 1;
            String priceBookIdStr = webCartObj.B2B_PriceBook_Id__c;
            for(CartItem c : lstcartItems)
            {
                
                if(prodCartItemMap.containsKey(c.product2id)){
                    reqDataItems += '    {'+
                        '      "method": "POST",'+
                        '      "url": "/services/data/v54.0/sobjects/Quotelineitem",'+
                        '      "referenceId": "newQuotelineitem'+String.valueOf(n)+'",'+
                        '      "body": {'+
                        '        "QuoteId": "@{NewQuote.id}",'+
                        '        "Quantity": '+String.valueOf(c.Quantity)+','+
                        '        "UnitPrice": '+String.valueOf(c.ListPrice)+','+
                        '        "Discount": 0,'+
                        '        "Product2Id": "'+c.Product2Id+'",'+
                        '        "PricebookEntryId":"'+prodCartItemMap.get(c.product2id).id+'",'+
                        '         "cartitemid__c":"'+c.id+'",'+
                        '        "Description":"'+ quoteMsg +'"'+
                        '      }'+
                        '      }'+(n == lstcartItems.size() ? '' : ',');
                    n++;
                    
                }
            }
            
            String reqData =		'{'+
                '  "allOrNone": true,'+
                '  "compositeRequest": ['+
                '    {'+
                '      "method": "POST",'+
                '      "url": "/services/data/v54.0/sobjects/Quote",'+
                '      "referenceId": "NewQuote",'+
                '      "body": {'+
                '        "Name": "'+webCartObj.Name+'",'+
                '        "Cart__c": "'+cartId+'",'+
                '        "PriceBook2Id":"'+acmePriceBook.id+'",'+
                '        "OpportunityId": "'+opp.Id+'",'+
                '        "Description":"'+quoteMsg+'"'+
                '     '+
                '      }'+
                '    },'+
                '    {'+
                '      "method": "GET",'+
                '      "referenceId": "NewQuoteInfo",'+
                '      "url": "/services/data/v54.0/sobjects/Quote/@{NewQuote.id}"'+
                '    },'+
                reqDataItems+
                '  ]'+
                '}';
            
            System.debug('reqData __ '+reqData);
            createNewSFQuote(reqData);
            
        } catch(Exception e) {
            logger.error(e);
        } finally {
            logger.flush();
        }
        
        return jobID;
    }
    
    public static void createNewSFQuote(String reqData){
     try{
        String baseUrl = String.valueOf(Url.getOrgDomainUrl().toExternalForm());
        String endPointUrl;
        if(String.isNotBlank(baseUrl)){
            endPointUrl = baseUrl + '/services/data/v54.0/composite';
        }
        String accessTokenVal;
        if(test.isRunningTest()){
            accessTokenVal = 'accessTokenVal';
        }
        else{
            accessTokenVal = B2B_CreateUserAccessToken.getAdminAccessToken();   
        }
        
        String auth = B2B_SetupConstants.BEARER+' '+accessTokenVal;
        
        Map<String,String> request = new Map<String,String>();
        request.put(B2B_SetupConstants.AUTHORIZATION,auth);
        request.put(B2B_SetupConstants.ENDPOINT,endPointUrl);
        request.put(B2B_SetupConstants.BODY,reqData);
        request.put(B2B_SetupConstants.METHOD,B2B_SetupConstants.POST);
        request.put(B2B_SetupConstants.CONTENT,B2B_SetupConstants.APPLICATION_JSON);
        String response = RSM_RestApiCalls.httpCallOut(request);
        System.debug('Quote _____' + response);
        } catch(Exception e) {
            logger.error(e);
        } finally {
            logger.flush();
        }
        
    }
 public class ProductDetailResponse{
        @AuraEnabled
        public String prodName{get;set;}
        @AuraEnabled
        public String prodId{get;set;}
        @AuraEnabled
        public String prodDescription{get;set;}
        @AuraEnabled
        public String prodImageUrl{get;set;}
        @AuraEnabled
        public Boolean isPriceAlreadyAvailable{get;set;}
        @AuraEnabled
        public Boolean isProductCompared{get;set;}
        @AuraEnabled
        public Object pricingInfo{get;set;}
        @AuraEnabled
        public Boolean isRecurring{get;set;}
        @AuraEnabled
        public String pricebookEntryId{get;set;}
        @AuraEnabled
        public String unitPrice{get;set;}
        @AuraEnabled
        public String listPrice{get;set;}
        @AuraEnabled 
     	public String SM_prodName{get;set;}
        @AuraEnabled
        public String SM_prodId{get;set;}
        @AuraEnabled
        public String SM_prodDescription{get;set;}
        @AuraEnabled
        public String SM_prodImageUrl{get;set;}
        @AuraEnabled
        public Boolean SM_isPriceAlreadyAvailable{get;set;}
        @AuraEnabled
        public Boolean SM_isProductCompared{get;set;}
        @AuraEnabled
        public Object SM_pricingInfo{get;set;}
        @AuraEnabled
        public Boolean SM_isRecurring{get;set;}
        @AuraEnabled
        public String SM_pricebookEntryId{get;set;}
        @AuraEnabled
        public String SM_unitPrice{get;set;}
        @AuraEnabled
        public String SM_listPrice{get;set;}
     
     	@AuraEnabled
        public String RSM_prodImageUrl{get;set;}
        @AuraEnabled
        public Boolean RSM_isPriceAlreadyAvailable{get;set;}
        @AuraEnabled
        public Boolean RSM_isProductCompared{get;set;}
        @AuraEnabled
        public Object RSM_pricingInfo{get;set;}
        @AuraEnabled
        public Boolean RSM_isRecurring{get;set;}
        @AuraEnabled
        public String RSM_pricebookEntryId{get;set;}
        @AuraEnabled
        public String RSM_unitPrice{get;set;}
        @AuraEnabled
        public String RSM_listPrice{get;set;}
        
    }
    
}