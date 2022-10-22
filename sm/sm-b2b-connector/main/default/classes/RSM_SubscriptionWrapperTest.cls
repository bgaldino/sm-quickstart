@isTest
private class RSM_SubscriptionWrapperTest {
    public Integer subscriptionTerm;
    public String startDate;
    public String roundingMode;
    public String pricingFlow;
    @testSetup
    static void main(){
         TestDataFactory.createData();
    }
    @isTest
    static void subwrap(){
         CartItem cartItem1 =[Select id,Quantity,CurrencyIsoCode from CartItem where Name='Cart Item 1' Limit 1];
        ProductSellingModel model = [Select id,Name from ProductSellingModel where Name='Evergreen Monthly' Limit 1];
        Pricebook2 customPricebook = new Pricebook2(Name = 'Custom Test Pricebook', IsActive = false);
        insert customPricebook;
        String cID ='02nnafanf';   
        List<String> candidatePricebookIds= new List<String>();
        candidatePricebookIds.add(cId);
        RSM_SubscriptionWrapper rsm = new RSM_SubscriptionWrapper(customPricebook.id,candidatePricebookIds);
        Product2 product1 = [Select id ,Name from Product2 where Name ='Test Product1' Limit 1];
        Test.startTest();
       // subscriptionTerm,startDate,roundingMode,pricingFlow,
       // listPricebookId,
       // graph:{"records":[{"referenceId":"ref_sales_txn",
       // "record":{"CurrencyIsoCode":"USD","attributes":{"type":"SalesTransaction"}}},{"referenceId":"ref_sales
        RSM_SubscriptionWrapper rsm1 = new RSM_SubscriptionWrapper(customPricebook.id,candidatePricebookIds);
        String r = rsm.getTermPriceProduct(rsm, product1.id, Integer.valueOf(cartItem1.Quantity), model.id, String.valueOf(cartItem1.CurrencyIsoCode));
        System.assert(r != Null);
        Test.stopTest();
    }
}