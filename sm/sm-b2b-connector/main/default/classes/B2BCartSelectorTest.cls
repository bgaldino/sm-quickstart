@isTest
private class B2BCartSelectorTest {
    @testSetup
    static void main(){
        TestDataFactory.createData();
    }
    
    @isTest  
    static void One(){
        Test.startTest();
        Set<String> actual = new Set<String>();
        Set<String> expected = new Set<String>{
      'Id',
      'Name',
      'WebStoreId',
      'OwnerId,Owner.FirstName,Owner.LastName,Owner.Email',
      'AccountId,Account.Name',
      'CurrencyIsoCode',
      'GrandTotalAmount',
      'TotalPromoAdjustmentAmount',
      'Status',
      'TotalTaxAmount','TotalAmount','TotalProductAmount',
      'PoNumber',
      '(SELECT Id,CurrencyIsoCode,Sku,Quantity,SalesPrice,ListPrice,TotalPrice,Product2Id,Product2.Name,Product2.ProductCode,Product2.DisplayUrl,Product2.isActive, AdjustmentAmount,  AdjustmentTaxAmount, CartDeliveryGroupId,  Name, TotalLineAmount, TotalListPrice, Type, UnitAdjustedPrice, UnitAdjustmentAmount, CartId FROM CartItems)'
    };
        actual =B2BCartSelector.getDefaultFields();
        System.assertEquals(expected,actual);
        Test.stopTest();
    }
    @isTest  
    static void Two(){
             Map<String, Object> m= new Map<String,Object>();
        Map<String,Object> expected = new Map<String,Object>();
        expected.put('ModuleName','StoreUrl');
        String whereClause='';
         whereClause +=
        ' WHERE Module_Name__c = \'' +
        (String) expected.get('ModuleName') +
        '\'';
        m.put('ModuleName','StoreUrl');
        String ans= whereClause;
        Test.startTest();
        String result= B2BCartSelector.getQueryWhereMetaData(m);
        System.assertEquals(ans, result);
        Test.stopTest();
    }
    @isTest  
    static void three(){
        WebCart cart =[Select id,Name from WebCart where Name='Cart' limit 1];
        WebCart actual = new WebCart();
        WebCart result= new WebCart();
        Test.startTest();
        actual = B2BCartSelector.getClosedCart(cart.id);
        System.assertEquals(null, actual);
        Test.stopTest();
    }
    @isTest  
    static void four(){
        WebCart cart =[Select id,Name from WebCart where Name='Cart' limit 1];
        WebCart actual = new WebCart();
        WebCart expected =[Select Id, Name, WebStoreId, OwnerId, AccountId,
                           CurrencyIsoCode, GrandTotalAmount, TotalPromoAdjustmentAmount,
                           Status, TotalTaxAmount, TotalAmount, TotalProductAmount, PoNumber
                          from WebCart limit 1];
        Test.startTest();
        actual= B2BCartSelector.getCurrentActiveCart(cart.id);
        System.assertEquals(expected.id,actual.id);
        Test.stopTest();
    }
   @isTest  
    static void five(){
        List<B2B_Store_Configuration__mdt> bsm = new List<B2B_Store_Configuration__mdt>();
        List<B2B_Store_Configuration__mdt> expect = new List<B2B_Store_Configuration__mdt>();
        Map<String, Object> m= new Map<String,Object>();
        m.put('ModuleName','StoreUrl'); 
        Test.startTest();
        bsm= B2BCartSelector.getProductCategorie(m);
        System.assertEquals(expect, bsm);
        Test.stopTest();
    }
    
}