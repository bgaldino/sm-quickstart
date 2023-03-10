@isTest
public class B2BStripeIntegrationControllerTest {
    @TestSetup static void method(){
        TestDataFactory.createData2();
        User usr = [SELECT Id FROM User WHERE firstname = 'ABC' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        WebStore wstore = [SELECT Id FROM WebStore WHERE Name = 'Sflabs' LIMIT 1];
        WebCart wb = [SELECT Id,name FROM WebCart where Name = 'Cart' LIMIT 1];
          Order orderObj = new Order();
        orderObj.Name               = 'Test';
        orderObj.AccountId          = acc.Id;
        orderObj.Status             = 'Draft';
        orderObj.EffectiveDate      = system.today();
        orderObj.ShippingCountry    = 'United States';
        orderObj.ShippingState      = 'Georgia';
        orderObj.Type               = 'End Customer';
        Insert orderObj;
        // CartCheckoutSession checkoutSession = new CartCheckoutSession(WebCartId = wb.Id, IsArchived = FALSE, State = 'Start', Name = wb.Name,OrderId =orderObj.id);
        //      insert checkoutSession;
        StoreIntegratedService service = new StoreIntegratedService();
        service.ServiceProviderType='Payment';
        service.StoreId= wstore.Id;
        service.Integration='0b08Z0000004IHPQA2';
        insert service;
           }
    @isTest static void charge(){
        WebCart wb = [Select Id from WebCart where Name = 'Cart' LIMIT 1];
         String cartId = wb.Id;
        Map<String,Object> dataMap = new Map<String,Object>();
        dataMap.put('cartId', wb.id);
        dataMap.put('charges',wb.id);
        dataMap.put('data',wb.id);
          Object Msg='';
        Map<String, Object> ExpectedOrderInfo = new  Map<String, Object>{'cartid'=>cartId, 'isSuccess'=>false, 'msg'=>Msg};
        // Because test methods do not support Web service callouts, we create a mock response based on a static resource.
        // To create the static resource from the Developer Console, select File | New | Static Resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Stripe');
        // The web service call returns an error code.
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.startTest();
       // Test.setMock(HttpCalloutMock.class, new B2BStripeIntegrationControllerMock());
       Test.setMock(HttpCalloutMock.class, mock);
      Map<String, Object> charge =  B2BStripeIntegrationController.chargeCustomer(dataMap);
        
         system.assertNotEquals(ExpectedOrderInfo,charge);
        Test.stopTest();
    }
    
    @isTest static void PaymentOptions(){
        WebCart wb = [Select Id from WebCart where Name = 'Cart' LIMIT 1];
         String cartId = wb.Id;
        Map<String,Object> dataMap = new Map<String,Object>();
        dataMap.put('cartId', wb.id);
        dataMap.put('Charges',wb.id);
         Object Msg='';
        Map<String, Object> ExpectedOrderInfo = new  Map<String, Object>{'cartid'=>cartId, 'isSuccess'=>false, 'msg'=>Msg};
        Test.startTest();
        Map<String, Object> actual = B2BStripeIntegrationController.getPaymentOptions(dataMap);
        Test.setMock(HttpCalloutMock.class, new B2BStripeIntegrationControllerMock());
        system.assertNotEquals(ExpectedOrderInfo,actual);
        Test.stopTest();
    }
    @isTest static void stripeCustomer(){
        User usr = [SELECT Id, AccountId, firstname FROM User WHERE firstname = 'ABC' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Id=:usr.AccountId LIMIT 1];
        String expdata = 'Value';
        WebCart wb = [Select Id from WebCart where Name = 'Cart' LIMIT 1];
        // Because test methods do not support Web service callouts, we create a mock response based on a static resource.
        // To create the static resource from the Developer Console, select File | New | Static Resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Stripe');
        // The web service call returns an error code.
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, mock);
        String actual= B2BStripeIntegrationController.getStripeCustomerId( [SELECT Id, DeveloperName, MasterLabel, Label, QualifiedApiName, Api_Key__c, Country__c, EndPoint_URL__c, Entity_Name__c, Public_Key__c, Stripe_Account_Name__c, User_Locale__c, WebStore__c, Currency__c FROM B2B_Payment_Gateway_Setting__mdt LIMIT 1]);
        System.assertEquals(null, actual);
        //  B2BStripeIntegrationController.getStripeCustomerId(stripeConfig);
        //Test.setMock(HttpCalloutMock.class, new B2BStripeIntegrationControllerMock());
        // System.assertNotEquals(expdata, actual);   
        Test.stopTest();
    }
    @isTest static void PaymentInfo(){
        Map<String, String> exp = new  Map<String, String>{'cartid'=>'cartId', 'isSuccess'=>'false'};
        WebStore wstore = [SELECT Id FROM WebStore WHERE Name = 'Sflabs' LIMIT 1]; 
        WebCart wb = [Select Id, WebStoreId from WebCart where Name = 'Cart' AND WebStoreId =: wstore.Id LIMIT 1];
        Map<String,Object> result = new Map<String,Object>();
        Map<String,Object> dataMap = new Map<String,Object>();
        dataMap.put('cartId', wb.id);
        dataMap.put('Charges',wb.id);
        Test.startTest();
        result= B2BPaymentController.setPaymentInfo(dataMap);
        System.debug(result);
        Test.setMock(HttpCalloutMock.class, new B2BStripeIntegrationControllerMock());
        System.assertNotEquals(exp,B2BPaymentController.setPaymentInfo(dataMap));
        Test.stopTest();
    }
  
    @isTest static void PaymentGroup(){
        ConnectApi.PaymentGroupRequest paymentGroup = new ConnectApi.PaymentGroupRequest();
        paymentGroup.createPaymentGroup = true;
       Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Order orderIns = [Select Id from Order Where Name = 'Test' LIMIT 1];
        WebCart wb = [Select Id, CurrencyISOCode from WebCart where Name = 'Cart'And CurrencyISOCode='USD' LIMIT 1];
        Map<String,Object> dataMap = new Map<String,Object>();
        dataMap.put('cartId', wb.id);
        dataMap.put('Charges',wb.id);
        Test.startTest();
        B2BStripeIntegrationController.getPaymentGroup(wb,orderIns.Id);
        System.assertNotEquals(null, paymentGroup);
     //   Test.setMock(HttpCalloutMock.class, new B2BStripeIntegrationControllerMock());
        Test.stopTest();
    }
    @isTest static void PaymentMethod(){ 
         ConnectApi.AuthApiPaymentMethodRequest authApiMethod = new ConnectApi.AuthApiPaymentMethodRequest();
         Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        WebCart wb = [Select Id, GrandTotalAmount, AccountId,currencyIsoCode from WebCart where Name = 'Cart'AND AccountId =: acc.Id LIMIT 1];
        Test.startTest();
        B2BStripeIntegrationController.getPaymentMethod(wb);
        System.assertNotEquals(null, authApiMethod);
       // Test.setMock(HttpCalloutMock.class, new B2BStripeIntegrationControllerMock());
        Test.stopTest();
    }
    @isTest static void methodOrigin(){
        Test.startTest();
         B2BPaymentController.getVFOrigin();
        System.assertNotEquals(null, B2BPaymentController.getVFOrigin());
        Test.stopTest();
    }
    @isTest static void method1(){
        WebCart wb = [Select Id from WebCart where Name = 'Cart' LIMIT 1];
         String cartId = wb.Id;
        Map<String,Object> dataMap = new Map<String,Object>();
        dataMap.put('cartId', wb.id);
        Object Msg='';
        Map<String, Object> ExpectedOrderInfo = new  Map<String, Object>{'cartid'=>cartId, 'isSuccess'=>false, 'msg'=>Msg};
        Test.startTest();
        Map<String, Object> paymentInfo = B2BPaymentController.getPaymentInfo(dataMap);
         system.assertNotEquals(ExpectedOrderInfo,paymentInfo);
        Test.stopTest();
    }
    @isTest static void method2(){
        WebCart wb = [Select Id from WebCart where Name = 'Cart' LIMIT 1];
        String cartId = wb.Id;
        Map<String,Object> dataMap = new Map<String,Object>();
        dataMap.put('cartId', wb.id);
         Map<String, Object> Expectedinfo = new  Map<String, Object>{'cartid'=>cartId, 'isSuccess'=>false};
        Test.startTest();
       Map<String, Object> PoOrder = B2BPaymentController.submitPoOrder(dataMap);
         system.assertNotEquals(Expectedinfo,PoOrder);
        Test.stopTest();
    }
    @isTest static void method3(){
        WebCart wb = [Select Id,Name from WebCart where Name = 'Cart' LIMIT 1];
        Test.startTest();
        B2BPaymentController.updateOppCheckoutStatus(wb);
        System.assertEquals('Cart', wb.Name);
        Test.stopTest();
    }
    @isTest static void method4(){
        WebCart wb = [Select Id from WebCart where Name = 'Cart' LIMIT 1];
        String cartId = wb.Id;
        Map<String, Object> Expectedinfo = new  Map<String, Object>{'cartid'=>cartId, 'isSuccess'=>false, 'msg'=>'Attempt to de-reference a null object'};
        Map<String,Object> dataMap = new Map<String,Object>();
        dataMap.put('cartId', wb.id);
        Test.startTest();
       Map<String, Object> PoOrder= B2BPaymentController.submitCreditCardOrder(dataMap);
        system.assertNotEquals(Expectedinfo,PoOrder); 
        Test.stopTest();
    }
    @isTest static void method5(){
        WebCart wb = [Select Id from WebCart where Name = 'Cart' LIMIT 1];
        String cartId = wb.Id;
        Map<String,Object> dataMap = new Map<String,Object>();
        dataMap.put('cartId', wb.id);
        Map<String, Object> Expectedinfo = new  Map<String, Object>{'cartid'=>cartId, 'isSuccess'=>false, 'msg'=>'Attempt to de-reference a null object'};
        Test.startTest();
        Map<String, Object> updateOrderInfo= B2BPaymentController.updateOrderInformation(dataMap);
        system.assertNotEquals(Expectedinfo,updateOrderInfo); 
        Test.stopTest();
    }
     @isTest static void testB2BStripeIntegrationController(){
        WebCart wb = [Select Id from WebCart where Name = 'Cart' LIMIT 1];
        String cartId = wb.Id;
        Map<String,Object> dataMap = new Map<String,Object>();
        object chargeData ;
        Object cToken;
        datamap.put('cartid', cartId);
        datamap.put('chargeData', chargeData);
        datamap.put('cToken', cToken);
         map<String,Object> Expectedinfo= new map<String,Object>{'cToken'=>null, 'cartid'=>cartId, 'chargeData'=>null};
        Test.startTest();
      map<String,Object> orderinfo =  B2BPaymentController.updatePaymentAuthError(dataMap);
         system.assertEquals(Expectedinfo, orderinfo);
        Test.stopTest();
    }
      public static testmethod void parseRequest1()
    {
        B2BStripeModel obj=new B2BStripeModel();
        String response='{\"id\":\"cus_AJ6mUWjfoelHlJ\",\"object\":\"customer\",\"balance\":0,\"currency\":\"usd\",\"email\":\"agustina@example.com\",\"name\":null,\"next_invoice_sequence\":154980,\"phone\":null,\"preferred_locales\":[],\"shipping\":null,\"tax_exempt\":\"none\",\"amount\":2143,\"type\":\"Card\",\"source\":{\"last4\":\"1111\",\"exp_month\":\"12\",\"exp_year\":\"23\",\"country\":\"US\",\"brand\":\"XX\"},\"data\":{\"last4\":\"1111\",\"exp_month\":\"12\",\"exp_year\":\"23\",\"country\":\"US\",\"brand\":\"XX\"},\"Error\":{\"message\":\"1111\"}}';
        B2BStripeIntegrationController.parseTokenResponse(response);
        String response2='{\"id\":\"cus_AJ6mUWjfoelHlJ\",\"object\":\"charge\",\"balance\":0,\"currency\":\"usd\",\"email\":\"agustina@example.com\",\"name\":null,\"next_invoice_sequence\":154980,\"phone\":null,\"preferred_locales\":[],\"shipping\":null,\"tax_exempt\":\"none\",\"amount\":2143,\"type\":\"Card\",\"data\":{\"last4\":\"1111\",\"exp_month\":\"12\",\"exp_year\":\"23\",\"country\":\"US\",\"brand\":\"XX\"},\"Error\":{\"message\":\"1111\"}}';
        B2BStripeIntegrationController.parseTokenResponse(response2);
        String response3='{\"id\":\"cus_AJ6mUWjfoelHlJ\",\"object\":\"charge\",\"balance\":0,\"currency\":\"usd\",\"email\":\"agustina@example.com\",\"name\":null,\"next_invoice_sequence\":154980,\"phone\":null,\"preferred_locales\":[],\"shipping\":null,\"tax_exempt\":\"none\",\"amount\":2143,\"type\":\"Card\",\"Error\":{\"message\":\"1111\"}}';
        B2BStripeIntegrationController.parseTokenResponse(response3);
        obj.Id='24234234';
        obj.transactionObject='wererw';
        obj.stripeTransactionToken='frwerfw';
        obj.CustomerId='test';
        obj.cardLastFourDigit='test';
        obj.cardExpiryMonth='test';
        obj.country='test';
        obj.email='test';
        obj.brand='test';
        obj.card='test';
        obj.chargeAmount=3242;
        obj.currencyCode='test';
        obj.type='test';
        obj.stripeChargeProcessError='test';
        obj.client_secret='test';
        obj.chargeCurrencyType='test';
        obj.obj='test';
        obj.payableNetAmount='test';
        obj.balance_transaction='test';
        obj.storefrontName='test';
        obj.cartId='test';
        
 system.assertEquals('test', obj.cartId);
    }
}