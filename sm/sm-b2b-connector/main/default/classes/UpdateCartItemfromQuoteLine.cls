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
global with sharing class UpdateCartItemfromQuoteLine {
    
    private static final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.DISCOUNT_UPDATE);
    
    /**
* @description Update the Cart Item with Discount amount from Quote Line item.
* @param quoteLineItems List of quote line items.
* @return void.
*/
    global static void updateCartItemfromQuotelineItem(List<QuoteLineItem> quoteLineItems)
    {
        
        
        Set<Id> cartItemIds = new Set<id>();
        Set<id> quoteId = new set<id>();
        
        Map<string, QuoteLineItem> mapQuoteLineItem = new Map<string, QuoteLineItem>();
        for(QuoteLineItem qi : quoteLineItems){
            
            cartItemIds.add(qi.cartitemid__c);
            mapQuoteLineItem.put(qi.cartitemid__c, qi);
            quoteId.add(qi.QuoteId);
            
            
        }
        
        //Apply discount if the quote is apporved.
        List<Quote> q = [SELECT ID, STATUS FROM QUOTE WHERE ID IN: quoteId AND STATUS = 'Approved' WITH SECURITY_ENFORCED];
        if(q.size() > 0){
            //Query Cart item and update the price if discount applied.
            //String cartItemSOQL = 'SELECT ' + RSM_Utils.getAllObjectFields(String.valueOf(CartItem.getSObjectType())) +
            String cartItemSOQL = 'SELECT id, isdeleted, name, currencyisocode, createddate, createdbyid, lastmodifieddate, lastmodifiedbyid, systemmodstamp, cartid, cartdeliverygroupid, product2id, type, sku, quantity, listprice, salesprice, unitadjustmentamount, unitadjustedprice, totallistprice, totallineamount, totallinetaxamount, adjustmentamount, adjustmenttaxamount, totalprice, itemizedadjustmentamount, itemizedadjustmenttaxamount, distributedadjustmentamount, distributedadjustmenttaxamount, totalpromoadjustmentamount, totalpromoadjustmenttaxamount, totaladjustmentamount, totalpriceafteralladjustments, totaltaxamount, totalamount, b2b_amend_product_quantity__c, b2b_external_list_price__c, b2b_external_unit_price__c, b2b_pricebookentry_id__c, b2b_recurring_price__c, b2b_renewal_uplift__c, b2b_upfront_price__c, b2b_upfront__c, b2b_uplift__c, billingfrequency2__c, discount__c, enddate__c, original_quantity__c, productsellingmodel__c, start_date__c, subscription__c' +
                ' FROM ' + String.valueOf(CartItem.getSObjectType()) +
                ' WHERE Id IN : cartItemIds WITH SECURITY_ENFORCED LIMIT 49999';
            
            List<CartItem> cartItemLst = (List<CartItem>)Database.query(cartItemSOQL);
            List<CartItem> updatedCartItemLst = new List<CartItem>();
            
            if(cartItemLst.size() > 0){
                for(CartItem ci : cartItemLst){
                    
                    ci.ListPrice = mapQuoteLineItem.get(ci.id).TotalPrice;
                    ci.SalesPrice = mapQuoteLineItem.get(ci.id).TotalPrice;
                    ci.Sku = 'Quote Update';
                    ci.AdjustmentAmount = 0;
                    ci.AdjustmentTaxAmount = 0;
                    ci.TotalAdjustmentAmount = 0;
                    ci.TotalPriceAfterAllAdjustments = 0;
                    ci.TotalLineAmount = mapQuoteLineItem.get(ci.id).TotalPrice;
                    ci.TotalListPrice = mapQuoteLineItem.get(ci.id).TotalPrice;
                    ci.TotalPrice = mapQuoteLineItem.get(ci.id).TotalPrice;
                    ci.UnitAdjustedPrice = mapQuoteLineItem.get(ci.id).TotalPrice;
                    ci.Discount__c =  mapQuoteLineItem.get(ci.id).Discount > 0 ? (mapQuoteLineItem.get(ci.id).Subtotal - mapQuoteLineItem.get(ci.id).TotalPrice) : 0;
                    updatedCartItemLst.add(ci);
                    
                    
                }
                
                try{
                    
                    DMLManager.updateAsSystem(updatedCartItemLst);
                    
                } catch(Exception e) {
                    logger.error(e);
                } finally {
                    logger.flush();
                }
                
                
            }
        }
        
    }
    
    //test methods to increase coverage
    
    /**
    * Creates new quote based on the Cart.
    * @param cartId, CartType, QuoteMesage, Community Id
    * @return Newly created Quote data
    **/
    

    global static void createQuoteToCart(String cartId,String cartType,String quoteMsg, string communityId){
        
        try
        {
            List<WebCart> lstCarts = [SELECT OwnerId, Id, Name, Type,CurrencyIsoCode, Status, (SELECT ID FROM Quotes__r) FROM WebCart 
                                      WHERE Id=:cartId WITH SECURITY_ENFORCED ORDER BY CREATEDDATE DESC LIMIT 20];   
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
            
            String webstoreId;
            if(!Test.isRunningTest()){
                webstoreId = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId WITH SECURITY_ENFORCED LIMIT 1].WebStoreId;
            }else{
                webstoreId = [SELECT Id FROM WebStore WHERE Name = 'Sflabs' WITH SECURITY_ENFORCED LIMIT 1].Id;
            }
            
            //get pricebook id
            string pricebook_id = [select id, Pricebook2Id,WebStoreId from WebStorePricebook where WebStoreId =: webstoreId AND pricebook2.isActive=true WITH SECURITY_ENFORCED].Pricebook2Id;
            
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
            DMLManager.insertAsUser(opp);
            
            String reqDataItems = '';
            Integer n = 1;
            String priceBookIdStr = webCartObj.B2B_PriceBook_Id__c;
            
            
            for(CartItem c : lstcartItems)
            {
                
                if(sellingModel.containsKey(c.B2B_PriceBookEntry_Id__c)){
                    string billingFreq = '';
                    string endDateQuoteLine = '';
                    
                    if(sellingModel.get(c.B2B_PriceBookEntry_Id__c) == 'TermDefined'){
                        Integer daysInMonth = Date.daysInMonth(system.today().Year(), system.today().Month());
                        endDateQuoteLine =  '"EndDate":"' + string.valueOf(System.today().addDays(daysInMonth-1))+ '",';
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
                '        "Description":"'+quoteMsg+'"'+
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
    
    public Integer subscriptionTerm;
  public String endDate;
  public String startDate;
  public String roundingMode;
  public String listPricebookId;
  public List<String> candidatePricebookIds;
  public String pricingFlow;
  public Graph graph;
    
  public class Graph {
    public String graphId;
    public List<Records> records;
  }

  public class Attributes {
    public String type;
  }

  public class Record {
    public Attributes attributes;
    public String CurrencyIsoCode;
  }

  public class SalesTransactionItem {

    public Attributes attributes;
    public String CurrencyIsoCode;
    public String SalesTransactionId;
        public String ProductSellingModelId;
    public String ProductId;
    public Integer Quantity;
  }

  public class PriceAdjustmentGroup {
    public Attributes attributes;
    public String SalesTransactionId;
    public String AdjustmentType;
    public Integer AdjustmentValue;
    public String AdjustmentSource;
    public String Description;
  }

    public class PriceAdjustmentItem {
    public Attributes attributes;
    public String SalesTransactionItemId;
    public String AdjustmentType;
    public Integer AdjustmentValue;
    public String AdjustmentSource;
    public String Description;
  }

  public class Records {
    public String referenceId;
    public Object record;
  }


    public UpdateCartItemfromQuoteLine(String listPricebookId,List<String> candidatePricebookIds){
        this.listPricebookId = listPricebookId;
        this.candidatePricebookIds = candidatePricebookIds;
        this.pricingFlow = 'GET_FINAL_PRICE';
        this.subscriptionTerm = 1;
      this.startDate = '2021-01-01';
      this.roundingMode = 'RoundUp';

    }

    public String getTermPriceProduct(UpdateCartItemfromQuoteLine pricingEngine,String productId,Integer quantity,String productSellingModelId, String CurrencyIsoCode){
        
        Graph graph = new Graph();
        List<Records> records = new List<Records> ();
        graph.records = records;
        graph.graphId = '1';
        /*SalesTransaction  record*/
        Records stRecords =  new Records();
        Record stRecord = new Record();
        Attributes stAttributes = new Attributes();
        stRecord.attributes = stAttributes;
        stAttributes.type = 'SalesTransaction';
        stRecord.CurrencyIsoCode = CurrencyIsoCode;
        stRecords.record = stRecord;
        stRecords.referenceId='ref_sales_txn';
        records.add(stRecords);
        /*SalesTransaction  record end */

        /*SalesTransactionItem  record*/
        Records stiRecords =  new Records();
        SalesTransactionItem stiRecord = new SalesTransactionItem();
        Attributes stiAttributes = new Attributes();
        stiRecord.attributes = stiAttributes;
        stiAttributes.type = 'SalesTransactionItem';
        stiRecord.CurrencyIsoCode = CurrencyIsoCode;
        stiRecord.SalesTransactionId = '@{ref_sales_txn.Id}';
        stiRecord.ProductId = productId;
        stiRecord.Quantity = quantity;
        stiRecord.ProductSellingModelId = productSellingModelId;
        stiRecords.record = stiRecord;
        stiRecords.referenceId='ref_sales_txn_item1';
        records.add(stiRecords);
        /*SalesTransactionItem  record end */
        pricingEngine.graph = graph;

        return JSON.serialize(pricingEngine);
    }
    
}