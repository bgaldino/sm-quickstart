/**
 * @description       : This class use to create Quote and Quote line in case of Discount is requested.
 * 
**/

@RestResource(urlMapping='/B2BCartToQuoteRestService/')
global with sharing class  RSM_MakeCPQQuoteAPICallout {

    private static final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.REQUEST_DISCOUNT);

    /**
     * Creates new quote based on the Cart.
     * @param cartId, CartType, QuoteMesage, Community Id
     * @return Newly created Quote data
    **/

    @HttpPost
    global static void createQuoteToCart(String cartId,String cartType,String quoteMsg, string communityId){

       try
       {

       //removed WITH SECURITY_ENFORCED from soql
        List<WebCart> lstCarts = [SELECT OwnerId, Id, Name, Type,CurrencyIsoCode, Status, (SELECT ID FROM Quotes__r) FROM WebCart 
        WHERE Id=:cartId ORDER BY CREATEDDATE DESC LIMIT 20];
        
       
        WebCart cartObj = lstCarts[0];
        if(cartType == 'New' || cartType == 'RFQ')
        createNewQuote(cartId,quoteMsg,cartType == 'RFQ'?true:false, communityId);
        
       }   
       
       catch (Exception ex) {
        logger.error(ex);
       }finally{
        logger.flush();
       }
       
    }

     /**
     * Creates new Quote using composite API.
     * @param reqData - Payload Quote and Quote Lines
     * @return Newly created Quote data
    **/
    @Future(callout=true)
    public static void createNewSFQuote(String reqData){
        try{
         String baseUrl = String.valueOf(Url.getOrgDomainUrl().toExternalForm());
         String endPointUrl;
         if(String.isNotBlank(baseUrl)){
             endPointUrl = baseUrl + '/services/data/v56.0/composite';
         }
         String accessTokenVal = B2B_CreateUserAccessToken.getAdminAccessToken();
         String auth = B2B_SetupConstants.BEARER+' '+accessTokenVal;
         
         Map<String,String> request = new Map<String,String>();
         request.put(B2B_SetupConstants.AUTHORIZATION,auth);
         request.put(B2B_SetupConstants.ENDPOINT,endPointUrl);
         request.put(B2B_SetupConstants.BODY,reqData);
         request.put(B2B_SetupConstants.METHOD,B2B_SetupConstants.POST);
         request.put(B2B_SetupConstants.CONTENT,B2B_SetupConstants.APPLICATION_JSON);
         String response = RSM_RestApiCalls.httpCallOut(request);
         logger.debug(JSON.serialize(response));
        }catch(Exception e){
            logger.error(e);
        }finally{
            logger.flush();
        }

    }

     /**
     * @param cartId, CartType, QuoteMesage, Community Id
     * @return Newly created Quote data
    **/
    public static String createNewQuote(String cartId,String quoteMsg,Boolean IsRFQ, string communityId){

      ID jobID ;

      try
       {
         
       
         WebCart webCartObj = RSM_Utils.getCartDetails(cartId);
         List<cartItem> lstcartItems = RSM_Utils.getCartItemsByCartId(cartId);
         Set<id> prodId = new set<id>();
         Set<Id> price_bookenryId = new set<Id>();
         Map<string, PricebookEntry> prodCartItemMap = New map<String, PricebookEntry>();
         Map<string, string> sellingModel = New map<String, string>();
         

         if(lstcartItems.size() > 0){

            for(cartItem cartItem : lstcartItems){

                prodId.add(cartItem.Product2Id);
                price_bookenryId.add(cartItem.B2B_PriceBookEntry_Id__c);

            }
         }

         String webstoreId = Test.isRunningTest() ? [SELECT Id FROM WebStore WHERE Name ='Sflabs' LIMIT 1].Id : [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId WITH SECURITY_ENFORCED LIMIT 1].WebStoreId;

         //get pricebook id
         //WITH SECURITY_ENFORCED removed from below soql
         string pricebook_id = [select id, Pricebook2Id,WebStoreId from WebStorePricebook where WebStoreId =: webstoreId AND pricebook2.isActive=true].Pricebook2Id;

         Pricebook2 acmePriceBook = [Select Id,Name,IsActive,Description,IsStandard from PriceBook2 WHERE id =: pricebook_id WITH SECURITY_ENFORCED];


         User u = [select id,ContactId from User where id=:webCartObj.OwnerId WITH SECURITY_ENFORCED LIMIT 1];

        List<PricebookEntry> prices = [SELECT id, UnitPrice, ProductSellingModelId, ProductSellingModel.SellingModelType, ProductSellingModel.PricingTerm, ProductSellingModel.PricingTermUnit, Product2Id FROM PricebookEntry WHERE Pricebook2Id =: acmePriceBook.Id AND ProductSellingModelId != null AND Id IN: price_bookenryId WITH SECURITY_ENFORCED];

        for(PricebookEntry priceentry : prices){

             sellingModel.put(priceentry.id, priceentry.ProductSellingModel.SellingModelType);


        }
          

         Opportunity opp = new Opportunity();
         opp.CloseDate = System.today().addDays(30);
         opp.Name = 'Q' + webCartObj.Name +' '+System.now();
         opp.Pricebook2Id = acmePriceBook.Id;
         opp.StageName = 'Prospecting';
         
         opp.CurrencyIsoCode = webCartObj.CurrencyIsoCode;
         //Insert opp; //update due to securit review.
         //DMLManager.insertAsUser(opp);
         DMLManager.insertAsSystem(opp);

         String reqDataItems = '';
         Integer n = 1;
         String priceBookIdStr = webCartObj.B2B_PriceBook_Id__c;

        ConnectApi.CartCouponCollection cartCouponsResult = Test.isRunningTest() ? new ConnectApi.CartCouponCollection() : ConnectApi.CommerceCart.getCartCoupons(webStoreId, webCartObj.AccountId, cartId);
        if(Test.isRunningTest()) {
            ConnectApi.CartCouponList cartCoupon = new ConnectApi.CartCouponList();
            List<ConnectApi.CartCoupon> coupons = new List<ConnectApi.CartCoupon>();
            ConnectApi.CartCoupon coupon = new ConnectApi.CartCoupon();
            coupon.couponCode = 'testCode';
            coupons.add(coupon);
            cartCoupon.coupons = coupons;
            cartCouponsResult.cartCoupons = cartCoupon;
        }
         for(CartItem c : lstcartItems)
         {
          
        if(sellingModel.containsKey(c.B2B_PriceBookEntry_Id__c)){
            string billingFreq = '';
            string endDateQuoteLine = '';

             if(sellingModel.get(c.B2B_PriceBookEntry_Id__c) == 'TermDefined'){
                 Integer daysInMonth = Date.daysInMonth(system.today().Year(), system.today().Month());
                 if(daysInMonth == 31){
                    endDateQuoteLine =  '"EndDate":"' + string.valueOf(System.today().addDays(daysInMonth-2))+ '",';
                 }else{
                    endDateQuoteLine =  '"EndDate":"' + string.valueOf(System.today().addDays(daysInMonth-1))+ '",';
                 }
             }

             if(sellingModel.get(c.B2B_PriceBookEntry_Id__c) != 'OneTime'){
                billingFreq =  '"BillingFrequency": "Monthly",';
                
             } 

                reqDataItems += '    {'+
                '      "method": "POST",'+
                '      "url": "/services/data/v56.0/sobjects/Quotelineitem",'+
                '      "referenceId": "newQuotelineitem'+String.valueOf(n)+'",'+
                '      "body": {'+
                '        "QuoteId": "@{NewQuote.id}",'+
                '        "Quantity": '+String.valueOf(c.Quantity)+','+
                '        "UnitPrice": '+String.valueOf(c.ListPrice)+','+
                '        "Discount": 0,'+
                '        "Product2Id": "'+c.Product2Id+'",'+
                '        "PricebookEntryId":"'+c.B2B_PriceBookEntry_Id__c+'",'+
                '         "r1sm__cartitemid__c":"'+c.id+'",'+
                         (billingFreq != null ? billingFreq : '') + 
                '         "StartDate":"' + string.valueOf(System.today()) + '",'+  
                          (endDateQuoteLine != null ? endDateQuoteLine : '') + 
                '        "Description":"'+ quoteMsg +'"'+
                '      }'+
                '      }'+(n == lstcartItems.size() ? '' : ',');
                n++;

            }
        }

         String reqData =       '{'+
        '  "allOrNone": true,'+
        '  "compositeRequest": ['+
        '    {'+
        '      "method": "POST",'+
        '      "url": "/services/data/v56.0/sobjects/Quote",'+
        '      "referenceId": "NewQuote",'+
        '      "body": {'+
        '        "Name": "'+webCartObj.Name+'",'+
        '        "r1sm__Cart__c": "'+cartId+'",'+
        '        "PriceBook2Id":"'+acmePriceBook.id+'",'+
        '        "OpportunityId": "'+opp.Id+'",'+
        '        "Description":"'+quoteMsg+'",'+
        '        "r1sm__Is_Coupon_Applied__c":"'+!cartCouponsResult.cartCoupons.coupons.isEmpty()+'"'+
        '     '+
        '      }'+
        '    },'+
        '    {'+
        '      "method": "GET",'+
        '      "referenceId": "NewQuoteInfo",'+
        '      "url": "/services/data/v56.0/sobjects/Quote/@{NewQuote.id}"'+
        '    },'+
            reqDataItems+
        '  ]'+
        '}';

        logger.debug(JSON.serialize(reqData));
        createNewSFQuote(reqData);
      
       }   
       
       catch (Exception ex) {
        logger.error(ex);
       }finally{
        logger.flush();
       }

       return jobID;
    }

}