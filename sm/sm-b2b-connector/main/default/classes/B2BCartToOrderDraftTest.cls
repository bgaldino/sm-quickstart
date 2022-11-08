@isTest
private class B2BCartToOrderDraftTest {

    @TestSetup
    static void makeData(){
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            TestDataFactory.createData();
            TestDataFactory.createTaxEngine();
        }
    }

    @IsTest
    static void testCartToOrder() {
        Product2 product1 = [SELECT id, Name FROM Product2 WHERE Name = 'Test Product1' LIMIT 1];
        WebCart cart = [SELECT Id, Name, AccountId, OwnerId, WebStoreId, PoNumber, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude,
                            (SELECT Id, Street__c, Country__c, City__c, Postal_Code__c, State__c, Name FROM B2B_Shipping_Addresses__r LIMIT 1) 
                            FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        CartItem cartItems = [SELECT Id, AdjustmentAmount, Product2Id, B2B_PriceBookEntry_Id__c, Type, Quantity, ListPrice, SalesPrice, TotalLineAmount FROM CartItem WHERE CartId =: cart.Id];
        PricebookEntry prices = [SELECT Id, UnitPrice, ProductSellingModelId, ProductSellingModel.SellingModelType FROM PricebookEntry WHERE Id =: cartItems.B2B_PriceBookEntry_Id__c LIMIT 1];
        ProductSellingModel model = [SELECT Id, PricingTerm, Name, SellingModelType FROM ProductSellingModel WHERE Id =: prices.ProductSellingModelId LIMIT 1];
        ProrationPolicy prorationPolicy = [SELECT Id FROM ProrationPolicy WHERE RemainderStrategy = 'AddToFirst' LIMIT 1];
        TaxTreatment taxTreatment = [SELECT Id, TaxEngineId, TaxPolicyId FROM TaxTreatment WHERE TaxPolicyId != null AND Status = 'Active' LIMIT 1];
        CartCheckoutSession session = [SELECT id, Name FROM CartCheckoutSession WHERE WebCartId =: cart.Id LIMIT 1];
        CartDeliveryGroup cartDeliveryGroupId = [SELECT Id, DesiredDeliveryDate, DeliverToName, ShippingInstructions, DeliverToStreet, DeliverToCity, DeliverToState, DeliverToPostalCode, DeliverToCountry, DeliverToLatitude, DeliverToLongitude, DeliveryMethodId, CartId FROM CartDeliveryGroup WHERE DeliveryMethodId != null AND CartId = :cart.Id LIMIT 1];
        CartTax CT= new CartTax();
        CT.CartItemId= cartItems.id;
        CT.TaxRate= 10;
        CT.Amount=10;
        CT.Name= 'TestCartTax';
        CT.TaxType='Estimated';    
            CT.TaxCalculationDate=System.today(); 
        insert CT;
        Test.startTest();
        B2BCartToOrderDraft.B2BCartToOrderDraftRequest request = new B2BCartToOrderDraft.B2BCartToOrderDraftRequest();
        request.checkoutSessionId = session.Id;
        request.cartId = cart.Id;
        List<ID> checkList = new List<Id>();
        
            checkList = B2BCartToOrderDraft.cartToOrder(new B2BCartToOrderDraft.B2BCartToOrderDraftRequest[] {request});
       
        System.assertNotEquals(checkList.size(), 0);
        test.stopTest();
	}

    @IsTest
    static void testCartToOrderTermDefined() {
        Product2 product1 = [SELECT id, Name FROM Product2 WHERE Name = 'Test Product1' LIMIT 1];
        Product2 product2 = [SELECT id, Name FROM Product2 WHERE Name = 'Term Product1' LIMIT 1];
        WebCart cart = [SELECT Id, Name, AccountId, OwnerId, WebStoreId, PoNumber, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude,
                            (SELECT Id, Street__c, Country__c, City__c, Postal_Code__c, State__c, Name FROM B2B_Shipping_Addresses__r LIMIT 1) 
                            FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        CartItem cartItems = [SELECT Id, AdjustmentAmount, Product2Id, B2B_PriceBookEntry_Id__c, Type, Quantity, ListPrice, SalesPrice, TotalLineAmount FROM CartItem WHERE CartId =: cart.Id];
        PricebookEntry prices = [SELECT Id, UnitPrice, Product2Id, ProductSellingModelId, ProductSellingModel.SellingModelType, ProductSellingModel.PricingTerm, ProductSellingModel.PricingTermUnit FROM PricebookEntry WHERE Product2Id =: product2.Id LIMIT 1];
        ProductSellingModel model = [SELECT Id, PricingTerm, Name, SellingModelType FROM ProductSellingModel WHERE Id =: prices.ProductSellingModelId LIMIT 1];
        ProrationPolicy prorationPolicy = [SELECT Id FROM ProrationPolicy WHERE RemainderStrategy = 'AddToFirst' LIMIT 1];
        TaxTreatment taxTreatment = [SELECT Id, TaxEngineId, TaxPolicyId FROM TaxTreatment WHERE TaxPolicyId != null AND Status = 'Active' LIMIT 1];
        CartCheckoutSession session = [SELECT id, Name FROM CartCheckoutSession WHERE WebCartId =: cart.Id LIMIT 1];
        CartDeliveryGroup cartDeliveryGroupId = [SELECT Id, DesiredDeliveryDate, DeliverToName, ShippingInstructions, DeliverToStreet, DeliverToCity, DeliverToState, DeliverToPostalCode, DeliverToCountry, DeliverToLatitude, DeliverToLongitude, DeliveryMethodId, CartId FROM CartDeliveryGroup WHERE DeliveryMethodId != null AND CartId = :cart.Id LIMIT 1];
        CartTax CT= new CartTax();
        CT.CartItemId= cartItems.id;
        CT.TaxRate= 10;
        CT.Amount=10;
        CT.Name= 'TestCartTax';
        CT.TaxType='Estimated';    
            CT.TaxCalculationDate=System.today(); 
        insert CT;
        Test.startTest();
        update cartItems;
        B2BCartToOrderDraft.B2BCartToOrderDraftRequest request = new B2BCartToOrderDraft.B2BCartToOrderDraftRequest();
        request.checkoutSessionId = session.Id;
        request.cartId = cart.Id;
        List<ID> checkList = new List<Id>();

            checkList = B2BCartToOrderDraft.cartToOrder(new B2BCartToOrderDraft.B2BCartToOrderDraftRequest[] {request});
        System.assertEquals(checkList.size(), 1);
        test.stopTest();
	}

    @IsTest
    static void testCartToOrderChargeProduct() {
        WebCart cart = [SELECT Id, Name, AccountId, OwnerId, WebStoreId, PoNumber, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude,
                            (SELECT Id, Street__c, Country__c, City__c, Postal_Code__c, State__c, Name FROM B2B_Shipping_Addresses__r LIMIT 1) 
                            FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        CartItem cartItems = [SELECT Id, AdjustmentAmount, Product2Id, B2B_PriceBookEntry_Id__c, Type, Quantity, ListPrice, SalesPrice, TotalLineAmount FROM CartItem WHERE CartId =: cart.Id];
        PricebookEntry prices = [SELECT Id, UnitPrice, ProductSellingModelId, ProductSellingModel.SellingModelType FROM PricebookEntry WHERE Id =: cartItems.B2B_PriceBookEntry_Id__c LIMIT 1];
        ProductSellingModel model = [SELECT Id, PricingTerm, Name, SellingModelType FROM ProductSellingModel WHERE Id =: prices.ProductSellingModelId LIMIT 1];
        ProrationPolicy prorationPolicy = [SELECT Id FROM ProrationPolicy WHERE RemainderStrategy = 'AddToFirst' LIMIT 1];
        TaxTreatment taxTreatment = [SELECT Id, TaxEngineId, TaxPolicyId FROM TaxTreatment WHERE TaxPolicyId != null AND Status = 'Active' LIMIT 1];
        CartCheckoutSession session = [SELECT id, Name FROM CartCheckoutSession WHERE WebCartId =: cart.Id LIMIT 1];
        CartDeliveryGroup cartDeliveryGroupId = [SELECT Id, DesiredDeliveryDate, DeliverToName, ShippingInstructions, DeliverToStreet, DeliverToCity, DeliverToState, DeliverToPostalCode, DeliverToCountry, DeliverToLatitude, DeliverToLongitude, DeliveryMethodId, CartId FROM CartDeliveryGroup WHERE DeliveryMethodId != null AND CartId = :cart.Id LIMIT 1];
        Test.startTest();
        cartItems.Type = 'Charge';
        cartItems.ListPrice = prices.UnitPrice;
        cartItems.AdjustmentAmount = prices.UnitPrice;
        cartItems.SalesPrice = prices.UnitPrice;
        update cartItems;
        B2BCartToOrderDraft.B2BCartToOrderDraftRequest request = new B2BCartToOrderDraft.B2BCartToOrderDraftRequest();
        request.checkoutSessionId = session.Id;
        request.cartId = cart.Id;
        List<ID> checkList = new List<Id>();

        CartTax CT= new CartTax();
        CT.CartItemId= cartItems.id;
        CT.TaxRate= 10;
        CT.Amount=10;
        CT.Name= 'TestCartTax';
        CT.TaxType='Estimated';    
            CT.TaxCalculationDate=System.today(); 
        insert CT;
       
        checkList = B2BCartToOrderDraft.cartToOrder(new B2BCartToOrderDraft.B2BCartToOrderDraftRequest[] {request});
        
        System.assertEquals(checkList.size(), 1);
        test.stopTest();
	}

    @IsTest
    static void testCartToOrderSimpleProduct() {
        Product2 product1 = [SELECT id, Name FROM Product2 WHERE Name = 'Test Product1' LIMIT 1];
        Product2 product2 = [SELECT id, Name FROM Product2 WHERE Name = 'Test Product2' LIMIT 1];
        WebCart cart = [SELECT Id, Name, AccountId, OwnerId, WebStoreId, PoNumber, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude,
                            (SELECT Id, Street__c, Country__c, City__c, Postal_Code__c, State__c, Name FROM B2B_Shipping_Addresses__r LIMIT 1) 
                            FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        CartItem cartItems = [SELECT Id, AdjustmentAmount, Product2Id, B2B_PriceBookEntry_Id__c, Type, Quantity, ListPrice, SalesPrice, TotalLineAmount FROM CartItem WHERE CartId =: cart.Id];
        PricebookEntry prices = [SELECT Id, UnitPrice, ProductSellingModelId, ProductSellingModel.SellingModelType FROM PricebookEntry WHERE Id =: cartItems.B2B_PriceBookEntry_Id__c LIMIT 1];
        PricebookEntry priceProduct2 = [SELECT Id, UnitPrice, Product2Id FROM PricebookEntry WHERE Product2Id =: product1.Id LIMIT 1];
        
        ProrationPolicy prorationPolicy = [SELECT Id FROM ProrationPolicy WHERE RemainderStrategy = 'AddToFirst' LIMIT 1];
        TaxTreatment taxTreatment = [SELECT Id, TaxEngineId, TaxPolicyId FROM TaxTreatment WHERE TaxPolicyId != null AND Status = 'Active' LIMIT 1];
        CartCheckoutSession session = [SELECT id, Name FROM CartCheckoutSession WHERE WebCartId =: cart.Id LIMIT 1];
        CartDeliveryGroup cartDeliveryGroupId = [SELECT Id, DesiredDeliveryDate, DeliverToName, ShippingInstructions, DeliverToStreet, DeliverToCity, DeliverToState, DeliverToPostalCode, DeliverToCountry, DeliverToLatitude, DeliverToLongitude, DeliveryMethodId, CartId FROM CartDeliveryGroup WHERE DeliveryMethodId != null AND CartId = :cart.Id LIMIT 1];
        CartTax CT= new CartTax();
        CT.CartItemId= cartItems.id;
        CT.TaxRate= 10;
        CT.Amount=10;
        CT.Name= 'TestCartTax';
        CT.TaxType='Estimated';    
            CT.TaxCalculationDate=System.today(); 
        insert CT;
        Test.startTest();
        update cartItems;
        B2BCartToOrderDraft.B2BCartToOrderDraftRequest request = new B2BCartToOrderDraft.B2BCartToOrderDraftRequest();
        request.checkoutSessionId = session.Id;
        request.cartId = cart.Id;
        List<ID> checkList = new List<Id>();

        checkList = B2BCartToOrderDraft.cartToOrder(new B2BCartToOrderDraft.B2BCartToOrderDraftRequest[] {request});

        System.assertEquals(checkList.size(), 1);
        test.stopTest();
	}
}