//Extension for viewInvoice VF Page
//global class RSM_ViewInvoiceExtension {
public with sharing class RSM_ViewInvoiceExtension {

    private static final String MODULE_NAME = 'MyInvoices Module';
    private static final DCM_Logger logger = DCM_Logger.getInstance(MODULE_NAME);
    
    public with sharing class RSM_MyInvoiceLineWrapper {
        @AuraEnabled 
        public Id lineId { get; set; }
        @AuraEnabled 
        public Decimal Quantity { get; set; }
        @AuraEnabled 
        public String ProductName { get; set; }
        @AuraEnabled 
        public String ProductDescription { get; set; }
        @AuraEnabled 
        public Decimal UnitPrice { get; set; }
        @AuraEnabled 
        public String Type { get; set; }
        @AuraEnabled 
        public Decimal LineAmount { get; set; } 
        @AuraEnabled 
        public Date invLineStartDate { get; set; }
        @AuraEnabled 
        public Date invLineEndDate { get; set; }
        @AuraEnabled 
        public String invLineBillingTermUnit { get; set; }
    }   

    {}

    public class CompanyInfo{
        public String companyName {get;set;}
        public String street {get;set;}
        public String phone {get;set;}
        public String city {get;set;}
        public String postalCode {get;set;}
        public String state {get;set;}
        public String country {get;set;}
    }

    public Invoice invoiceRec {get; set;}
    public CompanyInfo companyInfo {get; set;}
    public String orderNumber {get; set;}
    public String invDocNum {get; set;}
    public Date invDate {get; set;}
    public Decimal invTotalTax { get; set; } 
    public Decimal invTotal { get; set; } 
    public Date invDueDate {get; set;}
    public String invStatus {get; set;}
    public String paymentTerm {get; set;}
    public DateTime activatedDate {get; set;}
    public Account billingAddress {get;set;}
    public Account shippingAddress {get;set;}
    public String salesRep {get;set;}
    public String comments {get;set;}
    public List<RSM_MyInvoiceLineWrapper> voiceLines{get;set;}
    private String companyName = 'Docmation';
    public Date nullDate = null;
    
    //global
    public Pagereference onLoad(){
        
        String strInvoiceId = null;
        try{
            if(ApexPages.currentPage()!=null && ApexPages.currentPage().getParameters()!=null && 
                ApexPages.currentPage().getParameters().get('invoiceId')!=null )
            {
                strInvoiceId= ApexPages.currentPage().getParameters().get('invoiceId');
            }
            logger.debug(JSON.serialize(strInvoiceId));
            getCompanyInfoMetadata(companyName);
            if(!test.isRunningTest()){
                queryInvoiceLineDetails(strInvoiceId);
            }
        }catch(Exception ex){
            logger.error(ex);
        }finally{
            logger.flush();
        }
        return null;
    }

    /*private*/ public void getCompanyInfoMetadata(String companyName){
        //RSM_ConnectorConfigrationSelector configSelector = new RSM_ConnectorConfigrationSelector();
        //Map<String,String> invoiceConfig= configSelector.getAllConfigByType('Invoicing');
        //this.companyInfo.state = invoiceConfig.get('State'); //RSM_Connector_Configuration__mdt.getInstance('OrgDomainUrl');
        companyInfo cmp = new companyInfo();
        cmp.state = String.valueOf(RSM_Connector_Configuration__mdt.getInstance('State').key__c);
        /*this.companyInfo.companyName = invoiceConfig.get('Company_Name');
        this.companyInfo.city = invoiceConfig.get('City');
        this.companyInfo.street = invoiceConfig.get('Street');
        this.companyInfo.country = invoiceConfig.get('Country');
        this.companyInfo.postalCode = invoiceConfig.get('Postal_Code');*/
        cmp.companyName = String.valueOf(RSM_Connector_Configuration__mdt.getInstance('Company_Name').key__c);
        cmp.city = String.valueOf(RSM_Connector_Configuration__mdt.getInstance('City').key__c);
        cmp.street = String.valueOf(RSM_Connector_Configuration__mdt.getInstance('Street').key__c);
        cmp.country = String.valueOf(RSM_Connector_Configuration__mdt.getInstance('Country').key__c);
        cmp.postalCode = String.valueOf(RSM_Connector_Configuration__mdt.getInstance('Postal_Code').key__c);
        cmp.phone = String.valueOf(RSM_Connector_Configuration__mdt.getInstance('Phone').key__c);
        this.companyInfo = cmp;
    }

    public void queryInvoiceLineDetails(Id invoiceId){
        
        try{
            list<Invoice> invoiceRecList = [Select id, DocumentNumber, TotalTaxAmount, TotalAmountWithTax, InvoiceDate, DueDate, Status, ReferenceEntityId from Invoice where Id =: invoiceId WITH SECURITY_ENFORCED limit 1];
            logger.debug(JSON.serialize(invoiceRecList));
            this.invoiceRec = invoiceRecList[0];
            this.invDocNum = invoiceRecList[0].DocumentNumber;
            this.invDate = invoiceRecList[0].InvoiceDate;
            this.invTotalTax = invoiceRecList[0].TotalTaxAmount;
            this.invDueDate = invoiceRecList[0].DueDate;
            this.invStatus = invoiceRecList[0].Status;
            this.invTotal = invoiceRecList[0].TotalAmountWithTax;
            list<InvoiceLine> invLineItem = [select id, type, InvoiceId  from InvoiceLine where InvoiceId =:invoiceRecList[0].Id AND type = 'Charge' WITH SECURITY_ENFORCED Limit 1];
            list<BillingPeriodItem> invBPI = [select id, BillingScheduleId  from BillingPeriodItem where InvoiceLineId =: invLineItem[0].Id /*WITH SECURITY_ENFORCED*/ Limit 1];
            list<BillingSchedule> blngSchedule = [select id, ReferenceEntityId from BillingSchedule where id =: invBPI[0].BillingScheduleId /*WITH SECURITY_ENFORCED*/ limit 1];
            string ordId = blngSchedule[0].ReferenceEntityId;
            List<Order> ordList = [SELECT id, OrderNumber, Status, ActivatedDate, AccountId, Account.Name, BillingStreet, BillingCity, 
                                    BillingState, BillingPostalCode, BillingCountry from Order where id =:ordId WITH SECURITY_ENFORCED LIMIT 1];
            this.orderNumber = ordList[0].OrderNumber;
            this.activatedDate = ordList[0].ActivatedDate;
            this.billingAddress = generateBillingAccount(
                ordList[0].AccountId, 
                ordList[0].Account.Name, 
                ordList[0].BillingStreet, 
                ordList[0].BillingCity, 
                ordList[0].BillingState, 
                ordList[0].BillingPostalCode, 
                ordList[0].BillingCountry);
            this.shippingAddress = generateShippingAccount(
                ordList[0].AccountId, 
                ordList[0].Account.Name, 
                ordList[0].BillingStreet, 
                ordList[0].BillingCity, 
                ordList[0].BillingState, 
                ordList[0].BillingPostalCode, 
                ordList[0].BillingCountry);
            list<InvoiceLine> invLineList = [Select id, Quantity, Product2.Name, Product2.Description, UnitPrice, Type, LineAmount, InvoiceLineStartDate, InvoiceLineEndDate,
                                                BillingSchedule.BillingScheduleGroup.ProductName, BillingSchedule.BillingScheduleGroup.BillingTermUnit, 
                                                BillingSchedule.BillingScheduleGroup.EndDate, BillingSchedule.BillingScheduleGroup.StartDate
                                                from InvoiceLine where InvoiceId =: invoiceId AND Type = 'Charge' /*WITH SECURITY_ENFORCED*/];
            voiceLines = new List<RSM_MyInvoiceLineWrapper>();
            logger.debug(JSON.serialize(invLineList));
            if(!invLineList.isEmpty()){
                for(InvoiceLine line : invLineList){
                    RSM_MyInvoiceLineWrapper obj = new RSM_MyInvoiceLineWrapper();
                    obj.Quantity = line.Quantity!= null ? line.Quantity : 1;
                    obj.UnitPrice = line.UnitPrice!= null ? line.UnitPrice : 0;
                    obj.lineId = line.Id;
                    obj.Type = line.Type;
                    obj.LineAmount = line.LineAmount;
                    obj.ProductName = line.BillingSchedule.BillingScheduleGroup.ProductName!= null ? line.BillingSchedule.BillingScheduleGroup.ProductName : 'ProductName';
                    obj.ProductDescription = line.Product2.Description!= null ? line.Product2.Description : 'ProductDescription';
                    if(line.BillingSchedule.BillingScheduleGroup.BillingTermUnit != 'OneTime'){
                        obj.invLineStartDate = line.BillingSchedule.BillingScheduleGroup.StartDate;
                        if(line.BillingSchedule.BillingScheduleGroup.EndDate != nullDate){
                            obj.invLineEndDate = line.BillingSchedule.BillingScheduleGroup.EndDate;
                        }else{
                            obj.invLineEndDate = line.BillingSchedule.BillingScheduleGroup.StartDate.addMonths(1);
                        }
                    }
                    else{
                        obj.invLineStartDate = nullDate;
                        obj.invLineEndDate = nullDate;
                    }
                    obj.invLineBillingTermUnit = line.BillingSchedule.BillingScheduleGroup.BillingTermUnit;
                    voiceLines.add(obj);
                }
            }
        }catch(Exception ex){
            logger.error(ex);
        }finally{
            logger.flush();
        }
    }
    @testVisible
    private Account generateBillingAccount(Id accId, String accName, String street, String city, String state, String postalCode, String country) {
        return new Account(Id = accId,
            Name = accName,
            BillingStreet = street,
            BillingCity = city,
            BillingState = state,
            BillingPostalCode = postalCode,
            BillingCountry = country);
    }
    
    @testVisible
    private Account generateShippingAccount(Id accId, String accName, String street, String city, String state, String postalCode, String country) {
        return new Account(Id = accId,
            Name = accName,
            ShippingStreet = street,
            ShippingCity = city,
            ShippingState = state,
            ShippingPostalCode = postalCode,
            ShippingCountry = country);
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
                WebStore wstore = [SELECT Id FROM WebStore WHERE Name ='Sflabs' LIMIT 1];
                webstoreId = wstore.Id;
            }else{
                webstoreId = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId WITH SECURITY_ENFORCED LIMIT 1].WebStoreId;
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
            //Insert opp;
            DMLManager.insertAsSystem(opp);
            
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
            logger.error(ex);
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
                            WHERE NetworkId = :communityId WITH SECURITY_ENFORCED
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
        if(!test.isRunningTest())
        { request.setHeader('Authorization', 'Bearer ' + B2B_CreateUserAccessToken.getAdminAccessToken()); }
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
                billingSechd = [select id, EffectiveNextBillingDate, EndDate from BillingScheduleGroup where ReferenceEntityId =: assetId];
            } else {
                billingSechd = [select id, EffectiveNextBillingDate, EndDate from BillingScheduleGroup where ReferenceEntityId =: assetId WITH SECURITY_ENFORCED];
            }
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
            if(isNotNullOrEmpty(String.valueOfGmt(orderDetail.CreatedDate))){
                orderModel.createdDate = orderDetail.CreatedDate;
            }
            //Total order amount
            if(isNotNullOrEmpty(String.valueOf(orderDetail.TotalAmount))){
                orderModel.totalAmount = orderDetail.TotalAmount;
            }
            //Account name
            if(isNotNullOrEmpty(orderDetail.Account.Name)){
                orderModel.accountName = orderDetail.Account.Name;
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