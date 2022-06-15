@isTest
public class CPQB_RecordResetTests {
    @TestSetup static void setup(){
        Account testAccount = new Account(
                Name='Universal Testing',
                AccountNumber='0118999'
        );

        Database.insert(testAccount);

        Contact testContact = new Contact(
                AccountId=testAccount.Id,
                FirstName='Test',
                LastName='User'
        );

        Database.insert(testContact);

        blng__BillingConfig__c blngConfig = new blng__BillingConfig__c(Name='DISABLE_TRIGGERS',
                                                                        blng__BooleanValue__c=true);
        Database.insert(blngConfig);

    }

    @isTest
    public static void disableBillingTriggersTest() {
        blng__BillingConfig__c triggerConfig =[SELECT Id, Name, blng__BooleanValue__c FROM blng__BillingConfig__c WHERE Name = 'DISABLE_TRIGGERS'];
        triggerConfig.blng__BooleanValue__c = false;
        SObject so = (SObject)triggerConfig;
        Database.SaveResult sr = Database.updateImmediate(so);

        // try to disable triggers
        Boolean response = CPQB_RecordReset.disableBillingTriggers(true);
        System.assertEquals(true, response, 'Billing Triggers Toggle ran successfully');
        blng__BillingConfig__c updatedConfig = [SELECT Id, Name, blng__BooleanValue__c FROM blng__BillingConfig__c WHERE Name = 'DISABLE_TRIGGERS'];
        System.assertEquals(true, updatedConfig.blng__BooleanValue__c, 'Billing Triggers OFF');
    }

    @isTest
    public static void enableBillingTriggersTest() {
        blng__BillingConfig__c triggerConfig =[SELECT Id, Name, blng__BooleanValue__c FROM blng__BillingConfig__c WHERE Name = 'DISABLE_TRIGGERS'];
        triggerConfig.blng__BooleanValue__c = true;
        SObject so = (SObject)triggerConfig;
        Database.SaveResult sr = Database.updateImmediate(so);

        // try to enable triggers
        Boolean response = CPQB_RecordReset.disableBillingTriggers(false);
        System.assertEquals(true, response, 'Billing Triggers Toggle ran successfully');
        blng__BillingConfig__c updatedConfig = [SELECT Id, Name, blng__BooleanValue__c FROM blng__BillingConfig__c WHERE Name = 'DISABLE_TRIGGERS'];
        System.assertEquals(false, updatedConfig.blng__BooleanValue__c, 'Billing Triggers ON');
    }

    @IsTest
    private static void deleteDiscSchedsTest(){
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        SBQQ__DiscountSchedule__c dsToDelete = new SBQQ__DiscountSchedule__c(Name='Test',SBQQ__Account__c =accId);
        Database.insert(dsToDelete);
        CPQB_RecordReset.deleteDiscScheds(accId);
        SBQQ__DiscountSchedule__c[] emptyDS = [SELECT Id, SBQQ__Account__c FROM SBQQ__DiscountSchedule__c WHERE SBQQ__Account__c = :accId];
        System.assert(emptyDS.size() == 0, 'Discount Schedules Deleted');
    }

    @IsTest
    private static void deleteContractsTest(){
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        Contract testContract = new Contract(
                AccountId=accId,
                Status='Draft',
                StartDate=System.today(),
                ContractTerm=12
        );

        Database.insert(testContract);

        testContract.Status = 'Activated';
        Database.update(testContract);

        CPQB_RecordReset.deleteContracts(accId);
        Contract[] contractsToDelete = [SELECT Id, SBQQ__RenewalOpportunity__c, AccountId FROM Contract WHERE AccountId = :accId];

       
        System.assert(contractsToDelete.size() == 0, 'Contracts Deleted');
    }

    @IsTest
    private static void deleteInvoicesTest(){
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;

        // Invoice
        blng__Invoice__c inv = new blng__Invoice__c(blng__Account__c=accId,
                                                    blng__InvoiceStatus__c='Posted',
                                                    blng__DueDate__c=System.today().addDays(-2));
        Database.insert(inv);

        // Invoice Line
        blng__InvoiceLine__c invLine = new blng__InvoiceLine__c(blng__Invoice__c=inv.Id,
                                                                Name='Test Product',
                                                                blng__Quantity__c=1,
                                                                blng__UnitPrice__c=50,
                                                                blng__Subtotal__c=50,
                                                                blng__TaxAmount__c=0,
                                                                blng__TotalAmount__c=50);
        Database.insert(invLine);

        CPQB_RecordReset.deleteInvoices(accId);
        blng__Invoice__c[] invoicesToDelete = [SELECT 
                                                    Id, 
                                                    blng__InvoiceStatus__c, 
                                                    blng__Account__r.Id 
                                                FROM blng__Invoice__c 
                                                WHERE blng__Account__r.Id = :accId];

       
        System.assert(invoicesToDelete.size() == 0, 'Invoices Deleted');
    }

    // Delete Opps
    @IsTest
    private static void deleteOpportunitiesTest() {
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        Opportunity newOpp = new Opportunity(AccountId=accId,
                                            Name='New Opportunity',
                                            CloseDate=Date.today(),
                                            StageName='Qualification');
        Database.insert(newOpp);
        CPQB_RecordReset.deleteOpportunities(accId);
        Opportunity[] opportinitiesToDelete = [SELECT 
                                                    Id, 
                                                    AccountId 
                                                FROM Opportunity 
                                                WHERE AccountId = :accId];
        System.assert(opportinitiesToDelete.size() == 0, 'Opportunities Deleted');
    }

    // Delete Assets
    @IsTest
    private static void deleteAssetsTest() {
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        Asset testAsset = new Asset(AccountId=accId,
                                            Name='Test');
        Database.insert(testAsset);
        CPQB_RecordReset.deleteAssets(accId);
        Asset[] assetsToDelete = [SELECT Id, AccountId FROM Asset WHERE AccountId = :accId];
        System.assert(assetsToDelete.size() == 0, 'Assets Deleted');
    }

    // Delete Subs
    @IsTest
    private static void deleteSubscriptionsTest() {
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        Contract testContract = new Contract(
                AccountId=accId,
                Status='Draft',
                StartDate=System.today(),
                ContractTerm=12
        );

        Database.insert(testContract);

        Product2 p = new Product2(
                Name = 'Test Product 01',
                IsActive = true,
                ProductCode = 'TP-01'
        );

        Database.insert(p);

        SBQQ__Subscription__c sub = new SBQQ__Subscription__c(SBQQ__Account__c=accId,
                                                            SBQQ__Contract__c=testContract.Id,
                                                            SBQQ__Product__c=p.Id,
                                                            SBQQ__Quantity__c=1);

        Database.insert(sub);

        CPQB_RecordReset.deleteSubscriptions(accId);
        SBQQ__Subscription__c[] subscriptionsToDelete = [SELECT Id, SBQQ__Account__r.Id FROM SBQQ__Subscription__c WHERE SBQQ__Account__r.Id = :accId];
        System.assert(subscriptionsToDelete.size() == 0, 'Subscriptions Deleted');
    }

    @IsTest
    private static void deleteQuotesTest() {
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        SBQQ__Quote__c newQuote = new SBQQ__Quote__c(SBQQ__Type__c='Quote',SBQQ__Account__c=accId);
        Database.insert(newQuote);
        SBQQ__QuoteProcess__c qp = new SBQQ__QuoteProcess__c(Name='Test');
        Database.insert(qp);
        SBQQ__ProcessInput__c pi = new SBQQ__ProcessInput__c(Name='Test', SBQQ__Label__c='Test',SBQQ__DisplayOrder__c=1,SBQQ__ConditionsMet__c='All',SBQQ__InputField__c='Test__c', SBQQ__QuoteProcess__c=qp.Id);
        Database.insert(pi);
        SBQQ__ProcessInputValue__c piv = new SBQQ__ProcessInputValue__c(SBQQ__QuoteId__c=newQuote.Id,SBQQ__Value__c='Test',SBQQ__ProcessInputID__c=pi.Id);
        Database.insert(piv);

        CPQB_RecordReset.deleteQuotes(accId);
        SBQQ__Quote__c[] quotesToDelete = [SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__Account__r.Id = :accId];
        System.assert(quotesToDelete.size() == 0, 'Quotes Deleted');
    }


    @IsTest
    private static void deleteContractedPricesTest() {
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        Product2 p = new Product2(
                Name = 'Test Product 01',
                IsActive = true,
                ProductCode = 'TP-01'
        );

        Database.insert(p);
        SBQQ__ContractedPrice__c cp = new SBQQ__ContractedPrice__c(SBQQ__Account__c=accId, SBQQ__Price__c=100, SBQQ__Product__c=p.Id);
        Database.insert(cp);
        CPQB_RecordReset.deleteContractedPrices(accId);
        SBQQ__ContractedPrice__c[] cpToDelete = [SELECT Id FROM SBQQ__ContractedPrice__c WHERE SBQQ__Account__c = :accId];
        System.assert(cpToDelete.size() == 0, 'Contracted Prices Deleted');
    }

    @IsTest
    private static void deleteOrdersTest() {
        SBQQ.TriggerControl.disable();
        
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        
        blng__BillingRule__c blngRule = new blng__BillingRule__c(blng__Active__c=true,
            blng__AmendmentBillCycleDateAlignment__c='Do not align amended Order Product',
            blng__GenerateInvoices__c='Yes',
            blng__InitialBillingTrigger__c='Order Product Activation Date',
            Name='Test',
            blng__PartialPeriodTreatment__c='Separate');
        Database.insert(blngRule);

        blng__TaxRule__c taxRule = new blng__TaxRule__c(Name='Test', blng__Active__c=true,blng__TaxableYesNo__c='No');
        Database.insert(taxRule);

        blng__RevenueRecognitionRule__c rrRule = new blng__RevenueRecognitionRule__c(Name='Test', blng__Active__c=true, blng__CreateRevenueSchedule__c='Yes');
        Database.insert(rrRule);

        Product2 p = new Product2(
            Name = 'Test Product 01',
            IsActive = true,
            ProductCode = 'TP-01',
            CurrencyIsoCode = 'USD'
        );

        Database.insert(p);


        PricebookEntry pbe = new PricebookEntry(
                Product2Id=p.Id,
                CurrencyIsoCode = 'USD',
                IsActive = true,
                Pricebook2Id = Test.getStandardPricebookId(),
                UnitPrice = 100
        );

        Database.insert(pbe);

        Order newOrder = new Order(Status='Draft',
            AccountId=accId, 
            EffectiveDate=System.Today(),
            Pricebook2Id = Test.getStandardPricebookId());
        Database.insert(newOrder);

        OrderItem oi = new OrderItem(OrderId=newOrder.Id, 
            UnitPrice=100,
            Product2Id=p.Id,
            PricebookEntryId=pbe.Id,
            Quantity=1,
            blng__RevenueRecognitionRule__c=rrRule.Id,
            blng__TaxRule__c=taxRule.Id,
            blng__BillingRule__c=blngRule.Id);
        Database.insert(oi);

        // need at least one OP to activate
        newOrder.Status='Activated';
        Database.update(newOrder);

        CPQB_RecordReset.deleteOrders(accId);
        Order[] orders = [SELECT Id, AccountId FROM Order WHERE AccountId = :accId];
        System.assert(orders.size() == 0, 'Orders Deleted');
    }

    @IsTest
    private static void deleteCreditNotesTest(){
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        blng__CreditNote__c	cn = new blng__CreditNote__c(blng__Account__c=accId,
            blng__Status__c='Draft',
            blng__CreditNoteDate__c=System.Today());
        Database.insert(cn);
        CPQB_RecordReset.deleteCreditNotes(accId);
        blng__CreditNote__c[] creditNotesToDelete = [SELECT 
                                                        Id, 
                                                        blng__Account__c 
                                                    FROM blng__CreditNote__c 
                                                    WHERE blng__Account__c = :accId];
        System.assert(creditNotesToDelete.size() == 0, 'Credit Notes Deleted');
    }

    @IsTest
    private static void deleteDebitNotesTest(){
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        blng__DebitNote__c	dn = new blng__DebitNote__c(blng__Account__c=accId,
            blng__Status__c='Draft',
            blng__DebitNoteDate__c=System.Today());
        Database.insert(dn);
        CPQB_RecordReset.deleteDebitNotes(accId);
        blng__DebitNote__c[] debitNotesToDelete = [SELECT 
                                                        Id, 
                                                        blng__Account__c 
                                                    FROM blng__DebitNote__c 
                                                    WHERE blng__Account__c = :accId];
        System.assert(debitNotesToDelete.size() == 0, 'Debit Notes Deleted');
    }

    @IsTest
    private static void deletePaymentsTest(){
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        blng__Payment__c pay = new blng__Payment__c(blng__Account__c=accId,
            blng__Status__c='Draft',
            blng__Amount__c=100);
        Database.insert(pay);

        CPQB_RecordReset.deletePayments(accId);
        blng__Payment__c[] payments = [SELECT 
                                            Id, 
                                            blng__Account__c 
                                        FROM blng__Payment__c 
                                        WHERE blng__Account__c = :accId];
        System.assert(payments.size() == 0, 'Payments Deleted');
    }

    @IsTest
    private static void deletePaymentTransactionsTest() {
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        blng__PaymentGateway__c gateway = new blng__PaymentGateway__c(Name='Test');
        Database.insert(gateway);
        blng__PaymentTransaction__c txn = new blng__PaymentTransaction__c(blng__Account__c=accId,
            blng__Amount__c=100,
            blng__PaymentGateway__c=gateway.Id);
        Database.insert(txn);

        CPQB_RecordReset.deletePaymentTransactions(accId);
    
        blng__PaymentTransaction__c[] trxToDelete = [SELECT 
                                                        Id, 
                                                        blng__Account__c 
                                                    FROM blng__PaymentTransaction__c 
                                                    WHERE blng__Account__c = :accId];
        System.assert(trxToDelete.size() == 0, 'Payment Transactions Deleted');
    }


    @IsTest
    private static void deleteRefundsTest() {
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;

        blng__Refund__c rf = new blng__Refund__c(blng__Account__c=accId,
            blng__RefundMode__c='External',
            blng__Status__c='Draft');
        Database.insert(rf);

        CPQB_RecordReset.deleteRefunds(accId);
    
         blng__Refund__c[] refunds = [SELECT 
                                        Id, 
                                        blng__Account__c 
                                    FROM blng__Refund__c 
                                    WHERE blng__Account__c = :accId];
        System.assert(refunds.size() == 0, 'Refunds Deleted');
    }
    
}