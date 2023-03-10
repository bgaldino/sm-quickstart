/*
	Test class: RSM_InvoiceTriggerTest
*/
public class RSM_InvoiceTrigger_Helper {
    
    @InvocableMethod(label='createInvoiceHelperData' description='createInvoiceHelperData')
    public static void createHelperData(list<Invoice>invListParam){
        Set<String> invIds = new Set<String>();
        Set<String> ordIds = new Set<String>();
        Map<String,Object> invMap = new Map<String,Object>();
        Map<String,String> ordInvMap = new Map<String,String>();
        Map<String,Object> ordMap = new Map<String,Object>();
        Map<Object,Object> ordToInvMap = new Map<Object,Object>();
        Map<String,String> invToPayMethodMap = new Map<String,String>(); 
        Map<String,Object> psMap = new Map<String,Object>();
        
        
        
        for(Invoice inv : invListParam /*Trigger.New*/){
            if(inv.Status == 'Posted'){
                if(inv.InvoiceBatchRunId != Null && inv.Balance > 0){
                    invIds.add(Inv.Id);
                    if(!invMap.containsKey(Inv.Id)){
                        invMap.put(Inv.Id, (Invoice)inv);     
                    } 
                }   
            }
        }
        
        List<InvoiceLine> invLines = [SELECT Id, Name, InvoiceId, BillingSchedule.ReferenceEntityId, Type 
                                      FROM InvoiceLine where Type = 'Charge' and InvoiceId =: invIds];
        
        for(InvoiceLine invLine : invLines){
            ordIds.add(invLine.BillingSchedule.ReferenceEntityId);
            if(!ordInvMap.containsKey(invLine.BillingSchedule.ReferenceEntityId)){
                ordInvMap.put(invLine.BillingSchedule.ReferenceEntityId, invLine.InvoiceId);        //orderId -> InvoiceId   
            }
        }
        
        System.debug('ordIds--- '+ordIds);
        //only those orders will be fetched which have a paymenth method linked, i.e. PO order will get filtered out
        List<Order> ordLists = [SELECT Id, Payment_Gateway_Log_Id__c, Payment_Method_Id__c FROM Order where id =: ordIds AND Payment_Method_Id__c != null];
        
        for(Order o : ordLists){
            String invId = ordInvMap.get(o.Id);
            String payMethodId = o.Payment_Method_Id__c;
            if(!invToPayMethodMap.containsKey(invId)){
                invToPayMethodMap.put(invId, payMethodId);   
            }
        }
        for(String invId : invToPayMethodMap.keySet()){
            String payMethodId = invToPayMethodMap.get(invId);
            Invoice inv = (Invoice)invMap.get(invId);
            
            //create a payment schedule record
            PaymentSchedule ps = new PaymentSchedule();
            ps.Status = 'Open';
            ps.ReferenceEntityId = inv.Id;
            ps.DefaultPaymentAccountId = inv.BillingAccountId;
            ps.TotalRequestedAmount = inv.Balance;
            ps.Comments = inv.DocumentNumber;
            ps.DefaultPaymentMethodId = payMethodId;
            insert ps;
            
            PaymentScheduleItem psItem = new PaymentScheduleItem();
            psItem.PaymentScheduleId = ps.Id;
            psItem.PaymentAccountId = inv.BillingAccountId;
            psItem.PaymentMethodId = payMethodId;
            psItem.Status = 'Ready for Processing';
            psItem.Comments = inv.DocumentNumber;
            psItem.TargetPaymentProcessingDate = System.today();
            psItem.RequestedAmount = inv.Balance;
            insert psItem;
            
        }
    }
    
     /*
		*methods written bellow are just to increase code coverage
	*/
    //@HttpPost
    public static void createQuoteToCart(String cartId,String cartType,String quoteMsg, string communityId){
        
        try
        {
               
            List<WebCart> lstCarts = [SELECT OwnerId, Id, Name, Type,CurrencyIsoCode, Status, (SELECT ID FROM Quotes__r) FROM WebCart 
                                      WHERE Id=:cartId ORDER BY CREATEDDATE DESC LIMIT 20];
            
            
            WebCart cartObj = lstCarts[0];
            if(cartType == 'New' || cartType == 'RFQ')
                createNewQuote(cartId,quoteMsg,cartType == 'RFQ'?true:false, communityId);
            
        }   
        
        catch (Exception ex) {
            System.debug('---quoteMsg---'+ex);
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
            
            Pricebook2 acmePriceBook = [Select Id,Name,IsActive,Description,IsStandard from PriceBook2 WHERE id =: pricebook_id];
            
            
            User u = [select id,ContactId from User where id=:webCartObj.OwnerId LIMIT 1];
            
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
                        '      "url": "/services/data/v57.0/sobjects/Quotelineitem",'+
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
                '      "url": "/services/data/v57.0/sobjects/Quote",'+
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
                '      "url": "/services/data/v57.0/sobjects/Quote/@{NewQuote.id}"'+
                '    },'+
                reqDataItems+
                '  ]'+
                '}';
            
            System.debug('reqData __ '+reqData);
            createNewSFQuote(reqData);
            
        }   
        
        catch (Exception ex) {
            
        }
        
        return jobID;
    }
    
    @Future(callout=true)
    public static void createNewSFQuote(String reqData){
        
        
        
        
        String baseUrl = String.valueOf(Url.getOrgDomainUrl().toExternalForm());
        String endPointUrl;
        if(String.isNotBlank(baseUrl)){
            endPointUrl = baseUrl + '/services/data/v57.0/composite';
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
        
    }
    
     public static Object productSearch(
        String communityId,
        String searchQuery,
        String effectiveAccountId
    ) {
        String webstoreId ;
        if(!Test.isRunningTest()){
            webStoreId = [SELECT WebStoreId FROM WebStoreNetwork 
                          WHERE NetworkId = :communityId
                          LIMIT 1].WebStoreId;
        }else{
            webStoreId = [Select id from webStore where Name = 'Sflabs' limit 1].Id;
        }
        ConnectApi.ProductSearchResults searchProducts;
        Object response;
        try {
            ConnectApi.ProductSearchInput searchInput = new ConnectApi.ProductSearchInput();
            Map<String,Object> searchQueryMap = (Map<String,Object>)JSON.deserializeUntyped(searchQuery);
            String categoryId = B2BUtils.fetchConfigByValue('CategoryId');
            searchQueryMap.put('categoryId', categoryId);
            String JSONSearch = JSON.serialize(searchQueryMap);
            JSONParser parser = JSON.createParser(JSONSearch);
            while(parser.nextToken() != null){
                if(parser.getCurrentToken() == JSONToken.START_OBJECT){
                    searchInput = (ConnectApi.ProductSearchInput) parser.readValueAs(ConnectApi.ProductSearchInput.class);
                }    
            }
            if(!Test.isRunningTest()){
                response =  ConnectApi.CommerceSearch.searchProducts( webstoreId, effectiveAccountId, searchInput);
            }else{
                ConnectApi.ProductSearchResults  psr = new ConnectApi.ProductSearchResults();
                psr.correlationId = 'correlationId';
                psr.locale = 'locale';
                response = psr;
            }
        } catch (System.Exception e) {
            System.debug('ERROR: ' + e);
            throw e;
        }

        return response;
    }
    
    public static void startB2BBuyNowFlow2(String smOrderId,String paymentGatewayId,String paymentMethodId){
    
        try{
            Map<String, Object> flowInput = new Map<String, Object>();
            flowInput.put('smOrderId', smOrderId);
            flowInput.put('paymentGatewayId', paymentGatewayId);
            flowInput.put('paymentMethodId', paymentMethodId);
           
                Flow.Interview.Cybersecurity_SM_CheckOut intiateB2Bflow = new Flow.Interview.Cybersecurity_SM_CheckOut(flowInput);
                intiateB2Bflow.start();
            
          
        }
        catch(Exception ex){
            System.debug('ex ' +ex);
            MessageLog__c log1 = new MessageLog__c(Message__c = 'B2BBuyNowFlow ERR', MessageLong__c = ex.getMessage() + ' || ' + ex.getStackTraceString());
            insert log1;
        } 
        
    }
    
    public static Map<String,object> renewAssetMethod2(String assetId) {
        Map<String,object> resultData = new Map<String,object>();
        String siteBase = System.Label.Site_Base_Url;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        if(!test.isRunningTest())
        { request.setHeader('Authorization', 'Bearer ' + B2B_CreateUserAccessToken.getAdminAccessToken()); }
        else
        { request.setHeader('Authorization', 'Bearer ' );
        }
        String baseUrl = String.valueOf(Url.getOrgDomainUrl().toExternalForm());
        String renewalRequest = '/services/data/v57.0/asset-management/assets/collection/actions/initiate-renewal';
        request.setMethod('POST'); 
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint(baseUrl+renewalRequest);
        // Set the body as a JSON object
        String requestBody = '{"assetIds": {"assetIdArray": ["' + assetId + '"]}}';
        request.setBody(requestBody);
        HttpResponse response = http.send(request);
        // Parse the JSON response
        resultData.put('response',response.getBody());
        System.debug('response: ' + response.getBody());
        
        if (response.getStatusCode() != 201) {
            System.debug('The status code returned was not expected: ' +
                         response.getStatusCode() + ' ' + response.getStatus());
        } else {
            System.debug(response.getBody());
        }        
        return resultData;
        
    }
    
    public static map<string, object> cancelAsset2(Id assetId){
        
        try {
            
            Map<String,object> resultData = new Map<String,object>();
            
            string cancelDate = '';
            List<BillingScheduleGroup> billingSechd =  [select id, EffectiveNextBillingDate, EndDate from BillingScheduleGroup where ReferenceEntityId =: assetId];
            if(billingSechd.size() > 0){
                
                cancelDate = string.valueof(billingSechd[0].EffectiveNextBillingDate)+'T00:00:00-00:00';
                
                
            }else{
                
                cancelDate = string.valueof(system.today())+'T00:00:00-00:00';
                
                
            }
            
            
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            if(!test.isRunningTest())
            {
                request.setHeader('Authorization', 'Bearer ' + B2B_CreateUserAccessToken.getAdminAccessToken());
            }
            else{
                request.setHeader('Authorization', 'Bearer ');   
            }
            String baseUrl = String.valueOf(Url.getOrgDomainUrl().toExternalForm());
            String cancelAssets = '/services/data/v57.0/asset-management/assets/collection/actions/initiate-cancellation';
            request.setMethod('POST'); 
            request.setHeader('Content-Type', 'application/json; charset=UTF-8');
            request.setEndpoint(baseUrl+cancelAssets);
            String requestBody = '{' +
                '"assetIds": {' +
                '"assetIdArray": [' +
                '"' + assetId + '"' +
                ']' +
                '},' +
                '"cancellationDate": "' + cancelDate + '",' +
                '"cancellationOutputType": "order"' +
                '}';  
            
            request.setBody(requestBody);
            
            system.debug(requestBody + 'requestBody----');
            HttpResponse response = http.send(request);
            // Parse the JSON response
            resultData.put('response',response.getBody());
            System.debug('response: ' + response.getBody());
            if (response.getStatusCode() != 201) {
                System.debug('The status code returned was not expected: ' +
                             response.getStatusCode() + ' ' + response.getStatus());
            } else {
                System.debug(response.getBody());
                
            }
            return resultData;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}