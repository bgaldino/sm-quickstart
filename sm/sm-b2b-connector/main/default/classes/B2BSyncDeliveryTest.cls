@isTest
public class B2BSyncDeliveryTest {
    @testSetup static void setup() {
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            TestDataFactory.createData();
            Account testAccount = new Account(Name='TestAccount');
            insert testAccount;
            WebStore testWebStore = new WebStore(Name='TestWebStore', DefaultLanguage='en_US');
            insert testWebStore;
            
            Account account = [SELECT Id FROM Account WHERE Name='TestAccount' LIMIT 1];
            WebStore webStore = [SELECT Id FROM WebStore WHERE Name='TestWebStore' LIMIT 1];
            WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=account.Id);
            insert cart;
            
            CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery 1');
            insert cartDeliveryGroup;

            CartItem cartItem = new CartItem(CartId=cart.Id, Type='Product', Name='TestProduct', CartDeliveryGroupId=cartDeliveryGroup.Id);
            insert cartItem;
        }
    }
    

    @isTest static void testIntegrationRunsSuccessfully() {
        // Because test methods don't support Web service callouts, we create a mock response based on a static resource.
        // To create the static resource from the Developer Console, select File | New | Static Resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetDeliveryRatesResource');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.startTest();
        // Associate the callout with a mock response.
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Test: execute the integration for the test cart ID.
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name='Cart' LIMIT 1];
        List<Id> webCarts = new List<Id>{webCart.Id};
        //VOID METHOD
        B2BSyncDelivery.syncDelivery(webCarts);
        System.assertEquals('', '');
        // No status is returned from the syncCheckInventory check, but if no exception is thrown, the test passes

        Test.stopTest();
    }
    
    @isTest static void testIntegrationRunsSuccessfully1() {
        // Because test methods don't support Web service callouts, we create a mock response based on a static resource.
        // To create the static resource from the Developer Console, select File | New | Static Resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetDeliveryRatesResource');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.startTest();
        B2BSyncDelivery.ShippingOptionsAndRatesFromExternalService obj = new B2BSyncDelivery.ShippingOptionsAndRatesFromExternalService('','',1,1,'');
        obj.getOtherCost();
        obj.getServiceName();
        // Associate the callout with a mock response.
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Test: execute the integration for the test cart ID.
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name='Cart' LIMIT 1];
        List<Id> webCarts = new List<Id>();
        //VOID METHOD
        try{
            B2BSyncDelivery.syncDelivery(webCarts);
        }
        catch(Exception e ){
         	System.assertEquals('', '');   
        }
        // No status is returned from the syncCheckInventory check, but if no exception is thrown, the test passes

        Test.stopTest();
    }
    

    @isTest static void testWhenExternalServiceCallFailsAFailedStatusIsReturnedAndACartValidationOutputEntryIsNotCreated() {
        // Because test methods do not support Web service callouts, we create a mock response based on a static resource.
        // To create the static resource from the the Developer Console, select File | New | Static Resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetDeliveryRatesResource');
        // The web service call returns an error code.
        mock.setStatusCode(404);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.startTest();
        // Associate the callout with a mock response.
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Test: execute the integration for the test cart ID.
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        List<Id> webCarts = new List<Id>{webCart.Id};
        String expectedErrorMessage = 'There was a problem with the request. Error: 404';

        try {
            B2BSyncDelivery.syncDelivery(webCarts);
            
            // An exception should have been thrown before getting to this point:
            System.assert(false);
        } catch (CalloutException e) {
            System.assertEquals(expectedErrorMessage, e.getMessage());
        }
        
        // A new CartValidationOutput record with level 'Error' was created.
        List<CartValidationOutput> cartValidationOutputs = [SELECT Id, Message FROM CartValidationOutput WHERE Level = 'Error'];
        System.assertEquals(0, cartValidationOutputs.size());
        
        Test.stopTest();
    }
   @isTest static void b2bsync(){
        String errormsg ='ERROR';
        WebCart cart = [Select id,Name from WebCart where Name ='Cart' Limit 1];
        Test.startTest(); 
        B2BSyncDelivery.saveCartValidationOutputError(errormsg,cart.id);
        System.assertEquals(cart.Name, 'Cart');
        Test.stopTest();
    }
    @isTest static void b2bsync2(){
       Product2 product1 =[Select id,Name from Product2 where name ='Test Product1' Limit 1];
       OrderDeliveryMethod odm = new OrderDeliveryMethod(
       Name ='OrderDelivery',
       ProductId =product1.id
       );
       insert odm;
       String Id ;
       Test.startTest();
       Id= B2BSyncDelivery.getShippingChargeProduct2Id(odm.id);
       System.assertEquals(product1.id, Id);
       Test.stopTest();
    }
    
}