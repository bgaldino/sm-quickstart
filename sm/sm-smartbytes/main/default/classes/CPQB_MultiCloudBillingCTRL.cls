public with sharing class CPQB_MultiCloudBillingCTRL {
@AuraEnabled
    public static String[] initProdCodes() {
        // List<PricebookEntry> pbes = [SELECT Id, Pricebook2Id, Product2.Name, Product2.ProductCode FROM PricebookEntry WHERE Pricebook2Id = :pricebookId];
        List<Product2> allProds = [SELECT Id, ProductCode FROM Product2];
        
        String[] pCodes = new String[]{};
        for(Product2 prod : allProds) {
            if(String.isNotBlank(prod.ProductCode)){
            	pcodes.add(prod.ProductCode.trim().toLowerCase());
            }
        }
        System.debug(pCodes);
        return pCodes;
    }
    
    public static Id createOrder(Id recordId, String startDate, String Status, String poNumber, String description) {
        System.debug('Starting createOrder: ');
        Id orderId;
        // Get Std Pricebook
        Id stdPriceBook = getPriceBookId();
        System.debug('Received Pricebook Id: ' + stdPriceBook);

        System.debug('Status: ' + Status);
        System.debug('Status: ' + Status);
        System.debug('poNumber: ' + poNumber);
        System.debug('startDate: ' + startDate);
        // get JS date String and convert to Apex Date for start date / close date
        String[] dateChunks = startDate.split('-');
        System.debug('dateChunks: ' + dateChunks);
        //System.debug('dateChunks : ' + dateChunks.length);

        //Get current User.Locale to produce start date.
        Id currUserId = UserInfo.getUserId();
        System.debug('Current User Id: ' + currUserId);
        // SOQL to find record with currUserId to find Locale (field)
        String currUserLocale = [SELECT Id, LocaleSidKey FROM User WHERE Id =: currUserId LIMIT 1].LocaleSidKey;
        System.debug('Current User Locale: ' + currUserLocale);

        // Start with US - MM/DD/YY
        Date realStart;
        
        if(currUserLocale == 'en_US') {   
            realStart = Date.parse(dateChunks[1]+'/'+dateChunks[2]+'/'+dateChunks[0]);
            System.debug('Received realStart, user locale - USA: ' + realStart);
        } else if(currUserLocale == 'en_AU') {
            realStart = Date.parse(dateChunks[2]+'/'+dateChunks[1]+'/'+dateChunks[0]);
            System.debug('Received realStart, user locale - AUSTRAILIA: ' + realStart);
        } else {
            realStart = Date.parse(dateChunks[2]+'/'+dateChunks[1]+'/'+dateChunks[0]);
            System.debug('Received realStart, user locale - EUROPE: ' + realStart);
        }
        
        SObjectType thisObjectType = recordId.getSobjectType();
        System.debug('thisObjectType():'+ thisObjectType);
        
        // Check if Record id is account
        if(Account.getSObjectType() == thisObjectType) {

            // create order
            Order newOrder = new Order(AccountId=recordId,
                                       Status=Status,
                                       PO_Number__c=poNumber,
                                       Description=description,
                                       Pricebook2Id=stdPriceBook,
                                       EffectiveDate=realStart
                                       );

            // Insert the Order
            try {
                Database.insert(newOrder);
                System.debug('Successfully inserted new Order: ' + newOrder.Id);
            } catch (DmlException e) {
                System.debug('An error occurred inserting the Order: ' + e);
                System.debug('Stack trace:' + e.getStackTraceString());
            }
			orderId = newOrder.Id;

            }
      System.debug('Completing createOrder, Returning orderId: '+ orderId);
      return orderId;
    }
    
    
    public static Id getPriceBookId() {
        if(Test.isRunningTest()) {
            return Test.getStandardPricebookId();
        } else {
            return [SELECT Id, IsStandard FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1].Id;
        }
    }

    public static String getCurrencyISOCode(Id orderId) {
        if(Test.isRunningTest()) {
            return null; //Test.getCurrencyISOCode();
        } else {
            return [SELECT CurrencyIsoCode FROM Order WHERE Id =: orderId LIMIT 1].CurrencyIsoCode;
        }
    }
    
    @AuraEnabled
    public static List<ListView> getListViews() {
        List<ListView> listviews =
            [SELECT Id, Name FROM ListView WHERE SobjectType = 'Product2' AND Name = 'All Admin'];

            system.debug('listviews: ' + listviews);

        // Perform isAccessible() check here
        return listviews;
    }

  	@AuraEnabled
    public static Id addProduct(Id recordId, String startDate, String status, String poNumber, String description, String models) {
        // System.debug('Starting addProduct: ');
        // System.debug('recordId: ' + recordId);
        // System.debug('startDate: ' + startDate);
        // System.debug('status: ' + status);
        // System.debug('poNumber: ' + poNumber);
        // System.debug('description: ' + description);
        
        //recordId = '0013c00001rTZQ8AAO'; //Account Id
        //startDate = '2021-02-24';
        //status = 'Draft';

        // Start date American vs European (2021-12-16 vs 2021-16-12) is an issue at the moment
        // System.debug('addProduct - initial startDate: ' + startDate);
        
        Id orderId = createOrder(recordId, startDate, status, poNumber, description);
        
        //NEXT ADD ORDER PRODUCTS TO ORDER (ID = orderId)!!!!
        //Loop through all products to add..

        System.debug(models);
        List<Model> realModels = (List<Model>)JSON.deserialize(models,List<Model>.class);
        System.debug(realModels);

        // Need Std Pricebook and currency code to load in product models
        Id stdPriceBook = getPriceBookId();
        String currencyISOCode = getCurrencyISOCode(orderId);
        //String currencyISOCode = 'USD';

        // Generate list of uploadable order products
        List <OrderItem> orderProducts = new List<OrderItem>();

        List <String> productCodes = new List<String>();
        for(Model model : realModels) {
            productCodes.add(model.code);
        }

        
        List<Product2> productToFind = [SELECT Id, Name, ProductCode, SBQQ__ChargeType__c, SBQQ__BillingFrequency__c, SBQQ__BillingType__c, SBQQ__SubscriptionTerm__c FROM Product2 WHERE ProductCode IN :productCodes];
        List<PricebookEntry> pbeToFind = [SELECT Id, IsActive, CurrencyIsoCode, UnitPrice, Pricebook2Id, ProductCode, Product2Id, Name FROM PricebookEntry WHERE ((Pricebook2.Id = :stdPriceBook) AND (IsActive = true) AND (CurrencyIsoCode = :currencyISOCode)) AND (Product2.ProductCode IN :ProductCodes)];
        
        System.debug('pbeToFind:'+ pbeToFind);

        Map<Id, Id> pbeMap = New Map<Id, Id>();

        for(PricebookEntry pbe : pbeToFind){
            pbeMap.put(pbe.Product2Id, pbe.Id);
        }

        for(Model model : realModels){
                    
            // If null or empty string skip parsing that
            if(model.code.length() == 0) {
                continue;
            }
        
            // Try to find the Product by product code
            // this is not great to do multiple
            if(productToFind.size() > 0) {
                for (Integer i = 0; i < productToFind.size(); i++) {
                    if(productToFind[i].ProductCode == model.code) {
                        // load in the product model
                        OrderItem opm = New OrderItem();
                        opm.OrderId = orderId;
                        opm.PricebookEntryId = pbeMap.get(productToFind[i].Id);
                        opm.Product2Id = productToFind[i].Id;
                        opm.Quantity = model.quant;
                        opm.Description = model.description; // ALEX CHECK THIS
                        //system.debug('model:startDate:'+ model.serviceDate);
                        //system.debug('model:endDate:'+ model.endDate);
                        opm.ServiceDate = date.valueof(model.serviceDate);
                        //This is only for Recurring/Usage Price
                        if(model.charge != 'One-Time') {
                            opm.EndDate = date.valueof(model.endDate);
                        }
                        opm.UnitPrice = model.price/model.quant; // updated with new pricing structure in LWC
                        
                        //This is only for One-Time Price
                        if(model.charge == 'One-Time') {
                            opm.blng__BillableUnitPrice__c = model.price;
                        }

                        else { //you need to set recurring billableunitprice as well: https://help.salesforce.com/articleView?id=sf.blng_recurring_parent.htm&type=5
                            // System.debug('date.valueof(model.serviceDate):' + date.valueof(model.serviceDate) );
                            // System.debug('date.valueof(model.endDate):' + date.valueof(model.endDate) );
                            // System.debug('date.valueof(model.serviceDate).daysBetween(date.valueof(model.endDate)):' + date.valueof(model.serviceDate).daysBetween(date.valueof(model.endDate)));

                            //System.debug('proration calculation from LWC: ' + model.proration);

                            Decimal numerator = (1.00 + date.valueof(model.serviceDate).daysBetween(date.valueof(model.endDate)));
                            numerator = numerator.setScale(0);
                            Decimal denominator = 365.00;
                            Decimal prorateMultiplier = numerator / denominator;
                            // Decimal toround = 3.14159265;
                            prorateMultiplier = prorateMultiplier.setScale(4);
                            
                            // prorateMultiplier = prorateMultiplier.round(System.RoundingMode.CEILING);
                            //System.debug('prorateMultiplier:' + prorateMultiplier );
                            Decimal totalAmount = model.price;
                            totalAmount = totalAmount.setScale(4);
                            //System.debug('totalAmount: ' + totalAmount);
                            Decimal subscriptionTerm = productToFind[i].SBQQ__SubscriptionTerm__c;
                            subscriptionTerm = subscriptionTerm.setScale(4);
                            //System.debug('subscriptionTerm: ' + subscriptionTerm);
                            Integer numberOfInvoices = 12;
                            if(model.freq == 'Monthly'){
                                 numberOfInvoices = 12;
                            } else if(model.freq == 'Quarterly'){
                                 numberOfInvoices = 4;
                            }  else if(model.freq == 'Semiannual'){
                                 numberOfInvoices = 2;
                            }  else if(model.freq == 'Annual'){
                                 numberOfInvoices = 1;
                            }
                            //System.debug('numberOfInvoices: ' + numberOfInvoices);
                            Decimal numberOfInvoicesDec = numberOfInvoices;
                            numberOfInvoicesDec = numberOfInvoicesDec.setScale(4);
                            Decimal billingFrequencyDec = numberOfInvoicesDec*((1.00 + date.valueof(model.serviceDate).daysBetween(date.valueof(model.endDate))) / 365.00) ;
                            billingFrequencyDec = billingFrequencyDec.setScale(0);
                            //System.debug('billingFrequencyDec: ' + billingFrequencyDec);
                            // opm.blng__BillableUnitPrice__c = (totalAmount * billingFrequencyDec) / (prorateMultiplier * (subscriptionTerm * 12));
                    
                            opm.blng__BillableUnitPrice__c = (model.price * billingFrequencyDec) / (model.proration * 12/subscriptionTerm);
                            
                            //System.debug('Billable Unit Price: ' + opm.blng__BillableUnitPrice__c);
                            
                        }
                        
                        opm.SBQQ__Status__c = status;
                        opm.SBQQ__OrderedQuantity__c = model.quant;
                        opm.SBQQ__DefaultSubscriptionTerm__c = productToFind[i].SBQQ__SubscriptionTerm__c;
                        opm.SBQQ__ChargeType__c = productToFind[i].SBQQ__ChargeType__c;
                        opm.SBQQ__BillingFrequency__c = model.freq;
                        opm.SBQQ__BillingType__c = productToFind[i].SBQQ__BillingType__c;

                        orderProducts.add(opm);
                    }
                }

                system.debug('orderProducts: '+JSON.serializePretty(orderProducts));
            }
        }

        insert orderProducts;

        return orderId;
    }


    // Dummy Model for frontend input that we use to deserialize
    private class Model {
        @Auraenabled public String code;
        @Auraenabled public Integer quant;
        @Auraenabled public String description;
        @Auraenabled public String serviceDate;
        @Auraenabled public String endDate;
        @Auraenabled public Decimal price;
        @Auraenabled public String charge;
        @Auraenabled public String freq;
        @Auraenabled public String type;
        @Auraenabled public Decimal proration;
    }

    // Order Product Model for actual entry into Salesforce
    private class orderProductModel {
        @Auraenabled public String pbEntryId;
        @Auraenabled public Integer quantity;
        @Auraenabled public String serviceDate;
        @Auraenabled public String endDate;
        @Auraenabled public Decimal unitPrice;
        @Auraenabled public String status;
        @Auraenabled public Integer orderedQuantity;
        @Auraenabled public Decimal defaultSubscriptionTerm;
        @Auraenabled public String charge;
        @Auraenabled public String freq;
        @Auraenabled public String type;
        @Auraenabled public Decimal mrr;
    }

}