@isTest
public with sharing class CPQB_QuickKeyCTRLTest {
@TestSetup static void setup(){
        Account testAccount = new Account( 
                Name='Universal Testing',
                AccountNumber='0118999'
        );

        Database.insert(testAccount);


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
    }


    @IsTest
    private static void initProdCodesTest() {
        String[] pCodes = CPQB_QuickKeyCTRL.initProdCodes();
        System.assert(pCodes.size() > 0);
    }

    @IsTest
    private static void createOppAndQuoteTest() {
        Id accId = [SELECT Id, Name FROM Account LIMIT 1].Id;
        Opportunity newOpp = new Opportunity(AccountId=accId,
                                Name='Quick Key Opportunity',
                                CloseDate=Date.Today(),
                                StageName='Qualification');
        // Insert the Opp
        Database.insert(newOpp);
        Id recordId = newOpp.Id;

        String startDate = '2020-01-01'; 
        Integer subTerm = 12;
        Id qId = CPQB_QuickKeyCTRL.createOppAndQuote(recordId, startDate, subTerm);
        Id newQuoteId = [SELECT Id FROM SBQQ__Quote__c LIMIT 1].Id;
        System.assertEquals(newQuoteId, qId);
    }

    @IsTest
    private static void addProductTest() {
        Id recordId = [SELECT Id, Name FROM Account LIMIT 1].Id;
        String startDate = '2020-01-01';
        Integer subTerm = 12;
        String models = '[{"code":"TP-01", "quant":1}]';
        Id qId = CPQB_QuickKeyCTRL.addProduct(recordId, models, startDate, subTerm);
        Id newQuoteId = [SELECT Id FROM SBQQ__Quote__c LIMIT 1].Id;
        System.assertEquals(newQuoteId, qId);
    }

}