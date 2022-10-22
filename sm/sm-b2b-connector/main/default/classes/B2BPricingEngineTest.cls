@isTest
public class B2BPricingEngineTest {
    @testSetup
    static void setup(){
        TestDataFactory.createData();
    }
    @isTest
    static void B2BPricingEngineTest(){
        Account a = [Select id, Name, CurrencyIsoCode from Account where Name = 'Test Account'];
        List<String> candidatePricebookIds = new List<String>();
        candidatePricebookIds.add('candidatePricebookIds');
        Test.startTest();
        B2BPricingEngine obj = new B2BPricingEngine('listPricebookId',candidatePricebookIds);
        System.assert(a.CurrencyIsoCode == 'USD');
        Test.stopTest();
    }
    
    @isTest
    static void getRequestWithNoPAINoPAGandSubscriptionsEnabledTest(){
        String exVal = '{"pricingFlow":"GET_FINAL_PRICE","listPricebookId":"listPricebookId","graph":{"records":[{"referenceId":"ref_sales_txn","record":{"CurrencyIsoCode":"CurrencyIsoCode","attributes":{"type":"SalesTransaction"}}},{"referenceId":"ref_sales_txn_item1","record":{"SalesTransactionId":"@{ref_sales_txn.Id}","Quantity":1,"ProductSellingModelId":"productSellingModelId","ProductId":"productId","CurrencyIsoCode":"CurrencyIsoCode","attributes":{"type":"SalesTransactionItem"}}}],"graphId":"1"},"candidatePricebookIds":["candidatePricebookIds"]}';
        Account a = [Select id, Name, CurrencyIsoCode from Account where Name = 'Test Account'];
        List<String> candidatePricebookIds = new List<String>();
        candidatePricebookIds.add('candidatePricebookIds');
        B2BPricingEngine obj = new B2BPricingEngine('listPricebookId',candidatePricebookIds);
        Test.startTest();
        String returnVal = obj.getRequestWithNoPAINoPAGandSubscriptionsEnabled(obj,'productId',1,'productSellingModelId','CurrencyIsoCode');
        System.debug('returnVal-- '+returnVal);
        System.assertEquals(exVal, returnVal);
        Test.stopTest();
    }
    
    @isTest
    static void getRequestWithPercentDiscretionaryPAGandSubscriptionsEnabledTest(){
        String exVal = '{"pricingFlow":"GET_FINAL_PRICE","listPricebookId":"listPricebookId","graph":{"records":[{"referenceId":"ref_sales_txn","record":{"CurrencyIsoCode":"USD","attributes":{"type":"SalesTransaction"}}},{"referenceId":"ref_sales_txn_item1","record":{"SalesTransactionId":"@{ref_sales_txn.Id}","Quantity":1,"ProductSellingModelId":"ProductSellingModelId","ProductId":"ProductId","CurrencyIsoCode":"CurrencyIsoCode","attributes":{"type":"SalesTransactionItem"}}},{"referenceId":"ref_price_adjustment_group1","record":{"SalesTransactionId":"@{ref_sales_txn.Id}","Description":"10% Discretionary Discount applied at the header level","attributes":{"type":"PriceAdjustmentGroup"},"AdjustmentValue":1,"AdjustmentType":"AdjustmentPercentage","AdjustmentSource":"Discretionary"}}],"graphId":"1"},"candidatePricebookIds":["candidatePricebookIds"]}';
        List<B2BPricingEngine.SalesTransactionItem> salestransactionList = new List<B2BPricingEngine.SalesTransactionItem>();
        Account a = [Select id, Name, CurrencyIsoCode from Account where Name = 'Test Account'];
        List<String> candidatePricebookIds = new List<String>();
        candidatePricebookIds.add('candidatePricebookIds');
        B2BPricingEngine obj = new B2BPricingEngine('listPricebookId',candidatePricebookIds);
        B2BPricingEngine.Attributes attObj = new B2BPricingEngine.Attributes();
        attObj.type ='Attributes';
        B2BPricingEngine.SalesTransactionItem sObj = new B2BPricingEngine.SalesTransactionItem();
        sObj.attributes = attObj;
        sObj.CurrencyIsoCode = 'CurrencyIsoCode';
        sObj.ProductId = 'ProductId';
        sObj.ProductSellingModelId = 'ProductSellingModelId';
        sObj.Quantity = 1;
        sObj.SalesTransactionId = 'SalesTransactionId';
        salestransactionList.add(sObj);
        Test.startTest();
        String returnVal = obj.getRequestWithPercentDiscretionaryPAGandSubscriptionsEnabled(obj,salestransactionList,1,True);
        System.debug('returnVal-- '+returnVal);
        System.assertEquals(exVal, returnVal);
        Test.stopTest();
    }
    
    @isTest
    static void getRequestWithPercentDiscretionaryPAIandSubscriptionsEnabledTest(){
        String exVal = '{"pricingFlow":"GET_FINAL_PRICE","listPricebookId":"listPricebookId","graph":{"records":[{"referenceId":"ref_sales_txn","record":{"CurrencyIsoCode":"USD","attributes":{"type":"SalesTransaction"}}},{"referenceId":"ref_sales_txn_item1","record":{"SalesTransactionId":"@{ref_sales_txn.Id}","Quantity":1,"ProductSellingModelId":"ProductSellingModelId","ProductId":"ProductId","CurrencyIsoCode":"CurrencyIsoCode","attributes":{"type":"SalesTransactionItem"}}},{"referenceId":"ref_price_adjustment_item1","record":{"SalesTransactionItemId":"@{ref_sales_txn_item1.Id}","Description":"10% Discretionary Discount applied at the header level","attributes":{"type":"PriceAdjustmentItem"},"AdjustmentValue":1,"AdjustmentType":"AdjustmentPercentage","AdjustmentSource":"Discretionary"}}],"graphId":"1"},"candidatePricebookIds":["candidatePricebookIds"]}';
        List<B2BPricingEngine.SalesTransactionItem> salestransactionList = new List<B2BPricingEngine.SalesTransactionItem>();
        Account a = [Select id, Name, CurrencyIsoCode from Account where Name = 'Test Account'];
        List<String> candidatePricebookIds = new List<String>();
        candidatePricebookIds.add('candidatePricebookIds');
        B2BPricingEngine obj = new B2BPricingEngine('listPricebookId',candidatePricebookIds);
        B2BPricingEngine.Attributes attObj = new B2BPricingEngine.Attributes();
        attObj.type ='Attributes';
        B2BPricingEngine.SalesTransactionItem sObj = new B2BPricingEngine.SalesTransactionItem();
        sObj.attributes = attObj;
        sObj.CurrencyIsoCode = 'CurrencyIsoCode';
        sObj.ProductId = 'ProductId';
        sObj.ProductSellingModelId = 'ProductSellingModelId';
        sObj.Quantity = 1;
        sObj.SalesTransactionId = 'SalesTransactionId';
        salestransactionList.add(sObj);
        Test.startTest();
        String returnVal = obj.getRequestWithPercentDiscretionaryPAIandSubscriptionsEnabled(obj,salestransactionList,1,True);
        System.debug('returnVal-- '+returnVal);
        System.assertEquals(exVal, returnVal);
        Test.stopTest();
    }
    
}