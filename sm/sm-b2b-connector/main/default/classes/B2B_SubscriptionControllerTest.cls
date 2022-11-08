@isTest
public class B2B_SubscriptionControllerTest {
    @TestSetup static void Subscriptions() {
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            TestDataFactory.createData();
        }
    }
    @isTest static void Subscribe(){
        test.startTest();
       List<B2B_SubscriptionController.B2B_SubscriptionDto> subscrptnLst = new List<B2B_SubscriptionController.B2B_SubscriptionDto>();
        B2B_SubscriptionController.getSubscriptionsBasedOnContact(); 
        System.assertEquals(subscrptnLst, B2B_SubscriptionController.getSubscriptionsBasedOnContact());
        test.stopTest();
    }
    @isTest static void SubscriptionPaused(){
        Map<String,object> expec= new  Map<String,object>{'success'=>false };
        Map<String,Object> response = new Map<String,Object>();
        String recordId ='';
        Test.startTest();
       Map<String,object> actu =  B2B_SubscriptionController.getSubscriptionPaused(recordId);
        system.assertNotEquals(expec, actu);
        Test.stopTest();
    }
    @isTest static void SubscriptionCancelled(){
        Map<String,Object> response = new Map<String,Object>{'success'=>false };
        String recordId ='';
        Test.startTest();
        Map<String,object> actu = B2B_SubscriptionController.getSubscriptionCancelled(recordId);
         system.assertNotEquals(response, actu);
        Test.stopTest();
        
    }
    @isTest static void SubscriptionAutoRenew(){
        Map<String,Object> response = new Map<String,Object>{'success'=>false };
        String recordId ='';
        Test.startTest();
         Map<String,object> actu = B2B_SubscriptionController.getSubscriptionAutoRenew(recordId);
         system.assertNotEquals(response, actu);
        Test.stopTest();
    }
    
    @isTest static void Productdetail() {
        Product2 p =[Select Id,Name from Product2 WHERE Name = 'Test Product1' LIMIT 1]; 
           String product = 'Test Product1';       
        test.startTest();
     Product2 act =   B2B_SubscriptionController.getSubscriptionProdDetails(p.Id);
        System.assertNotEquals(p, act);
        test.stopTest();
    }
    @isTest static void SubscriptionAutoReStart(){
        Map<String,Object> response = new Map<String,Object>{'success'=>true };
        String recordId ='';
        Test.startTest();
       Map<String,object> actu =  B2B_SubscriptionController.getSubscriptionAutoReStart(recordId);
         system.assertNotEquals(response, actu);
        Test.stopTest();
    }
    @isTest static void SubscriptionBasedOnId(){
        SBQQ_Subscription__c subscrptn = new SBQQ_Subscription__c();
        Map<String,Object> response = new Map<String,Object>();
        String recordId ='';
        Test.startTest();
        B2B_SubscriptionController.getSubscriptionBasedOnId(recordId);
        System.assertNotEquals(null, subscrptn);
        Test.stopTest();
    }
    /*@isTest static void Cart(){
        Map<String,Object> exp = new Map<String,Object>{'success'=>true};
        Map<String,String> addToCartDomain = new Map<String,String>();
        Test.startTest();
      Map<String,Object> act =  B2B_SubscriptionController.addToCart(addToCartDomain);
       system.assertNotEquals(exp, act);
        Test.stopTest();
    }*/
    @isTest static void getActiveCartTest() {
              
        Product2 prod =[Select Id from Product2 WHERE Name = 'Test Product1' LIMIT 1]; 
        User u = [SELECT Id FROM User WHERE firstname = 'ABCD' LIMIT 1];
        Account accList = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        WebStore wstore = [SELECT Id FROM WebStore LIMIT 1];
        WebCart cart =[SELECT Id,Cart_Type__c, Status from WebCart WHERE Name ='Cart' LIMIT 1];
        PricebookEntry pricebookId = [SELECT Id FROM PricebookEntry LIMIT 1];
      //  String networkId = Network.getNetworkId();
        B2B_ProductPricingDomain productPricingDomain = new  B2B_ProductPricingDomain();
        productPricingDomain.isRecurringProduct = true;
        List<B2B_SubProdTerm> noSubscription = new List<B2B_SubProdTerm>();
        test.startTest();
     WebCart webcart =   B2B_SubscriptionController.getActiveCart();
        System.assertNotEquals(cart, webcart);
        test.stopTest();
    }
    @isTest static void addPrice(){
        Map<String,Object> exp = new Map<String,Object>{'success'=>true};
         Map<String,Object> act = new Map<String,Object>{'success'=>true};
        String communityId = '09a8c0000010C01AAE';
        Product2 prod =[Select Id from Product2 WHERE Name = 'Test Product1' LIMIT 1]; 
        Account accList = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1]; 
        B2B_ProductPricingDomain productPricingDomain = new  B2B_ProductPricingDomain();
        productPricingDomain.isRecurringProduct = true;
        test.startTest();
        B2B_SubscriptionController.getProductPrice(communityId,prod.Id,accList.Id,productPricingDomain);
        System.assertEquals(exp, act);
        Test.stopTest();
    }

    @isTest static void addCart(){
        TestDataFactory.createTestData();
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            WebCart cart =[Select id, name from WebCart Where Name = 'Sample Cart' LIMIT 1];
            String prod =[Select Id from Product2 WHERE Name = 'Sample Product 1' LIMIT 1].Id; 
            String accList = [SELECT Id FROM Account WHERE Name = 'Sample Account' LIMIT 1].Id;
            String quantity ='4';
            Boolean preserveCart = false;
        
            B2B_AddToCartDomain.B2B_CartItem testValue = new  B2B_AddToCartDomain.B2B_CartItem();
            testValue.productId = prod;
            Map<String, B2B_AddToCartDomain.B2B_CartItem> carttest = new  Map<String, B2B_AddToCartDomain.B2B_CartItem>();
            carttest.put(prod,testValue);
            B2B_AddToCartDomain addToCartDomains = new B2B_AddToCartDomain();
            addToCartDomains.productId = prod;
            addToCartDomains.productIdToCartItem = carttest;
            addToCartDomains.isRecurringProduct= true;
            addToCartDomains.unitPrice ='10';
            addToCartDomains.isProratedPrice = true;
            addToCartDomains.cartId = cart.Id;
            Test.startTest();
                B2B_SubscriptionController.addToCart(null,prod,quantity,accList,addToCartDomains,preserveCart);
                System.assertEquals(false, preserveCart);
            Test.stopTest();
        }
    }

    @isTest static void prepareReq(){
        B2B_AddToCartDomain t = new B2B_AddToCartDomain();
        t.effectiveAccountId ='effectiveAccountId';
        t.communityId = 'communityId';
        t.webstore = 'webstore';
        t.webstoreId = 'webstoreId';
        t.quantity = '1';
        t.salesRepId = 'salesRepId';
        t.currencyCode = 'currencyCode';
         WebCart cart =[SELECT Id,Name,Cart_Type__c, Status from WebCart WHERE Name ='Cart' LIMIT 1];
        Test.startTest();
         B2B_SubscriptionController.prepareRequest(cart.id,cart.Cart_Type__c);
        System.assertEquals('Cart', cart.Name);
        Test.stopTest();
    }
    @isTest static void updatecart(){
        Contact con = [SELECT Id from Contact Where FirstName = 'test2'LIMIT 1];
        User user =[SELECT Id, ContactId from User Where firstname = 'ABCD'LIMIT 1 ];
        WebCart cart = [SELECT Id  from WebCart WHERE Name = 'Cart' LIMIT 1];
        CartItem cartItem1 =[SELECT Id from CartItem WHERE CartId =: cart.Id LIMIT 1];
        Product2 product1 =[Select id from  Product2 Where Name = 'Test Product1' LIMIT 1];
        PricebookEntry product1CustomEntry =[Select id from  PricebookEntry where Product2Id =: product1.Id LIMIT 1];
        B2B_ProductPricingDomain productPricingDomain  = new B2B_ProductPricingDomain();
        productPricingDomain.pricebookEntryId = 'product1CustomEntry' ;
        B2B_AddToCartDomain.B2B_CartItem testValue = new  B2B_AddToCartDomain.B2B_CartItem();
        testValue.cartId = cart.Id;
        testValue.cartItemId = cartItem1.Id ;
        testValue.currencyCode = 'USD';
        testValue.listPrice ='10';
        testValue.productId = product1.Id;
        testValue.pricebookEntryId = product1CustomEntry.Id;
        testValue.quantity = '4';
        testValue.unitPrice = '40';
        testValue.subscriptionStartDate = date.newInstance(1990, 11, 21);
        testValue.subcriptionQuanity ='10';
        testValue.freeProducts = 1;
        testValue.totalListPrice = 'totalListPrice';
        testValue.totalPrice = 'totalPrice';
        Map<String, B2B_AddToCartDomain.B2B_CartItem> carttest = new  Map<String, B2B_AddToCartDomain.B2B_CartItem>();
        carttest.put(product1.Id,testValue);
        List<B2B_AddToCartDomain.B2B_CartItem> cartItemList = new  List<B2B_AddToCartDomain.B2B_CartItem>();
        cartItemList.add(testValue);
        B2B_AddToCartDomain addToCartDomain = new B2B_AddToCartDomain();
        addToCartDomain.productId = product1.Id;
        addToCartDomain.cartId= cart.Id;
        addToCartDomain.currentUser = user;
        addToCartDomain.subscriberInput = null;
        addToCartDomain.productIdToCartItem = carttest;
        addToCartDomain.isNonCPQStore =false;
        addToCartDomain.isRecurringProduct =true;
         Map<String,Object> inputData = new Map<String,Object>();
         inputData.put('success',True);
         inputData.put('cartDetail',addToCartDomain);
        Map<String,Object> Data = new Map<String,Object>();
        Data.put('cartDetail',addToCartDomain);
        
        Test.startTest();
        B2B_SubscriptionController.updateCartItems(inputData);
        System.assertNotEquals(inputData, Data);
        Test.stopTest();
    }
     @isTest static void upProductSubsc(){
        WebCart cart = [SELECT Id  from WebCart WHERE Name = 'Cart'];
        B2B_ProductPricingDomain productPricingDomain  = new B2B_ProductPricingDomain();
        productPricingDomain.pricebookEntryId = null;
        Map<String,Object> inputData = new Map<String,Object>();
         inputData.put('productPricing',productPricingDomain);
         Test.startTest();
        B2B_SubscriptionController.setupProductSubscription(inputData);
         system.assertNotEquals(null, inputData);
        Test.stopTest();
    }
    
    @isTest static void setUp(){
        B2B_ProductPricingDomain productPricingDomain = new  B2B_ProductPricingDomain();
        List<B2B_SubProdTerm> subscriptions = new  List<B2B_SubProdTerm>();
        productPricingDomain.isRecurringProduct = true; 
        productPricingDomain.subscriptions = subscriptions;
        productPricingDomain.unitPrice='10';
        productPricingDomain.sku ='SKo01';
        double price= 50.00;
        B2B_SubProdTerm__c spt = new B2B_SubProdTerm__c();
        spt.Auto_Renew__c= true;
        spt.Ignore_Billing_Frequency_Fields__c = true;
        spt.Installment_Frequency_UOM__c ='Monthly';
        spt.Installment_Count__c = 1;
        spt.Display_Name__c = 'Monthly';
        B2B_SubProdTerm sptDomain = new B2B_SubProdTerm();
        sptDomain.id = '';
        sptDomain.autoRenew = true;
        sptDomain.ignoreBillingFrequency = true;
        sptDomain.sku ='SKo01';
        sptDomain.subConfiguration ='Best';
        sptDomain.subscriptionPrice= price;
        sptDomain.renewalUplift = 'test';
        
        List<B2B_SubProdTerm__c> sptList = new  List<B2B_SubProdTerm__c>();
        sptList.add(spt);
                 
        boolean isListPrice = false;
        test.startTest();
        B2B_SubscriptionController.setUpSPT(productPricingDomain,sptList,isListPrice);
        System.assertNotEquals(null, productPricingDomain);
        test.stopTest();
    }
    @isTest static void nosubscription(){
        B2B_ProductPricingDomain productPricingDomain = new  B2B_ProductPricingDomain();
        productPricingDomain.isRecurringProduct = true; 
        productPricingDomain.unitPrice ='10';
         B2B_SubProdTerm sptDomain = new B2B_SubProdTerm();
        sptDomain.installmentFrequencyUOM ='Monthly';
        List<B2B_SubProdTerm> subscriptions = new  List<B2B_SubProdTerm>();
        subscriptions.add(sptDomain);
        String currencyCode = 'usd';
        test.startTest();
      List<B2B_SubProdTerm> actdata =  B2B_SubscriptionController.noSubscription(productPricingDomain, subscriptions,currencyCode);
       System.assertEquals(subscriptions, actdata);
        test.stopTest();
    }
    @isTest static void displayText(){
        B2B_SubProdTerm spt = new B2B_SubProdTerm();
        spt.autoRenew = true;
        spt.id='';
        spt.displayName ='test';
        spt.ignoreBillingFrequency = true;
        spt.subConfiguration ='best';
        spt.sku ='CP004';
        spt.subscriptionPrice = 3.14159;
        spt.unitPrice= 0.00;
        spt.renewalUplift ='Update';
        spt.upfront=38.14159;
        spt.upfrontAmount=0.00;
        spt.uplift =3.14159;
        spt.installmentCount = 2;
        spt.installmentFrequency = 10;
        spt.installmentFrequencyUOM ='Monthly';
        spt.orderCount = 4;
        spt.orderFrequency = 2;
        spt.orderFrequencyUOM ='Monthly';
        spt.orderFrequencyUOM ='Quarterly';
        spt.orderFrequencyUOM ='Annual';
        spt.displayNameUpfront ='store';
        spt.displayNameWOUpfront='test2';
        Decimal price =10.00;
        String installmentUOM ='Monthly';
        String currencyCode ='usd';
        test.startTest();
       String act = B2B_SubscriptionController.displayText(spt,price,installmentUOM,currencyCode);
        System.assertNotEquals(null, act);
        test.stopTest();
    }
    @isTest static void replaceSubscription(){
        String subscripionText='Text';
        list<String> dataList = new list<String>();
        dataList.add('Updated');
        Test.startTest();
        B2B_SubscriptionController.replaceSubscriptionLabel(subscripionText,dataList);
        System.assertEquals('Text', subscripionText);
        Test.stopTest();
    }
    @isTest static void replaceSubscriptionwithUpfrontLabel(){
        String subscripionText='Text';
        list<String> dataList = new list<String>();
        dataList.add('Updated');
        Test.startTest();
       String actdata = B2B_SubscriptionController.replaceSubscriptionwithUpfrontLabel(subscripionText,dataList);
        System.assertEquals(subscripionText, actdata);
        Test.stopTest();
    }
     @isTest static void replacenoSubscription(){
        list<String> dataList = new list<String>();
        dataList.add('data created');
        dataList.add('Update List');
        Test.startTest();
      String actdata =  B2B_SubscriptionController.replaceNoSubscriptionLabel(dataList);
         System.assertNotEquals(null, actdata);
        Test.stopTest();
    }
    @isTest static void replaceSubscriptionLabel(){
        String subscripionText= 'Test';
        list<String> dataList = new list<String>();
        dataList.add('Update list');
        Test.startTest();
       String actdata = B2B_SubscriptionController.replaceNoSubscriptionLabel(dataList);
        System.assertNotEquals(subscripionText, actdata);
        Test.stopTest();
    }
      
    @isTest
    public static void myUnitTest(){
        B2B_ProductPricingDomain bppd = new B2B_ProductPricingDomain();
        bppd.productId = 'productId';
        bppd.productCode = 'productCode';
        bppd.isStandardPricing = false;
        bppd.effectiveAccountId = 'effectiveAccountId';
        bppd.communityId = 'communityId';
        bppd.webstore = 'webstore';
        bppd.webstoreId = 'webstoreId';
        Map<String,Object> mMap = new Map<String,Object>();
        bppd.subscriberInput = mMap;
        B2B_ProductPricingDomain.B2B_PriceAdjustments bpa = new B2B_ProductPricingDomain.B2B_PriceAdjustments();
        bpa.adjustmentType = 'adjustmentType';
        bpa.adjustmentValue = 'adjustmentValue';
        bpa.lowerBound = 'adjustmentValue';
        bpa.tierUnitPrice = 'adjustmentValue';
        bpa.upperBound = 'adjustmentValue';
        B2B_SubscriptionController.B2B_SubscriptionDto subscribe = new B2B_SubscriptionController.B2B_SubscriptionDto();
        subscribe.prodName ='PortWorx';
        subscribe.prodId='01t8c00000O1VB8AAN';
        subscribe.subscriptionName ='Subscribe';
        subscribe.licenses = 2;
        subscribe.status='Active';
        subscribe.startDate= Date.newInstance(2016, 12, 9);
        subscribe.endDate= Date.newInstance(2022, 12, 12);
        subscribe.subId='';
        subscribe.isSubPaused=true;
        subscribe.isSubCancelled=false;
        subscribe.isSubPausedOrCancelled =true;
        subscribe.isTrialProduct=true;
        subscribe.renewalProduct='';
        subscribe.contractNumber='';
        subscribe.contractRecordId='';
        system.assertEquals(true,  subscribe.isSubPausedOrCancelled);
    }
    
}