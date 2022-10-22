@isTest public class B2BStripeHandlerTest {
    @TestSetup static void Method(){
        TestDataFactory.createData();
        //  User usr = [SELECT Id FROM User WHERE firstname = 'ABCD' LIMIT 1];
        List<Account> accList = [SELECT Id FROM Account WHERE Name = 'Test Name' LIMIT 1];
        WebCart cart = [Select id from  WebCart where  Name = 'Cart' LIMIT 1 ];
        B2BTestFactory.addNewWebStore();
        Opportunity opp = B2BTestFactory.createOpportunity('test opportunity','Negotiation',Date.today()+30,true);
    }
     @istest static void lexOrigin(){
        WebCart cart = [Select id from  WebCart where Name = 'Cart' LIMIT 1 ];
        Map<String,Object> dataMap = new Map<String,Object>();
        dataMap.put('cartId', cart.id);
        Map<String,Object> exp = new  Map<String,Object>{};
        Test.startTest();
        Map<String, String> actualval = B2BStripeHandler.submitOrderTest(dataMap);
        System.assertEquals(exp, actualVal);
        test.stopTest();
    }
    @istest static void submitorder(){      
        WebCart cart = [Select id from  WebCart where Name = 'Cart' LIMIT 1 ];
        Map<String,Object> dataMap = new Map<String,Object>();
        dataMap.put('cartId', cart.id);
         Map<String,Object> exp = new  Map<String,Object>{};
        test.startTest();
        Map<String, String> actualVal = B2BStripeHandler.submitOrderTestAura(dataMap);
        System.assertEquals(exp, actualVal);
        test.stopTest();
    }
    @istest static void submitorder2(){      
        WebCart cart = [Select id from  WebCart where Name = 'Cart' LIMIT 1 ];
        Map<String,Object> dataMap = new Map<String,Object>();
        dataMap.put('cartId', cart.id);
         Map<String,Object> exp = new  Map<String,Object>{};
        test.startTest();
        String actualVal = B2BStripeHandler.getPublicKey();
        //System.assertEquals(exp, actualVal);
        test.stopTest();
    }
 }