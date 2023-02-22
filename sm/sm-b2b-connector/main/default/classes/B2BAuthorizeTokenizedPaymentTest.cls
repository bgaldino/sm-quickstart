// This is a minimal test for this class that verifies some of the handling of B2BAuthorizeTokenizedPayment
// without completing the authorization
@isTest
public class B2BAuthorizeTokenizedPaymentTest{
    @testSetup static void setup() {
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            // Account and Contact are related
            Account account = new Account(Name='TestAccount');
            insert account;
            Contact contact = new Contact(LastName='TestContact', AccountId=account.Id);
            insert contact;
            
            WebStore webStore = new WebStore(Name='TestWebStore', DefaultLanguage='en_US');
            insert webStore;
            
            CardPaymentMethod cardPaymentMethod = new CardPaymentMethod(AccountId=account.Id, ProcessingMode='External', Status='Active');
            insert cardPaymentMethod;
            
            WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=account.Id, PaymentMethodId=cardPaymentMethod.Id);
            insert cart;
            CartCheckoutSession checkoutSession = new CartCheckoutSession(WebCartId = cart.Id, IsArchived = FALSE, State = 'Start', Name = cart.Id);
            INSERT checkoutSession;
            CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery');
            insert cartDeliveryGroup;
            Order orderObj = new Order();
            orderObj.Name               = 'Test';
            orderObj.AccountId          = account.Id;
            orderObj.Status             = 'Draft';
            orderObj.EffectiveDate      = system.today();
            orderObj.ShippingCountry    = 'United States';
            orderObj.ShippingState      = 'Georgia';
            orderObj.Type               = 'End Customer';
            orderObj.SalesStoreId = webStore.Id;
            orderObj.Cart__c= cart.Id;
            Insert orderObj;
            
            insertCartItem(cart.Id, cartDeliveryGroup.Id);
            
            //addStoreIntegratedService(webStore);
        }
    }
    
   // Setup code that creates a non-functional store integrated service
    static void addStoreIntegratedService(WebStore webStore) {
        // Any named credential should do for the purposes of tests that don't 100% complete
        NamedCredential namedCredential = [SELECT Id FROM NamedCredential LIMIT 1];
        
        // This provider should be installed while running the SFDX installation that this test is associated with
        PaymentGatewayProvider paymentGatewayProvider = [SELECT Id FROM PaymentGatewayProvider LIMIT 1];
        
        PaymentGateway paymentGateway = new PaymentGateway(PaymentGatewayName='PGN', MerchantCredentialId=namedCredential.Id,
                                                           PaymentGatewayProviderId=paymentGatewayProvider.Id, Status='Active');
        insert paymentGateway;
        
        StoreIntegratedService newStoreIntegratedService = new StoreIntegratedService(Integration=paymentGateway.Id,
                                                                                      ServiceProviderType='Payment', StoreId=webStore.Id);
        insert newStoreIntegratedService;
    }
    
    // Starter test. Doesn't bother setting up an order, so errors are expected
    // To create more tests, consider setting up an order associated with a session and a cart to get past the failure
    // this test verifies.
    @isTest static void testNoOrderYetCreated() {
        
        // Get the data we'll need to use for running the test or for verification
        //Order order =[SELECT ID FROM Order Name='Test' LIMIT 1];
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name='Cart' LIMIT 1];
        CartCheckoutSession checkoutSession =[SELECT OrderId FROM CartCheckoutSession WHERE WebCartId=:webCart.Id];
        List<B2BAuthorizeTokenizedPayment.B2BAuthorizeTokenizedPaymentRequest> requests = new List<B2BAuthorizeTokenizedPayment.B2BAuthorizeTokenizedPaymentRequest>();
        ConnectApi.AuthorizationRequest authRequest = new ConnectApi.AuthorizationRequest();
        B2BAuthorizeTokenizedPayment.B2BAuthorizeTokenizedPaymentRequest request = new B2BAuthorizeTokenizedPayment.B2BAuthorizeTokenizedPaymentRequest();
        request.cartId = webCart.Id;
        requests.add(request);
        Test.startTest();
        B2BAuthorizeTokenizedPayment.authorizePaymentInfo(requests);
         system.assertNotEquals(null, authRequest);
        Test.stopTest();
    }
    
    // Inserts a cart item when we only know the cart id
    static void insertCartItem(String cartId) {
        List<CartDeliveryGroup> cartDeliveryGroups = [SELECT Id FROM CartDeliveryGroup WHERE CartId = :cartId LIMIT 1];
        insertCartItem(cartId, cartDeliveryGroups.get(0).Id);
        
    }
    
     // Inserts a cart item that matches the cart and cart delivery group
    static void insertCartItem(String cartId, String cartDeliveryGroupId) {
        CartItem cartItem = new CartItem(
            CartId=cartId, 
            Sku='SKU_Test1', 
            Quantity=3.0, 
            Type='Product', 
            Name='TestProduct', 
            CartDeliveryGroupId=cartDeliveryGroupId
        );
        insert cartItem;
    }
    
    static testMethod void b2borders(){
        
        TestDataFactory.createData();
        B2BOrderModel result = new B2BOrderModel();
        Account acc= [select id,Name from Account where Name ='Test Account'LIMIT 1];
        /*Order o = new Order(
Name='Test Order',
AccountId=acc.id,
Status='Draft',
EffectiveDate=Date.newInstance(2022, 12, 9), 
Type='None'
);
insert o;*/
        Order o = [Select id, Name, AccountId, Status, EffectiveDate,Type, CreatedDate, TotalAmount, Account.Name 
                   from Order where Name = 'Test' limit 1];
        B2BOrderModel expect =new B2BOrderModel();
        expect.accountName  =null;
        expect.createdDate=null;
        expect.name='Test Order';
        expect.namedPlace=null;
        expect.orderDeliveryMethod=null;
        expect.orderEstimatedDuty=null;
        expect.orderEstimatedShipping=null;
        expect.orderId=o.id;
        expect.orderNumber=null;
        expect.orderSubtotal=null;
        expect.orderTotal=null;
        expect.orderType='None';
        expect.orderedDate=null;
        expect.paymentMethod=null;
        expect.promoCodes=null;
        expect.promoCodesAdded=null;
        expect.shipmentType=null;
        expect.status='Draft';
        expect.totalAmount=null;
        Test.startTest();
        result=B2BAuthorizeTokenizedPayment.getB2BOrderModel(o); 
        System.assertNotEquals(expect, result);
        Test.stopTest();  
    }
    
    static testMethod void b2borders2(){
        TestDataFactory.createData();
        String result;
        Account acc= [select id,Name from Account where Name ='Test Account'LIMIT 1];
        Order o = [Select id, Name, AccountId, Status, EffectiveDate,Type, CreatedDate, TotalAmount, Account.Name 
                   from Order where Name = 'Test' limit 1];
        
        Test.startTest();
        result=B2BAuthorizeTokenizedPayment.getRecordTypeNameById(o.ID); 
        System.assertNotEquals('Expected', result);
        Test.stopTest();
    }
    
    @isTest
    static void startB2BBuyNowFlow(){
        String b2bOrderId = '';
        String paymentGatewayId = '';
        String paymentMethodId = '';
        Test.startTest();
        B2BAuthorizeTokenizedPayment.startB2BBuyNowFlow(b2bOrderId,paymentGatewayId,paymentMethodId);
        //No assertion - Void Method
        system.assertNotEquals(null, b2bOrderId);
        Test.stopTest();
    }
    @isTest
    static void catchmethod(){
    MessageLog__c log1 = new MessageLog__c(Message__c='B2BBuyNowFlow ERR');
    insert log1;
     Test.startTest();
        B2BAuthorizeTokenizedPayment.startB2BBuyNowFlow(log1.Message__c,log1.Message__c,log1.Message__c);
       system.assertEquals('B2BBuyNowFlow ERR', log1.Message__c);
        Test.stopTest();
    }
    
    @isTest
    static void getPaymentGroupTest(){
        test.startTest();
        B2BAuthorizeTokenizedPayment.getPaymentGroup(Null);
        system.assertEquals(null, B2BAuthorizeTokenizedPayment.getPaymentGroup(Null));
        test.stopTest();
    }
    @isTest
    static void isNotNullOrEmptyTest(){
        test.startTest();
        boolean val = B2BAuthorizeTokenizedPayment.isNotNullOrEmpty(Null);
        system.assertNotEquals(null, val);
        test.stopTest();
    }
}