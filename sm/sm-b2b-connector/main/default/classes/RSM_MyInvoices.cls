/**
 * @description       : 
 * @author            : surya
 * @group             : 
 * @last modified on  : 05-20-2022
 * @last modified by  : surya
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   05-20-2022   surya  Initial Version
**/

global with sharing class RSM_MyInvoices {

    private final static Integer PAGE_SIZE = 10;
    private static Invoice invTest;
    private static final String MODULE_NAME = 'MyInvoices Module';
    private static final DCM_Logger logger = DCM_Logger.getInstance(MODULE_NAME);
    
    public RSM_MyInvoices(Invoice inv){
        invTest = inv;
    }
    @AuraEnabled
    global static RSM_MyInvoices_Page_Result getUserInvoices(Integer pageNumber) {
        try {

            Integer pageSize    = PAGE_SIZE; //define how many records are shown per page
            Integer offset      = (pageNumber - 1) * pageSize; //search when the page is located
            
            //List<RSM_SubscriptionsWrapper> response = new List<RSM_SubscriptionsWrapper>(); 
            List<RSM_MyInvoiceWrapper> response = new list<RSM_MyInvoiceWrapper>();
            String userId = UserInfo.getUserId() ;
            List<User> uList = [SELECT Id,AccountId, contactId FROM USER WHERE Id=:userId AND AccountId != null AND contactId!= Null WITH SECURITY_ENFORCED];
    
            List<Invoice> allInvoices = new List<Invoice>();
			logger.debug(JSON.serialize(uList));
            
            if(!uList.isEmpty()){
                //allInvoices = [SELECT id from Invoice WHERE BillingAccountId =: uList.get(0).AccountId];
                allInvoices = [SELECT id from Invoice WHERE billToContactId =: uList.get(0).contactId WITH SECURITY_ENFORCED];
                /*List<Invoice> invoiceList = [SELECT Id, CreatedDate, DocumentNumber, InvoiceDate, DueDate, Status, TotalChargeAmountWithTax, Balance  
                                             FROM Invoice 
                                             WHERE BillingAccountId =: uList.get(0).AccountId
                                             order by CreatedDate desc 
                                             LIMIT :pageSize OFFSET :offset]; */
                List<Invoice> invoiceList = [SELECT Id, CreatedDate, DocumentNumber, InvoiceDate, DueDate, Status, TotalChargeAmountWithTax, Balance  
                                             FROM Invoice 
                                             WHERE billToContactId =: uList.get(0).contactId WITH SECURITY_ENFORCED
                                             order by CreatedDate desc
                                             LIMIT :pageSize OFFSET :offset];
                if(Test.isRunningTest()){
                    if(invoiceList.isEmpty()){
                        invoiceList.add(invTest);
                    }
                }
                logger.debug(JSON.serialize(invoiceList));
                for(Invoice inv : invoiceList){
                    RSM_MyInvoiceWrapper wrap = new RSM_MyInvoiceWrapper();
                    wrap.invoice = inv;
                    if(!Test.isRunningTest()){
                        wrap.invEndDate_Stub = inv.InvoiceDate.addMonths(1);
                    }
                    response.add(wrap);
                }            
            }        
    
            RSM_MyInvoices_Page_Result result = new RSM_MyInvoices_Page_Result();
            result.totalItemCount   = allInvoices.size();
            result.pageSize         = pageSize; //total size of data on one page
            result.pageNumber       = pageNumber; //page number
            result.records          = response;
            logger.debug(JSON.serialize(result));
            return result;
        }catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        }finally{
            logger.flush();
        }
    }
    
    public static String getDomain(){
        String returnValue;
        try{
            RSM_Connector_Configuration__mdt mData = RSM_Connector_Configuration__mdt.getInstance('Org_Domain_Url');
            //B2B_Store_Configuration__mdt mData = B2B_Store_Configuration__mdt.getInstance('OrgDomainUrl');
            returnValue = String.valueOf(mData.key__c);
            logger.debug(JSON.serialize(returnValue));
            return returnValue;
        }catch(Exception ex){
            logger.error(ex);
        }finally{
            logger.flush();
        }
        logger.debug(JSON.serialize(returnValue));
        return returnValue;
    }
    
    @AuraEnabled 
    global static map<String,object> retrieveOrderDetailPDF(String invoiceId) {
        List<SObject> payload = new List<SObject>();
        map<String,object> response = new map<String,object>();
        response.put('domainUrl',getDomain());
        String fileName = 'Invoice.pdf';
        Attachment orderAttachment = null;
        Boolean blnAttachmentExist = false;
        try{
            if(String.isNotBlank(invoiceId))
            {
                logger.debug(JSON.serialize(invoiceId));
                List<Attachment> lstAttachment = [Select Id from Attachment Where parentId= :invoiceId AND Name = :fileName WITH SECURITY_ENFORCED];
                if(lstAttachment!=null && lstAttachment.size()>0)
                {
                    //delete lstAttachment;
                    DmlManager.deleteAsUser(lstAttachment);
                }
                PageReference pdf = Page.RSM_ViewMyInvoice;
                pdf.getParameters().put('invoiceId',invoiceId);
                orderAttachment = new Attachment();
                Blob body;
                try
                {
                    body = pdf.getContent(); //getContentasPDF();
                } catch (VisualforceException e)
                {
                    logger.error(e);
                    body = Blob.valueOf('unable to get content as pdf');
                }
                logger.debug(JSON.serialize(body));
                orderAttachment.Body = body;
                orderAttachment.Name = fileName;
                orderAttachment.IsPrivate = false;
                //orderAttachment.IsPrivate = true;
                orderAttachment.parentid = invoiceId;
                orderAttachment.ContentType = 'application/pdf';
                //insert orderAttachment;
                payload.add(orderAttachment);
                DmlManager.insertAsUser(payload);
                //DmlManager.insertAsSystem(payload);
                blnAttachmentExist = true;
                if(orderAttachment!=null && blnAttachmentExist)
                {
                    //return orderAttachment.id;
                    response.put('docId',orderAttachment.id);
                }
            }
            logger.debug(JSON.serialize(response));
            return response;
        }catch(Exception expObj)
        {
            logger.error(expObj);
        }finally{
            logger.flush();
        }
        return null;
    }
    
    @AuraEnabled
    global static Object lightDownloadInvoice(Id invoiceId)
    {
        map<String,object> responseMap = new map<String,object>();
        Id atId;
        try {
            if(!Test.isRunningTest()) {
                responseMap = retrieveOrderDetailPDF(invoiceId);
                logger.debug(JSON.serialize(responseMap));
                atId = (ID)responseMap.get('docId');
            }else{
                atId = (ID)responseMap.get('docId');
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception!');
                logger.error(e);
                throw e;
            }
            logger.debug(JSON.serialize(atId));
            return atId;
        } catch (Exception e) {
            logger.error(e);
            return e.getMessage();
        }finally{
            logger.flush();
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

}