@isTest
public class B2BPaymentControllerTest  {
    @testSetup static void setup() {
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            // Account and Contact are related
            Account account = new Account(Name='TestAccount');
            insert account;
            Contact contact = new Contact(LastName='TestContact', AccountId=account.Id);
            insert contact;
            
            WebStore webStore = new WebStore(Name='TestWebStore', DefaultLanguage='en_US');
            insert webStore;
            
            WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=account.Id);
            insert cart;
            
            CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery');
            insert cartDeliveryGroup;
            
            // The cpas are related to the account (and through it to the contact)
            ContactPointAddress cpa1 = new ContactPointAddress(Name='CPA1', Street='Street1', City='Goleta', State='California',
                                                            Country='United States', PostalCode='93117-3084', IsDefault=true, AddressType='shipping/Billing', ParentId=account.Id);
            ContactPointAddress cpa2 = new ContactPointAddress(Name='CPA2', Street='Street2', City='Goleta', State='California',
                                                            Country='United States', PostalCode='93117-3085', IsDefault=false, AddressType='shipping/Billing', ParentId=account.Id);
            
            // This contact point address should not show up because it's set to AddressType Shipping
            ContactPointAddress cpaShipping = new ContactPointAddress(Name='CPAS', Street='StreetS', City='Goleta',
                                                                    Country='United States', PostalCode='93117-3088', IsDefault=false, AddressType='shipping/Billing', ParentId=account.Id);
            
            insert cpa1;
            insert cpa2;
            insert cpaShipping;
            insertCartItem(cart.Id, cartDeliveryGroup.Id);
        
            // This profile name is the name of the buyer profile. The name specified here is what is installed using
            // SFDX and may be different for you.
        //Profile profile = [SELECT Id FROM Profile WHERE Name='Buyer_User_Profile_From_QuickStart' LIMIT 1];
            Profile profile = [SELECT Id FROM Profile WHERE Name = :B2B_Constants.Profile.CUSTOMER_COMMUNITY_PLUS_USER LIMIT 1];
            User user = new User(Alias='buyer', Email='buyer@example.com', LastName='Buyer',
                                TimeZoneSidKey='GMT', LocaleSidKey='en_US', Username='buyer@example.com',
                                EmailEncodingKey='UTF-8', ProfileId=profile.Id, LanguageLocaleKey='en_US',
                                ContactId=contact.Id);
            insert user;
            product2 producto= new product2(name='Test1',StockKeepingUnit='SKU_Test1', isActive=true);
            insert producto;
            //[Select id from Product2 where StockKeepingUnit=:'SKU_Test1'];
            Id standardId = test.getStandardPricebookId();
            List<PricebookEntry> entryList = [select product2id,pricebook2Id from  PricebookEntry where product2id =: producto.id and pricebook2Id = :standardId limit 1];
            PricebookEntry one;
            if(entryList.isEmpty()) {
                one = new PricebookEntry();
                one.pricebook2Id = standardId;
                one.product2id = producto.id;
                one.unitprice = 1249.0;
                one.isactive = true;
                insert one; 
                
            } else {one = entryList[0];}
            
            Order orderObj = new Order();
            orderObj.Name               = 'Test';
            orderObj.AccountId          = account.Id;
            orderObj.Status             = 'Draft';
            orderObj.EffectiveDate      = system.today();
            orderObj.ShippingCountry    = 'United States';
            orderObj.ShippingState      = 'Georgia';
            orderObj.Type               = 'End Customer';
            orderObj.Pricebook2Id       = standardId;
            //orderObj.RecordTypeId       = recordTypeId;
            
            orderObj.Cart__c=cart.Id;
            System.runAs(user)
            { Insert orderObj;}
            CartCheckoutSession checkoutSession = new CartCheckoutSession(WebCartId = cart.Id, IsArchived = FALSE, State = 'Start', Name = cart.Name,OrderId =orderObj.id);
        
            insert checkoutSession;
        }
    }
     
   
    @isTest static void testGetPaymentInfo() {
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name='Cart' LIMIT 1];
        String cartId = webCart.Id;
        User buyer= [Select Name, id from User where username like 'buyer@example.com' ];
        Map<String, Object> datamap = new Map<String, Object>();
        datamap.put('cartid', cartId);
        Object Msg='';
        Map<String, Object> ExpectedOrderInfo = new  Map<String, Object>{'cartid'=>cartId, 'isSuccess'=>false, 'msg'=>Msg};
        Test.startTest();
        
        B2BPaymentController.getVFOrigin();
        
        // Get the payment info as a buyer so that the buyer's account is used in the method call
        
        System.runAs(buyer) {
            Map<String, Object> paymentInfo = B2BPaymentController.getPaymentInfo(dataMap);
            system.assertEquals(ExpectedOrderInfo,paymentInfo);
        }
        Test.stopTest();
        
    }
    @isTest static void NegtestGetPaymentInfo() {
        try{ 
            Test.startTest();
            Map<String, Object> paymentInfo = B2BPaymentController.getPaymentInfo(null);
            Test.stopTest();
        }
        catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest static void testsubmitPoOrder() {
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name='Cart' LIMIT 1];
        String cartId = webCart.Id;
        User buyer= [Select Name, id from User where username like 'buyer@example.com' ];
        Map<String, Object> datamap = new Map<String, Object>();
        datamap.put('cartId', cartId);
         Object Msg='';
        Map<String, Object> Expectedinfo = new  Map<String, Object>{'cartid'=>cartId, 'isSuccess'=>false, 'msg'=>Msg};
       
        Test.startTest();
        // Get the payment info as a buyer so that the buyer's account is used in the method call
        System.runAs(buyer) {
            Map<String, Object> PoOrder = B2BPaymentController.submitPoOrder(dataMap);
          system.assertNotEquals(Expectedinfo,PoOrder);
        }
        Test.stopTest();
        
    }
     @isTest static void NegtestsubmitPoOrder() {
        try{ 
            Test.startTest();
            Map<String, Object> paymentInfo = B2BPaymentController.submitPoOrder(null);
            Test.stopTest();
        }
        catch(Exception e){
             System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest static void testsubmitCreditCardOrder() {
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name='Cart' LIMIT 1];
        String cartId = webCart.Id;
        User buyer= [Select Name, id from User where username like 'buyer@example.com' ];
        Map<String, Object> datamap = new Map<String, Object>();
        datamap.put('cartId', cartId);
        Map<String, Object> Expectedinfo = new  Map<String, Object>{'cartId'=>cartId,  'isSuccess'=>false, 'msg'=>'Insufficient permissions: secure query included inaccessible field'};
        
        Test.startTest();
        // Get the payment info as a buyer so that the buyer's account is used in the method call
        System.runAs(buyer) {
        Map<String, Object> PoOrder = B2BPaymentController.submitCreditCardOrder(dataMap);
          
        system.assertEquals(Expectedinfo,PoOrder);       
        }
        Test.stopTest();
           }
     @isTest static void NegtestsubmitCreditCardOrder() {
        try{ 
            Test.startTest();
            Map<String, Object> paymentInfo = B2BPaymentController.submitCreditCardOrder(null);
            Test.stopTest();
        }
        catch(Exception e){
             System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    // Verifies that the purchase order can be set in the setPayment class
    @isTest static void testSetPurchaseOrderNumber() {
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name='Cart' LIMIT 1];
        ContactPointAddress cpa1 = [SELECT Id, Name, Street, City, State, Country, PostalCode, IsDefault, ParentId, Address
                                    FROM ContactPointAddress WHERE Name='CPA1'];
       String expectedPONumber = 'ImAPoNumber';
        String paymentType = 'PurchaseOrderNumber';
        String cartId = webCart.Id;
        Map<String, Object> billingAddress = createBillingMapFromAddress(cpa1.Address);
        Map<String, Object> paymentInfo = new Map<String, Object>();
        paymentInfo.put('poNumber', expectedPONumber);
        
        Test.startTest();
        Map<String, Object> datamap = new Map<String, Object>();
        datamap.put('cartid', cartId);
        datamap.put('PO1234',expectedPONumber);
        datamap.put('paymentMethod','CC');
        datamap.put('stripeCustomerId','stripeid');
        
        
        
        
        B2BPaymentController.setPaymentInfo(datamap);
        // B2BPaymentController.setPayment(paymentType, cartId, billingAddress, paymentInfo);
        
        // Get the updated cart
        WebCart updatedCart = [SELECT PaymentMethodId, PONumber FROM WebCart WHERE Name='Cart' LIMIT 1];
        //system.assertEquals(cartId,updatedCart.id);
        System.assertEquals(null, updatedCart.PaymentMethodId);        
        // System.assertEquals(expectedPONumber, updatedCart.PONumber);
        
        Test.stopTest();
    }
     @isTest static void NegtestPurchaseOrderNumber() {
        try{ 
            Test.startTest();
             B2BPaymentController.setPaymentInfo(null);
            Test.stopTest();
        }
        catch(Exception e){
             System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest static void   testupdateOppCheckoutStatus(){
        WebCart webCart = [SELECT Id,Name FROM WebCart WHERE Name='Cart' LIMIT 1];
        Test.startTest();
        B2BPaymentController.updateOppCheckoutStatus(webCart);
        System.assertEquals('Cart', webCart.Name);
        Test.stopTest();
    }
    // Tests credit card but without providing a payment gateway
      @isTest static void NegtestupdateOppCheckoutStatus() {
        try{ 
            Test.startTest();
             B2BPaymentController.updateOppCheckoutStatus(null);
            Test.stopTest();
        }
        catch(Exception e){
             System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest static void TestupdateOrderInformation(){
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name='Cart' LIMIT 1];
        String cartId = webCart.Id;
        Map<String, Object> datamap = new Map<String, Object>();
        datamap.put('cartid', cartId);
         datamap.put('paymentMethod', 'online');
        Test.startTest();
        B2BPaymentController.updateOrderInformation(datamap);
        System.assertEquals(cartId, webCart.Id);
        Test.stopTest();
    }

     @isTest static void NegtestupdateOrderInformation() {
        try{ 
            Test.startTest();
            B2BPaymentController.updateOrderInformation(null);
            Test.stopTest();
        }
        catch(Exception e){
             System.assertEquals('Attempt to de-reference a null object', e.getMessage());
        }
    }
    
     @isTest static void TestupdateSMorderInfoInformation(){
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name='Cart' LIMIT 1];
        String cartId = webCart.Id;
        Map<String, Object> datamap = new Map<String, Object>();
        datamap.put('cartid', cartId);
        datamap.put('paymentMethod', 'online');
        Test.startTest();
        B2BPaymentController.updateSMorderInfo(datamap);
          System.assertEquals(cartId, webCart.Id);
        Test.stopTest();
    }
    @isTest static void TestupdatePaymentAuthError(){
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name='Cart' LIMIT 1];
        String cartId = webCart.Id;
        
        Map<String, Object> datamap = new Map<String, Object>();
        object chargeData ;
        Object cToken;
        datamap.put('cartid', cartId);
        datamap.put('chargeData', chargeData);
        datamap.put('cToken', cToken);
       map<String,Object> Expectedinfo= new map<String,Object>{'cToken'=>null, 'cartid'=>cartId, 'chargeData'=>null};
        Test.startTest();
        map<String,Object> orderinfo=   B2BPaymentController.updatePaymentAuthError(datamap);
        system.assertEquals(Expectedinfo, orderinfo);
        Test.stopTest();
    }
     @isTest static void NegtestupdatePaymentAuthError() {
        try{ 
            Test.startTest();
            map<String,Object> orderinfo= B2BPaymentController.updatePaymentAuthError(null);
            Test.stopTest();
        }
        catch(Exception e){
             System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest static void TestcallCreatePaymentMethodAPI(){
        
        
        Account account =[Select id from Account where name =:'TestAccount'];
        
        
        webstore webStore= [Select id from webstore where name=:'TestWebStore'] ;
        // StoreIntegratedService Testn =[Select Integration from  StoreIntegratedService where ServiceProviderType ='Payment' ];
        StoreIntegratedService  ServiceIntegration= new StoreIntegratedService ();
        ServiceIntegration.StoreId=webStore.Id;
        ServiceIntegration.ServiceProviderType ='Payment';
        ServiceIntegration.Integration='0b08c000000wtMcAAI';
        insert ServiceIntegration;
        
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name='Cart' LIMIT 1];
        String cartId = webCart.Id;
        
        Map<String, Object> datamap = new Map<String, Object>();
        object cToken;
       
        datamap.put('cartId', cartId);
       
       datamap.put('cToken', cToken);
        
       
        try{
            test.startTest();
            
             Test.setMock(HttpCalloutMock.class, new B2BPaymentControllerTestMock());  
            B2BPaymentController.callCreatePaymentMethodAPI(datamap);
            System.assertEquals(cartId, webCart.Id);
            test.stopTest();}
        catch(Exception e){}
    }
      @isTest static void TestSecondCasecallCreatePaymentMethodAPI(){
        
        
        Account account =[Select id,Name from Account where name =:'TestAccount'];
        
        
        webstore webStore= [Select id from webstore where name=:'TestWebStore'] ;
        // StoreIntegratedService Testn =[Select Integration from  StoreIntegratedService where ServiceProviderType ='Payment' ];
        StoreIntegratedService  ServiceIntegration= new StoreIntegratedService ();
        ServiceIntegration.StoreId=webStore.Id;
        ServiceIntegration.ServiceProviderType ='Payment';
        ServiceIntegration.Integration='0b08c000000wtMcAAI';
        insert ServiceIntegration;
        
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name='Cart' LIMIT 1];
        String cartId = webCart.Id;
        
        Map<String, Object> datamap = new Map<String, Object>();
        datamap.put('cartId', cartId);
        object chargeData;
       datamap.put('chargeData',chargeData);
        try{
            test.startTest();
            
             Test.setMock(HttpCalloutMock.class, new B2BPaymentControllerTestMock());  
         
            
            B2BPaymentController.callCreatePaymentMethodAPI(datamap);
            system.assertEquals('TestAccount', account.Name);
            test.stopTest();}
        catch(Exception e){}
    }
     @isTest static void TestThirdCasecallCreatePaymentMethodAPI(){
        
        
        Account account =[Select id from Account where name =:'TestAccount'];
        
        
        webstore webStore= [Select id from webstore where name=:'TestWebStore'] ;
        // StoreIntegratedService Testn =[Select Integration from  StoreIntegratedService where ServiceProviderType ='Payment' ];
        StoreIntegratedService  ServiceIntegration= new StoreIntegratedService ();
        ServiceIntegration.StoreId=webStore.Id;
        ServiceIntegration.ServiceProviderType ='Payment';
        ServiceIntegration.Integration='0b08c000000wtMcAAI';
        insert ServiceIntegration;
        
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name='Cart' LIMIT 1];
        String cartId = webCart.Id;
        
        Map<String, Object> datamap = new Map<String, Object>();
        datamap.put('cartId', cartId);
         Object  cToken;
         datamap.put(' cToken', cToken);
        try{
            test.startTest();
            
             Test.setMock(HttpCalloutMock.class, new B2BPaymentControllerTestMock());  
         
            
            B2BPaymentController.callCreatePaymentMethodAPI(datamap);
            test.stopTest();}
        catch(Exception e){
             System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest static void TestupdateOrderDetails(){
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name='Cart' LIMIT 1];
        String cartId = webCart.Id;
        Order o =[Select id from Order where  Cart__c=: webCart.Id];
        
        Map<String, Object> datamap = new Map<String, Object>();
        datamap.put('cartid', cartId);
        object PaymentMethod;
        datamap.put('paymentMethod', PaymentMethod);
        try{
        test.startTest();
        B2BPaymentController.updateOrderDetails(o.id, datamap);
            system.assertEquals('Cart', webCart.Name);
        test.stopTest();
        }
        catch(Exception e){}
        
    }
    
    
    @isTest static void TestgetOrderAccountId(){
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name='Cart' LIMIT 1];
        
        Order o =[Select id, CreatedBy.accountId from Order where name=: 'Test'];
        String cartId = webCart.Id;
        
        Map<String, Object> datamap = new Map<String, Object>();
        datamap.put('cartid', cartId);
        String ExcpetedOrd=[select id, CreatedById from Order limit 1 ].CreatedById;
        Test.startTest();
        Order ord= B2BPaymentController.getOrderAccountId(o);
        system.assertEquals(ExcpetedOrd, ord.CreatedById);
        Test.stopTest();
        
        
    }
    @isTest static void testCreditNoPaymentGateway() {
        B2BPaymentController.ProductDetailResponse onbj = new B2BPaymentController.ProductDetailResponse();
        onbj.prodImageUrl = 'prodImageUrl';
        onbj.isPriceAlreadyAvailable = true;
        onbj.isProductCompared = false;
        onbj.pricingInfo = String.valueOf('abs');
        onbj.isRecurring = true;
        onbj.prodName = 'prodName';
        onbj.prodId = 'prodId';
        onbj.prodDescription = 'prodDescription';
        onbj.pricebookEntryId = 'pricebookEntryId';
        onbj.unitPrice = 'unitPrice';
        onbj.listPrice = 'listPrice';
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name='Cart' LIMIT 1];
        ContactPointAddress cpa1 = [SELECT Id, Name, Street, City, Country, PostalCode, IsDefault, ParentId, Address
                                    FROM ContactPointAddress WHERE Name='CPA1'];
        
        String paymentType = 'CreditCard';
        String cartId = webCart.Id;
        Map<String, Object> billingAddress = createBillingMapFromAddress(cpa1.Address);
        Map<String, Object> paymentInfo = new Map<String, Object>();
        
        Test.startTest();
        
        try {
            B2BPaymentController.setPaymentInfo( paymentInfo);
            // Exception should have been thrown
            // System.assert(False, 'Expected an exception because no Payment Gateway is setup');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
            // The string we'd expect is: 'This store is not authorized to process payments.'
            // However, the way the auraHandledException is thrown, this isn't available unless we call setMessage() prior to
            // throwing the exception. So, we'll make due with a generic exception message for this reference
        }
        
        Test.stopTest();
        
    }
    
    // The payment expects a billing map with certain keys, this fills that out given an address
    static Map<String, Object> createBillingMapFromAddress(Address address) {
        Map<String, Object> billingMap = new Map<String, Object>();
        billingMap.put('street', address.Street);
        billingMap.put('city', address.City);
        billingMap.put('state', address.State);
        billingMap.put('country', address.Country);
        billingMap.put('postalCode', address.PostalCode);
        billingMap.put('latitude', address.Latitude);
        billingMap.put('longitude', address.Longitude);
        
        return billingMap;
    }
    
    // Copies the specified address into the BillingAddress in the cart
    static void setAddressInCart(WebCart webCart, Address address) {
        webCart.BillingStreet = address.Street;
        webCart.BillingCity = address.City;
        webCart.BillingState = address.State;
        webCart.BillingCountry = address.Country;
        webCart.BillingPostalCode = address.PostalCode;
        webCart.BillingLatitude = address.Latitude;
        webCart.BillingLongitude = address.Longitude;
        update(webCart);
    }
    


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
    
    // Deletes the single cart item    
    static void deleteCartItem() {
        CartItem cartItem = [SELECT Id FROM CartItem WHERE Name = 'TestProduct' LIMIT 1];
        delete cartItem;
    }
}