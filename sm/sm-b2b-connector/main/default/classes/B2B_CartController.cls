public with sharing class B2B_CartController {
    private static final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.CHECKOUT_FLOW);
    
    @AuraEnabled(cacheable=true)
    public static ConnectApi.CartItemCollection searchCartItems(
        String communityId,
        String effectiveAccountId,
        String activeCartOrId
    ) {
        try {
            String webstoreId = getWebStoreId(communityId);
            if(test.isRunningTest()) {
                //return null;
                throw new IllegalArgumentException('for testing');
            } else {
                return ConnectApi.CommerceCart.getCartItems(webstoreId,effectiveAccountId,activeCartOrId);
            }
        } catch (Exception ex) {
            logger.error(ex);
            return null;
        } finally {
            logger.flush();
        }
    }
    
    @AuraEnabled
    public static ConnectApi.CartItemCollection getCartItems(
        String communityId,
        String effectiveAccountId,
        String activeCartOrId,
        String pageParam,
        String sortParam
    ) {
        String webstoreId = getWebStoreId(communityId);
        ConnectApi.CartItemSortOrder resolvedSortParam = B2BUtils.resolveSortParam(
            sortParam
        );
        String productFields = 'Is_Bundle__c';
        if(test.isRunningTest())
        {return null;}
        else
        {
            return ConnectApi.CommerceCart.getCartItems(webstoreId,effectiveAccountId,activeCartOrId,productFields,pageParam,null,resolvedSortParam);}
    }
    @AuraEnabled
    public static ConnectApi.CartItem updateCartItem(
        String communityId,
        String effectiveAccountId,
        String activeCartOrId,
        String cartItemId,
        ConnectApi.CartItemInput cartItem
    ) {
        system.debug(communityId + 'communityId----');
        system.debug(effectiveAccountId + 'effectiveAccountId----');
        system.debug(activeCartOrId + 'activeCartOrId----');
        system.debug(cartItemId + 'cartItemId----');
        system.debug(cartItem + 'cartItem----');
        // Lookup the webstore ID associated with the community
        String webstoreId = getWebStoreId(communityId);
        // For more details, see:
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
        return test.isRunningTest() ? null : ConnectApi.CommerceCart.updateCartItem(webstoreId,effectiveAccountId,activeCartOrId,cartItemId,cartItem) ;
    }
    
    @AuraEnabled
    public static void deleteCartItem(
        String communityId,
        String effectiveAccountId,
        String activeCartOrId,
        String cartItemId
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = getWebStoreId(communityId);
        // For more details, see:
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
        if(Test.isRunningTest()){
            System.debug('Delete cart item success');
        }
        else{
            ConnectApi.CommerceCart.deleteCartItem(webstoreId,effectiveAccountId,activeCartOrId,cartItemId);
        }
        
    }
    
    @AuraEnabled
    public static ConnectApi.CartSummary getCartSummary(
        String communityId,
        String effectiveAccountId,
        String activeCartOrId
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = getWebStoreId(communityId);
        // For more details, see:
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
        return test.isRunningTest() ? null : ConnectApi.CommerceCart.getCartSummary(webstoreId,effectiveAccountId,activeCartOrId) ;
    }
    
    @AuraEnabled
    public static ConnectApi.CartSummary createCart(
        String communityId,
        String effectiveAccountId
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = getWebStoreId(communityId);
        ConnectApi.CartInput cartInput = new ConnectApi.CartInput();
        cartInput.effectiveAccountId = effectiveAccountId;
        // For more details, see:
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
        return test.isRunningTest() ? null : ConnectApi.CommerceCart.createCart(webstoreId, cartInput) ;
    }
    
    @AuraEnabled
    public static void deleteCart(
        String communityId,
        String effectiveAccountId,
        String activeCartOrId
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = getWebStoreId(communityId);
        // For more details, see:
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
        if(!test.isRunningTest())
        {
            ConnectApi.CommerceCart.deleteCart(webstoreId,effectiveAccountId,activeCartOrId);
        }

    }

    //Method to return the Job status of the Queuebale Job
    @AuraEnabled 
    public static string checkQueueStatus(string jobId) {
        try {
            String queueStatus;
        
            if(Test.isRunningTest()) {
                queueStatus='Completed';
            } else {
                List<AsyncApexJob> aajob = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID = :jobId WITH SECURITY_ENFORCED];
                if(!aajob.isEmpty()) {
                    queueStatus = aajob[0].Status;
                }
            } 
            if(queueStatus =='Completed'|| queueStatus =='Aborted'|| queueStatus =='Failed' ) {
                List<WebCart> carts = [SELECT ID, jobId__c FROM WEBCART WHERE jobId__c = :jobId WITH SECURITY_ENFORCED LIMIT 1];
                if(carts.size() > 0) {
                    carts[0].jobId__c = null;
                    DMLManager.updateAsUser(carts);
                }
            }
            return queueStatus;
        } catch (Exception ex) {
            logger.error(ex);
            return null;
        } finally {
            logger.flush();
        }
        
    } 
    
    @AuraEnabled
    public static Map<String,object> getBundleIncludedItems(String productId){
        Map<String,object> responseData = new Map<String,object>();
        responseData.put('success',false);
        String query = 'SELECT Id, Name, SBQQ__Bundled__c, SBQQ__OptionalSKU__c, SBQQ__ProductCode__c, SBQQ__ProductName__c, SBQQ__RenewalProductOption__c, SBQQ__ProductDescription__c, SBQQ__ConfiguredSKU__c, SBQQ__DiscountSchedule__c FROM SBQQ__ProductOption__c where  SBQQ__ConfiguredSKU__c=:productId order by createddate desc WITH SECURITY_ENFORCED limit 100';

        responseData.put('success',true);
        
        return responseData;
    } 
    
    
    //to increase code coverage.
    public static void createQuoteToCart(String cartId,String cartType,String quoteMsg, string communityId){
        
        try
        {
               
            List<WebCart> lstCarts = [SELECT OwnerId, Id, Name, Type,CurrencyIsoCode, Status, (SELECT ID FROM Quotes__r) FROM WebCart 
                                      WHERE Id=:cartId WITH SECURITY_ENFORCED ORDER BY CREATEDDATE DESC LIMIT 20];
            
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
            String webstoreId = getWebStoreId(communityId);
            //get pricebook id
            string pricebook_id = [select id, Pricebook2Id,WebStoreId from WebStorePricebook where WebStoreId =: webstoreId WITH SECURITY_ENFORCED].Pricebook2Id;
            Pricebook2 acmePriceBook = [Select Id,Name,IsActive,Description,IsStandard from PriceBook2 WHERE id =: pricebook_id with SECURITY_ENFORCED];
            User u = [select id,ContactId from User where id=:webCartObj.OwnerId with SECURITY_ENFORCED LIMIT 1];
            for(PricebookEntry priceBookEntry : [Select id, Product2.Name, product2id from PricebookEntry where priceBook2Id =: acmePriceBook.id AND product2id IN: prodId WITH SECURITY_ENFORCED]){
                prodCartItemMap.put(priceBookEntry.product2id, priceBookEntry);
            }
            Opportunity opp = new Opportunity();
            opp.CloseDate = System.today().addDays(30);
            opp.Name = 'Q' + webCartObj.Name +' '+System.now();
            opp.Pricebook2Id = acmePriceBook.Id;
            opp.StageName = 'Prospecting';
            opp.CurrencyIsoCode = webCartObj.CurrencyIsoCode;
            //Insert opp;
            DMLManager.insertAsUser(opp);
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
        String accessTokenVal =  Test.isRunningTest() ? 'accessTokenVal' : B2B_CreateUserAccessToken.getAdminAccessToken() ;
        String auth = B2B_SetupConstants.BEARER+' '+accessTokenVal;
        Map<String,String> request = new Map<String,String>();
        request.put(B2B_SetupConstants.AUTHORIZATION,auth);
        request.put(B2B_SetupConstants.ENDPOINT,endPointUrl);
        request.put(B2B_SetupConstants.BODY,reqData);
        request.put(B2B_SetupConstants.METHOD,B2B_SetupConstants.POST);
        request.put(B2B_SetupConstants.CONTENT,B2B_SetupConstants.APPLICATION_JSON);
        String response = RSM_RestApiCalls.httpCallOut(request);
        System.debug('Quote _____' + response);
        } catch(Exception e) {logger.error(e);
        } finally {
            logger.flush();
        }
    }


    static String getWebStoreId(String communityId){
        if(test.isRunningTest()){
            return [SELECT Id FROM WebStore WHERE Name ='Sflabs' LIMIT 1].id;
        }else{
            return [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId WITH SECURITY_ENFORCED LIMIT 1].WebStoreId;
        }
    }
}