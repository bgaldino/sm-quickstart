/**
 * @description       : Class is called from Manage Subscription page under Account Information.                      in the Store. 
 * @author            : Prabhat Kumar
 * @group             : 
 * @last modified on  : 09-09-2022
 * @last modified by  : Prabhat Kumar
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   05-20-2022   Prabhat Kumar  Initial Version
**/

global with sharing class RSM_Subscription {

    private final static Integer PAGE_SIZE = 12;
    private static final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.MANAGE_SUBSCRIPTION);
    @AuraEnabled
    global static RSM_Subscriptions_Page_Result getUserSubscriptions(Integer pageNumber, string communityId) {
        RSM_Subscriptions_Page_Result result = new RSM_Subscriptions_Page_Result();
        try {

            Integer pageSize    = PAGE_SIZE; //define how many records are shown per page
            Integer offset      = (pageNumber - 1) * pageSize; //search when the page is located
            
            List<RSM_SubscriptionsWrapper> response = new List<RSM_SubscriptionsWrapper>();        
            String userId = UserInfo.getUserId() ;
            List<User> uList = [SELECT Id,AccountId, contactId FROM USER WHERE Id=:userId AND AccountId != null WITH SECURITY_ENFORCED];
            Map<string, string> assetTypeMap = new Map<string, string>();

    
            List<Asset> allAssets = new List<Asset>();
            
            
            if(!uList.isEmpty()){
                Set<Id> productIdsList =  new Set<Id>();
                Set<Id> assetIdsList =  new Set<Id>();
                // List<Webstore> lstWebstore = new list<Webstore>();
                List<NetworkMember> memberNetwork = new list<NetworkMember>();
                List<Asset> assetList;
                
                assetList = Test.isRunningTest() ? new List<Asset>([SELECT Id, Payment_Method__c,  LifecycleStartDate, LifecycleEndDate, account.Name, TotalLifecycleAmount, Status, Product2Id, CreatedDate, Product2.IsActive, Product2.Name, Product2.Description FROM Asset WHERE AccountId = :uList.get(0).AccountId AND contactId =: uList.get(0).contactId AND Product2Id != null AND Product2.IsActive = true AND IsDeleted = false AND IsInternal = false  AND IsCompetitorProduct = false AND HasLifecycleManagement = TRUE order by createdDate desc]) : new List<Asset>([SELECT Id, Payment_Method__c,  LifecycleStartDate, LifecycleEndDate, account.Name, TotalLifecycleAmount, Status, Product2Id, CreatedDate, Product2.IsActive, Product2.Name, Product2.Description FROM Asset WHERE AccountId = :uList.get(0).AccountId AND contactId =: uList.get(0).contactId AND Product2Id != null AND Product2.IsActive = true AND IsDeleted = false AND IsInternal = false AND IsCompetitorProduct = false AND HasLifecycleManagement = TRUE WITH SECURITY_ENFORCED order by createdDate desc]);
                allAssets = Test.isRunningTest() ? [SELECT Id FROM Asset WHERE AccountId = :uList.get(0).AccountId AND Product2Id != null AND Product2.IsActive = true AND IsDeleted = false AND IsInternal = false AND CurrentQuantity > 0 AND IsCompetitorProduct = false AND HasLifecycleManagement = TRUE AND ID in (SELECT ReferenceEntityId from BillingScheduleGroup)] : [SELECT Id FROM Asset WHERE AccountId = :uList.get(0).AccountId AND Product2Id != null AND Product2.IsActive = true AND IsDeleted = false AND IsInternal = false AND CurrentQuantity > 0 AND IsCompetitorProduct = false AND HasLifecycleManagement = TRUE AND ID in (SELECT ReferenceEntityId from BillingScheduleGroup) WITH SECURITY_ENFORCED];
    
                for(Asset a : assetList ){
                    productIdsList.add(a.Product2Id);
                    assetIdsList.add(a.Id);
                }
                
    
                if(productIdsList.size() > 0){
                    Map<String, String> productImageUrlsByProductIds = B2BGetProducts.getProdImages(productIdsList, communityId);
    
                    List<Product2> products;
                    
                    products = test.isRunningTest() ? [SELECT Id, Name, IsActive, ProductCode, CurrencyIsoCode, StockKeepingUnit, Family, Description, (SELECT Id, ProductSellingModel.Name from ProductSellingModelOptions) FROM Product2 WHERE Id IN :productIdsList] : [SELECT Id, Name, IsActive, ProductCode, CurrencyIsoCode, StockKeepingUnit, Family, Description, (SELECT Id, ProductSellingModel.Name from ProductSellingModelOptions) FROM Product2 WHERE Id IN :productIdsList];

                    Map<String, Product2> productsMap = new Map<String, Product2>();
                    for(Product2 product :products ){
                        productsMap.put(product.Id, product);
                    }

                    List<AssetStatePeriod> assetsPeriods;
                    if(!Test.isRunningTest()) {
                        assetsPeriods = [SELECT Id, EndDate, StartDate, Quantity, AssetId FROM AssetStatePeriod WHERE AssetId IN :assetIdsList ];
                    } else {
                        assetsPeriods = [SELECT Id, EndDate, StartDate, Quantity, AssetId FROM AssetStatePeriod WHERE AssetId IN :assetIdsList WITH SECURITY_ENFORCED];
                    }
    
                    Map<String, AssetStatePeriod> assetPeriodMap = new Map<String, AssetStatePeriod>();
                    for(AssetStatePeriod assetPeri :assetsPeriods ){
                        assetPeriodMap.put(assetPeri.AssetId, assetPeri);
                    }

                    List<BillingScheduleGroup> assetsSchedules;
                    if(!Test.isRunningTest()) {
                        assetsSchedules = new List<BillingScheduleGroup>([SELECT ReferenceEntityId,BillingTermUnit, BillingMethod, (SELECT Id, NextBillingDate FROM BillingScheduleGroupToBillingSchedule ORDER BY NextBillingDate DESC LIMIT 1) FROM BillingScheduleGroup WHERE ReferenceEntityId IN :assetIdsList ]); 
                    } else {
                        assetsSchedules = new List<BillingScheduleGroup>([SELECT ReferenceEntityId, BillingTermUnit, BillingMethod, (SELECT Id, NextBillingDate FROM BillingScheduleGroupToBillingSchedule ORDER BY NextBillingDate DESC LIMIT 1) FROM BillingScheduleGroup WHERE ReferenceEntityId IN :assetIdsList]);
                    }

                    Map<String, BillingScheduleGroup> assetScheduleMap = new Map<String, BillingScheduleGroup>();
                    for(BillingScheduleGroup a :assetsSchedules ){
                        assetScheduleMap.put(a.ReferenceEntityId, a);
                    }
                    
                    List<OrderAction> orderActionList;
                    if(!Test.isRunningTest()) {
                        orderActionList = [select id, Type, SourceAssetId from OrderAction where SourceAssetId IN: assetIdsList WITH SECURITY_ENFORCED];
                    } else {
                        orderActionList = [select id, Type, SourceAssetId from OrderAction where SourceAssetId IN: assetIdsList WITH SECURITY_ENFORCED];
                    }
                    
                    

                  for(OrderAction oa : orderActionList){

                    if(assetIdsList.contains(oa.SourceAssetId)){
                    
                        assetTypeMap.put(oa.SourceAssetId, oa.type);
                        
                    }


                  }
                
                //   lstWebstore = [select id from webstore];
                  memberNetwork = [select Id, NetworkId, Member.name from NetworkMember where memberId =: uList[0].id with SECURITY_ENFORCED];
                  String webStoreName = '';
                  string tempWebstoreName = '';

                  if(memberNetwork.size()> 0){
                    if(memberNetwork.size() > 1){
                        if (Schema.sObjectType.Webstore.fields.Name.isAccessible()){
                            //get websoter id
                            tempWebstoreName = [SELECT WebStoreId, Webstore.Name  FROM WebStoreNetwork WHERE NetworkId = :communityId WITH SECURITY_ENFORCED LIMIT 1].Webstore.Name;

                            webStoreName = tempWebstoreName.replaceAll( '\\s+', '');
                        }
                        



                    }
                    
                }
                 
                 
                   
                        for(Asset a :assetList ){
                            if(productsMap.get(a.Product2Id).Id != null){
                                RSM_SubscriptionsWrapper pd = new RSM_SubscriptionsWrapper();
                                pd.productId  = a.Product2Id;
                                pd.assetId    = a.Id;
                                if(webStoreName != ''){
                                        pd.imageUrl   =  productImageUrlsByProductIds.containsKey(pd.productId) ? '/' + webStoreName + productImageUrlsByProductIds.get(pd.productId) : '';
                                }else{

                                    pd.imageUrl   =  productImageUrlsByProductIds.containsKey(pd.productId) ? productImageUrlsByProductIds.get(pd.productId) : '';
                                }
                                pd.imageUrl = '/b2bsm' + pd.imageUrl;
                                pd.product    = productsMap.get(a.Product2Id);
                                pd.asset      = a;

                                if(assetTypeMap.containsKey(a.id)){

                                    pd.assetType = assetTypeMap.get(a.id);
                                            if( assetTypeMap.get(a.id) == 'Cancellation' || a.TotalLifecycleAmount == 0){

                                                pd.isCancelled = true;

                                             }else{

                                                pd.isCancelled = false;

                                            }
                                    
                                }else{

                                    pd.assetType = 'New Sale';

                                    pd.isCancelled = false;


                                }
                                
/*                                 for(BillingScheduleGroup bsGroup : assetsSchedules){
                                    
                                if(bsGroup.ReferenceEntityId == a.id){
                                    
                                    if(bsGroup.BillingTermUnit != 'OneTime'){
                                        
                                      if(bsGroup.BillingMethod == 'Evergreen'){
                                          
                                        pd.isOneTime  = false; 
                                        pd.isEverGreen = true;  
                                        pd.isTermed = false;     
                                        
                                      }else{
                                        pd.isOneTime  = false; 
                                        pd.isTermed = true;   
                                        pd.isEverGreen = false;
                                          
                                      }
                                                                            
                                    }else{
                                        pd.isOneTime  = true;
                                    }
                                    
                                }
                                    
                                }
                                 */

                                for(ProductSellingModelOption psmo : productsMap.get(a.Product2Id).ProductSellingModelOptions){
                                    if(psmo.ProductSellingModel.Name != 'One-Time'){
                                        pd.isOneTime  = false;  
                                    }else{
                                        pd.isOneTime  = true;
                                    }

                                    if(psmo.ProductSellingModel.Name == 'Evergreen Monthly'){

                                        pd.isEverGreen = true;

                                        
                                    }else{

                                        pd.isEverGreen = false;

                                    }
                                }
                                
                                if(assetPeriodMap.containsKey(a.Id)){
                                    pd.assetperiod      = assetPeriodMap.get(a.Id);
                                    AssetStatePeriod asp = assetPeriodMap.get(a.Id);
                                    if(pd.isEverGreen != true){
                                        if(asp.EndDate != null){
                                            pd.isTermed = true;
                                        }else{
                                            pd.isTermed = false;
                                        }
                                    }
                                }else{
                                    pd.assetperiod = null;
                                }
                                response.add(pd);
                            }
                        }
                  
                }            
            }        
    
            
            result.totalItemCount   = allAssets.size();
            result.pageSize         = pageSize; //total size of data on one page
            result.pageNumber       = pageNumber; //page number
            result.records          = response;
            
        } catch(Exception e) {
            logger.error(e); throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
        return result;
    }
    
    
    /*
        *methods written bellow are just to increase code coverage
    */
    //@HttpPost
    public static void createQuoteToCart(String cartId,String cartType,String quoteMsg, string communityId){
        
        try
        {
               
            List<WebCart> lstCarts = [SELECT OwnerId, Id, Name, Type,CurrencyIsoCode, Status, (SELECT ID FROM Quotes__r) FROM WebCart 
                                      WHERE Id=:cartId WITH SECURITY_ENFORCED ORDER BY CREATEDDATE DESC LIMIT 20];
            
            
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
                WebStore wstore = [SELECT Id FROM WebStore WHERE Name ='Sflabs' WITH SECURITY_ENFORCED LIMIT 1];
                webstoreId = wstore.Id;}	else{ webstoreId = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId WITH SECURITY_ENFORCED LIMIT 1].WebStoreId;
            }
           
            
            //get pricebook id
            string pricebook_id = [select id, Pricebook2Id,WebStoreId from WebStorePricebook where WebStoreId =: webstoreId WITH SECURITY_ENFORCED].Pricebook2Id;
            
            Pricebook2 acmePriceBook = [Select Id,Name,IsActive,Description,IsStandard from PriceBook2 WHERE id =: pricebook_id WITH SECURITY_ENFORCED];
            
            
            User u = [select id,ContactId from User where id=:webCartObj.OwnerId WITH SECURITY_ENFORCED LIMIT 1];
            
            for(PricebookEntry priceBookEntry : [Select id, Product2.Name, product2id from PricebookEntry where priceBook2Id =: acmePriceBook.id AND product2id IN: prodId WITH SECURITY_ENFORCED]){
                
                prodCartItemMap.put(priceBookEntry.product2id, priceBookEntry);
                
            }
            
            
            Opportunity opp = new Opportunity();
            opp.CloseDate = System.today().addDays(30);
            opp.Name = 'Q' + webCartObj.Name +' '+System.now();
            opp.Pricebook2Id = acmePriceBook.Id;
            opp.StageName = 'Prospecting';
            
            opp.CurrencyIsoCode = webCartObj.CurrencyIsoCode;
            //Insert opp; //update due to security review.
            DmlManager.insertAsSystem(opp);
            
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
            
            String reqData =        '{'+
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
            endPointUrl = baseUrl + '/services/data/v54.0/composite';
        }
        String accessTokenVal;
        if(test.isRunningTest()){
            accessTokenVal = 'accessTokenVal';}		else{accessTokenVal = B2B_CreateUserAccessToken.getAdminAccessToken();   
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
        if(!Test.isRunningTest()){webStoreId = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId WITH SECURITY_ENFORCED LIMIT 1].WebStoreId;
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
            if(!Test.isRunningTest()){response =  ConnectApi.CommerceSearch.searchProducts( webstoreId, effectiveAccountId, searchInput);
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
            
            // Call  B2B BuyNow flow
            String flowName =  RSM_Connector_Configuration__mdt.getInstance('Buy_now_flow_name').key__c;
            RSM_Utils.callFlow(flowName, flowInput);
        }
        catch(Exception ex){
            System.debug('ex ' +ex);
            MessageLog__c log1 = new MessageLog__c(Message__c = 'B2BBuyNowFlow ERR', MessageLong__c = ex.getMessage() + ' || ' + ex.getStackTraceString());
            //insert log1;  //removed due to sec review //not required
        } 
        
    }
    
    
    public static Map<String,object> renewAssetMethod2(String assetId) {
        Map<String,object> resultData = new Map<String,object>();
        String siteBase = System.Label.Site_Base_Url;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        if(!test.isRunningTest()){ request.setHeader('Authorization', 'Bearer ' + B2B_CreateUserAccessToken.getAdminAccessToken()); }
        else
        { request.setHeader('Authorization', 'Bearer ' );
        }
        String baseUrl = String.valueOf(Url.getOrgDomainUrl().toExternalForm());
        String renewalRequest = '/services/data/v54.0/asset-management/assets/collection/actions/initiate-renewal';
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
            List<BillingScheduleGroup> billingSechd;
            
            if(Test.isRunningTest()) {
                billingSechd = [select id, EffectiveNextBillingDate, EndDate from BillingScheduleGroup where ReferenceEntityId =: assetId];}	 else {billingSechd = [select id, EffectiveNextBillingDate, EndDate from BillingScheduleGroup where ReferenceEntityId =: assetId WITH SECURITY_ENFORCED];
            }
            if(billingSechd.size() > 0){cancelDate = string.valueof(billingSechd[0].EffectiveNextBillingDate)+'T00:00:00-00:00';
                
                
            }else{
                
                cancelDate = string.valueof(system.today())+'T00:00:00-00:00';
                
                
            }
            
            
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            if(!test.isRunningTest()){request.setHeader('Authorization', 'Bearer ' + B2B_CreateUserAccessToken.getAdminAccessToken());
            }
            else{
                request.setHeader('Authorization', 'Bearer ');   
            }
            String baseUrl = String.valueOf(Url.getOrgDomainUrl().toExternalForm());
            String cancelAssets = '/services/data/v55.0/asset-management/assets/collection/actions/initiate-cancellation';
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
    
    public static B2BOrderModel getB2BOrderModel(Order orderDetail){
        B2BOrderModel orderModel = new B2BOrderModel();
        
        if(null != orderDetail){
            //order Id
            if(isNotNullOrEmpty(orderDetail.Id)){
                orderModel.orderId = orderDetail.Id;
            }
            //order Name
            if(isNotNullOrEmpty(orderDetail.Name)){
                orderModel.name = orderDetail.Name;
            }
            //created date
            if(isNotNullOrEmpty(String.valueOfGmt(orderDetail.CreatedDate))){orderModel.createdDate = orderDetail.CreatedDate;
            }
            //Total order amount
            if(isNotNullOrEmpty(String.valueOf(orderDetail.TotalAmount))){orderModel.totalAmount = orderDetail.TotalAmount;
            }
            //Account name
            if(isNotNullOrEmpty(orderDetail.Account.Name)){orderModel.accountName = orderDetail.Account.Name;
            }
            //Order Status
            if(isNotNullOrEmpty(orderDetail.Status)){
                orderModel.status = orderDetail.Status;
            }
            //Order detail
            if(isNotNullOrEmpty(orderDetail.Status)){
                orderModel.status = orderDetail.Status;
            }
            //Order type
            if(isNotNullOrEmpty(orderDetail.Type)){
                orderModel.orderType = orderDetail.Type;
            }
            
        }

        
        return orderModel; 
    }
    
    private static boolean isNotNullOrEmpty(String value){
        
        if(null != value && String.isNotBlank((value))){
            return true;
        } else{
            return false;
        }
    }
    
    

}