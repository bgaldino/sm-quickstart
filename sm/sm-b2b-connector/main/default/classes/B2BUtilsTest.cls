@isTest
public class B2BUtilsTest {
    
    @TestSetup
    static void testSetupMethod(){
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            B2BTestFactory.addNewUser();
            B2BTestFactory.addNewWebStore();
            B2BTestFactory.addNewCart(B2BTestFactory.getWebStore().Id, B2BTestFactory.getAccountList().get(0).Id, B2BTestFactory.getUser().Id);
            Webcart cart = B2BTestFactory.getCurrentWebCart();
            B2BTestFactory.createCartDeliveryGroup(cart,true);
            B2BTestFactory.createOrderDeliveryMethod(B2BTestFactory.getProduct2().Id,true);
            B2BTestFactory.createCartDeliveryGroupMethod(cart.Id, B2BTestFactory.getCartDeliveryGroup().Id, B2BTestFactory.getOrderDeliveryMethod().Id,true);
        }
    } 
    
    @isTest
    static void testresolveCommunityIdToWebstoreId() {
       // WebStore wstore = [SELECT Id FROM WebStore WHERE name = 'Evergreen Platform Solutions' LIMIT 1];
        Test.startTest();
        String retStr = B2BUtils.resolveCommunityIdToWebstoreId('webStoreId');
        Test.stopTest();        
        system.assertEquals('wstore.Id', retStr);
    }
  
    @isTest
    static void resolveSortParamTest(){
        Map<String, ConnectApi.CartItemSortOrder> sortOrderCache = new Map<String, ConnectApi.CartItemSortOrder>();
        for (ConnectApi.CartItemSortOrder sortOrder : ConnectApi.CartItemSortOrder.values()){
            sortOrderCache.put(sortOrder.name(), sortOrder);
          }
        Test.startTest();
        ConnectApi.CartItemSortOrder retStr = B2BUtils.resolveSortParam('CreatedDateAsc');
        Test.stopTest();
        system.assertEquals(sortOrderCache.get('CreatedDateAsc'), retStr);
    }
    @isTest
    static void getUserAccountIDtest(){
        list<user> u = [Select id, firstname, lastName, AccountId from User where firstname = 'ABC'];
        System.runAs(u[0]){
            Test.startTest();
            String retStr = B2BUtils.getUserAccountID();
            Test.stopTest();
            system.assertEquals(u[0].AccountId, retStr); 
        }
    }
    @isTest
    static void ListPicklistValuesByControllingValueTest(){
        Test.startTest();
         Map<String, Object> m = new Map<String, Object>{
                'statesByCountries' => B2BUtils.ListPicklistValuesByControllingValue(Account.BillingCountryCode, Account.BillingStateCode)
                };
        Test.stopTest();
        System.assertNotEquals(m.get('statesByCountries'), Null);
    }
    @isTest
    static void ListPicklistValuesByControllingValueNullTest(){
        Test.startTest();
         Map<String, Object> m = new Map<String, Object>{
                'statesByCountries' => B2BUtils.ListPicklistValuesByControllingValue(Null, Null)
                };
        Test.stopTest();
        System.assertNotEquals(m.get('statesByCountries'), Null);
    }
    @isTest
    static void testgetInternalAccounts() {
        List<String> retList = new  List<String>();
        B2B_Store_Configuration__mdt meta = B2B_Store_Configuration__mdt.getInstance('InternalAccountId');
        if(String.isNotBlank(meta.Value__c)){
            retList = meta.Value__c.split(',');
        }
        Test.startTest();
        List<String> recordList = B2BUtils.getInternalAccounts();
        Test.stopTest();        
        system.assertEquals(recordList, retList);
    }
    @isTest
    static void testmaxOnlinePurchaseAmount() {
         String retList;
        Decimal val;
        B2B_Store_Configuration__mdt meta = B2B_Store_Configuration__mdt.getInstance('MaxOnlineOrder_USD');
        if(String.isNotBlank(meta.Value__c)){
            retList = meta.Value__c;
        }
        val = decimal.valueOf(retList);
        Test.startTest();
        Decimal rate = B2BUtils.maxOnlinePurchaseAmount('USD');
        Test.stopTest();        
        system.assertEquals(val, rate);
    }    
}