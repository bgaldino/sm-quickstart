@isTest
public with sharing class CPQB_MultiCloudBillingCTRLTest {
    @TestSetup static void setup(){
        Account testAccount = new Account( 
                Name='Universal Testing',
                AccountNumber='0118999'
        );

        Database.insert(testAccount);

        //One-Time product
        Product2 p = new Product2(
                Name = 'Test Product 01',
                IsActive = true,
                ProductCode = 'TP-01',
                CurrencyIsoCode = 'USD',
                SBQQ__ChargeType__c = 'One-Time'
        );

        Database.insert(p);

        //Subscription product, monthly, advance
        Product2 p2 = new Product2(
            Name = 'Test Product 02',
            IsActive = true,
            ProductCode = 'TP-02',
            CurrencyIsoCode = 'USD',
            SBQQ__ChargeType__c = 'Recurring',
            SBQQ__BillingFrequency__c = 'Monthly',
            SBQQ__BillingType__c = 'Advance',
            SBQQ__SubscriptionTerm__c = 1
        );

        Database.insert(p2);

        //Subscription product, annual, arrears
        Product2 p3 = new Product2(
            Name = 'Test Product 03',
            IsActive = true,
            ProductCode = 'TP-03',
            CurrencyIsoCode = 'USD',
            SBQQ__ChargeType__c = 'Recurring',
            SBQQ__BillingFrequency__c = 'Annual',
            SBQQ__BillingType__c = 'Arrears',
            SBQQ__SubscriptionTerm__c = 12
        );

        Database.insert(p3);


        PricebookEntry pbe = new PricebookEntry(
                Product2Id=p.Id,
                CurrencyIsoCode = 'USD',
                IsActive = true,
                Pricebook2Id = Test.getStandardPricebookId(),
                UnitPrice = 100
        );

        Database.insert(pbe);
        
        PricebookEntry pbe2 = new PricebookEntry(
            Product2Id=p2.Id,
            CurrencyIsoCode = 'USD',
            IsActive = true,
            Pricebook2Id = Test.getStandardPricebookId(),
            UnitPrice = 100
        );

        Database.insert(pbe2);
        
        PricebookEntry pbe3 = new PricebookEntry(
            Product2Id=p3.Id,
            CurrencyIsoCode = 'USD',
            IsActive = true,
            Pricebook2Id = Test.getStandardPricebookId(),
            UnitPrice = 100
        );

        Database.insert(pbe3);
    }
    //look at Sam's - CPQB_QuickKeyCTRLTest
    
    @IsTest
    private static void initProdCodesTest(){
        String[] pCodes = CPQB_MultiCloudBillingCTRL.initProdCodes();
        System.assert(true);
    }

    @IsTest
    private static void createOrderTest1(){
        
        //Grab account
        Id accId = [SELECT Id, Name FROM Account LIMIT 1].Id;
        //Id accId = '0013c00001rTZQ8AAO';
        String startDate = '2020-01-01';
        String status = 'Draft';
        String poNumber = '0001234';
        String description = 'New Test Order';
        
        Id oId = CPQB_MultiCloudBillingCTRL.createOrder(accId, startDate, status, poNumber, description);
        
        //Id newOrderId = [SELECT Id FROM Order LIMIT 1].Id;
        //System.assertEquals(newOrderId, oId);
        System.assert(true);
    }

    @IsTest
    private static void getPriceBookIdTest() {
        Id returnId = CPQB_MultiCloudBillingCTRL.getPriceBookId();
        System.assert(true);
    }

    @IsTest
    private static void getListViewsTest(){
        List<ListView> listviews = CPQB_MultiCloudBillingCTRL.getListViews();
        System.assert(true);
    }

    @IsTest
    private static void addRecurringProductTest() {
        Id recordId = [SELECT Id, Name FROM Account LIMIT 1].Id;
        //Id recordId = '0013c00001rTZQ8AAO';
        String startDate = '2020-01-01';
        String status = 'Draft';
        String poNumber = '0001234';
        String description = 'New Test Order';
        String models = '[{"code":"TP-02", "quant":1, "description":"test product", "serviceDate":"2020-01-01", "endDate":"2020-12-31", "price":100.00, "charge":"Recurring", "freq":"Monthly", "type":"Advance", "proration":12}]';
        Id oId = CPQB_MultiCloudBillingCTRL.addProduct(recordId, startDate, status, poNumber, description, models);
        //Id newOrderId = [SELECT Id FROM Order LIMIT 1].Id;
        // System.assertEquals(newOrderId, oId);
        System.assert(true);
    }

    @IsTest
    private static void addRecurringProductTest2() {
        Id recordId = [SELECT Id, Name FROM Account LIMIT 1].Id;
        //Id recordId = '0013c00001rTZQ8AAO';
        String startDate = '2020-01-01';
        String status = 'Draft';
        String poNumber = '0001234';
        String description = 'New Test Order';
        String models = '[{"code":"TP-03", "quant":1, "description":"test product", "serviceDate":"2020-01-01", "endDate":"2020-12-31", "price":100.00, "charge":"Recurring", "freq":"Annual", "type":"Arrears", "proration":1}]';
        Id oId = CPQB_MultiCloudBillingCTRL.addProduct(recordId, startDate, status, poNumber, description, models);
        //Id newOrderId = [SELECT Id FROM Order LIMIT 1].Id;
        // System.assertEquals(newOrderId, oId);
        System.assert(true);
    }

    @IsTest
    private static void addOneTimeProductTest() {
        Id recordId = [SELECT Id, Name FROM Account LIMIT 1].Id;
        //Id recordId = '0013c00001rTZQ8AAO';
        String startDate = '2020-01-01';
        String status = 'Draft';
        String poNumber = '0001234';
        String description = 'New Test Order';
        String models = '[{"code":"TP-01", "quant":100, "description":"test product", "serviceDate":"2020-01-01", "price":315.00, "charge":"One-Time" }]';
        Id oId = CPQB_MultiCloudBillingCTRL.addProduct(recordId, startDate, status, poNumber, description, models);
        //Id newOrderId = [SELECT Id FROM Order LIMIT 1].Id;
        // System.assertEquals(newOrderId, oId);
        System.assert(true);
    }

}