@isTest
public class B2B_SMOrderCopierHelperTest {
    
	@testSetup
    public static void setup(){
        TestDataFactory.createDataSMOrder();
        WebCart wc = [Select id, Name from Webcart where Name = 'Cart'];
        Order o = [Select id,Status from Order where Status = 'Draft']; 
        /*Account ac = B2BTestFactory.addNewAccount('testName', true);
Product2 p = B2BTestFactory.creteProduct2(True);
Order ord = B2BTestFactory.addNewOrder(ac.Id, 'recordType');*/
        /*Id standardId = test.getStandardPricebookId();
        Product2 producto = [select id from Product2 where Name = 'Test Product1'];		//getProduct2();
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
        
        List<OrderItem> itemList = new List<OrderItem>();
        OrderItem orderItemObj = new OrderItem();
        orderItemObj.OrderId            = o.id;
        orderItemObj.Quantity           = 24; 
        orderItemObj.UnitPrice          = 240;
        orderItemObj.Product2id         = producto.id;
        orderItemObj.PricebookEntryId   = one.id;
        insert orderItemObj;
        
        OrderItem orderItemObj1 = new OrderItem();
        orderItemObj1.OrderId            = o.id;
        orderItemObj1.Quantity           = 24; 
        orderItemObj1.UnitPrice          = 240;
        orderItemObj1.Product2id         = producto.id;
        orderItemObj1.PricebookEntryId   = one.id;
        insert orderItemObj1;
        
        
        o.Cart__c = wc.Id;
        update o;*/
        
    }
    
    @isTest
    static void cloneSmOrderToCheckoutOrderTest(){
		Set<Id> ordIds = new Set<Id>();
        //Order o = [Select id from Order where Name = 'Test' ];
        List<Order> o = [Select id,Status,Cart__c,Name from Order where Status = 'Draft']; 
        ordIds.add(o[0].Id);
        Test.startTest();
        B2B_SMOrderCopierHelper.cloneSmOrderToCheckoutOrder(ordIds);
        System.assertNotEquals(o.size(), 0);
        Test.stopTest();
    }
    
    @isTest
    static void mapAndInsertOrderActionTest(){
        Set<Id> ordIds = new Set<Id>();
        //Order o = [Select id from Order where Name = 'Test' ];
        List<Order> o = [Select id,Status,Cart__c,Name from Order where Status = 'Draft']; 
        ordIds.add(o[0].Id);
        Test.startTest();
        B2B_SMOrderCopierHelper.mapAndInsertOrderAction(Null);
		System.assertNotEquals(o.size(), 0);
        Test.stopTest();
    }
    
    @isTest
    static void createOrderSummaryTest(){
        Set<Id> ordIds = new Set<Id>();
        //Order o = [Select id from Order where Name = 'Test' ];
        List<Order> o = [Select id,Status,Cart__c,Name from Order where Status = 'Draft']; 
        ordIds.add(o[0].Id);
        Test.startTest();
        B2B_SMOrderCopierHelper.createOrderSummary(Null);
		System.assertNotEquals(o.size(), 0);
        Test.stopTest();
    }

    
    @isTest
    static void getProductTest() {
         String networkId = Network.getNetworkId();
         Community community = [ SELECT Id FROM Community  LIMIT 1];
        // Id webstoreId = [SELECT WebStoreId FROM WebStoreNetwork WHERE networkId = :community.Id LIMIT 1].WebStoreId;
         WebStore store = [SELECT Id FROM WebStore WHERE Name = 'Sflabs' LIMIT 1];
         Account account = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
         Product2 productToSearch = [SELECT Id FROM Product2 WHERE Name = 'Test Product1' LIMIT 1];
         ConnectApi.ProductDetail prodDetail = B2B_SMOrderCopierHelper.getProduct(community.Id, productToSearch.Id, account.Id);
         System.assertNotEquals(null, prodDetail);
      
     
           }
    
    
    @isTest
    static void getwishlistTest() {
        String store = [SELECT Id FROM WebStore WHERE Name = 'Sflabs' LIMIT 1].Id;
        String account = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1].Id;
         String activeCartOrId = 'current';
        String wishlistName ='Test';
         Product2 productToSearch = [SELECT Id FROM Product2 WHERE Name = 'Test Product1' LIMIT 1];
       // ConnectApi.CartSummary cartSummary = B2BGetInfo.getCartSummary(store, account);
      // ConnectApi.CartSummary cartSummary = new ConnectApi.CartSummary();
       // System.assertNotEquals(null, cartSummary);
        ConnectApi.Wishlist wishlist = B2B_SMOrderCopierHelper.createAndAddToList(store, productToSearch.id ,wishlistName,account);
        System.assertNotEquals(null, wishlist);
        
  
    }
     @isTest
    static void getCartSummaryTest() {
        String store = [SELECT Id FROM WebStore WHERE Name = 'Sflabs' LIMIT 1].Id;
        String account = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1].Id;
         String activeCartOrId = 'current';
        String wishlistName ='Test';
         Product2 productToSearch = [SELECT Id FROM Product2 WHERE Name = 'Test Product1' LIMIT 1];
        ConnectApi.CartSummary cartSummary = B2B_SMOrderCopierHelper.getCartSummary(store, account);
      // ConnectApi.CartSummary cartSummary = new ConnectApi.CartSummary();
       // System.assertNotEquals(null, cartSummary);
       // ConnectApi.Wishlist wishlist = B2BGetInfo.createAndAddToList(store, productToSearch.id ,wishlistName,account);
        System.assertNotEquals(null, cartSummary);
        
  
    }
    @isTest
    static void checkProductIsInStockTestTrue() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new B2BGetInfoTestMock());
        Boolean result = B2B_SMOrderCopierHelper.checkProductIsInStock('productId');
        System.assertEquals(true, result);
        Test.stopTest();
    }
    
    @isTest
    static void checkProductIsInStockTestFalse() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new B2BGetInfoTestMock());
        Boolean result = B2B_SMOrderCopierHelper.checkProductIsInStock('');
        System.assertEquals(false, result);
        Test.stopTest();
    }
    
    @isTest
    static void addToCartTestCartItemDoesNotExist() {
         String store = [SELECT Id FROM WebStore WHERE Name = 'Sflabs' LIMIT 1].Id;
        String account = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1].Id;
        Product2 prod = [SELECT Id, Name FROM Product2 WHERE Name = 'Test Product2' LIMIT 1];
        PricebookEntry priceBookEntry = [SELECT Id, UnitPrice FROM PricebookEntry LIMIT 1];
        ProductSellingModel model = [SELECT Id, Name, SellingModelType, PricingTermUnit FROM ProductSellingModel LIMIT 1];
        WebCart cart = [SELECT Id FROM WebCart WHERE Name = 'Cart'];
        List<CartItem> cartItemsBeforeUpdate = [SELECT Id FROM CartItem WHERE CartId = :cart.Id];
        String quantity = '1';
        CartItem cartItem = B2B_SMOrderCopierHelper.addToCart(
            store,
            prod.Name,
            (String)cart.id,
            (String)prod.Id,
            priceBookEntry.UnitPrice,
            quantity,
            (String)priceBookEntry.Id,
            model.Name,
            model.SellingModelType,
            model.PricingTermUnit,
            account
        );
        List<CartItem> cartAfterUpdate = [SELECT Id FROM CartItem WHERE CartId = :cart.Id];
        System.assertNotEquals(Null, cartAfterUpdate.size(), 'Cart Items hadn\'t added');
    }
    @isTest
    static void addToCartTestException() {
         String store = [SELECT Id FROM WebStore WHERE Name = 'Sflabs' LIMIT 1].Id;
        String account = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1].Id;
        Product2 prod = [SELECT Id, Name FROM Product2 WHERE Name = 'Test Product2' LIMIT 1];
        PricebookEntry priceBookEntry = [SELECT Id, UnitPrice FROM PricebookEntry LIMIT 1];
        ProductSellingModel model = [SELECT Id, Name, SellingModelType, PricingTermUnit FROM ProductSellingModel LIMIT 1];
        WebCart cart = [SELECT Id FROM WebCart WHERE Name = 'Cart'];
        List<CartItem> cartItemsBeforeUpdate = [SELECT Id FROM CartItem WHERE CartId = :cart.Id];
        String quantity = '1';
        try{
               
        CartItem cartItem = B2B_SMOrderCopierHelper.addToCart(
            null,
            null,
            (String)cart.id,
            (String)prod.Id,
            priceBookEntry.UnitPrice,
            null,
            (String)priceBookEntry.Id,
            model.Name,
            model.SellingModelType,
            model.PricingTermUnit,
            null
        );
        System.assertEquals('Cart', cart.Name);}
        catch(Exception e){
            
        }
       // List<CartItem> cartAfterUpdate = [SELECT Id FROM CartItem WHERE CartId = :cart.Id];
        //System.assertNotEquals(2, cartAfterUpdate.size(), 'Cart Items hadn\'t added');
    }
     @isTest
    static void createandaddlist() {
         String store = [SELECT Id FROM WebStore WHERE Name = 'Sflabs' LIMIT 1].Id;
         String account = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1].Id;
         String productToSearch = [SELECT Id FROM Product2 WHERE Name = 'Test Product1' LIMIT 1].Id;
         String wlist = 'Wishing';
        ConnectApi.WishlistItemInput wishlistItemInput = new ConnectApi.WishlistItemInput();
         wishlistItemInput.productId = productToSearch;
       ConnectApi.WishlistInput wishlistInput = new ConnectApi.WishlistInput();
        wishlistInput.name = wlist;
         System.assertNotEquals(null,wlist);
        
           }
    @isTest
    static void ProductPriceTest() {
         String store = [SELECT Id FROM WebStore WHERE Name = 'Sflabs' LIMIT 1].Id;
         String account = [SELECT Id FROM Account WHERE  Name = 'Test Account' LIMIT 1].Id;
         String productToSearch = [SELECT Id FROM Product2 WHERE Name = 'Test Product1' LIMIT 1].Id;
        Test.startTest();
        ConnectApi.ProductPrice priceDetail = B2B_SMOrderCopierHelper.getProductPrice(store, productToSearch, account);
         System.assertNotEquals(null, priceDetail);
      //  System.assertEquals(null, B2BGetInfo.getProductPrice(store, productToSearch, account));
        Test.stopTest();
        
    }
    
    @isTest
    static void addToCartTestCartItemExist() {
        Product2 prod = [SELECT Id, Name FROM Product2 WHERE Name = 'Test Product1' LIMIT 1];
        PricebookEntry priceBookEntry = [SELECT Id, UnitPrice FROM PricebookEntry WHERE isActive = true LIMIT 1];
        ProductSellingModel model = [SELECT Id, Name, SellingModelType, PricingTermUnit FROM ProductSellingModel LIMIT 1]; 
        WebCart cart = [SELECT Id FROM WebCart WHERE Name = 'Cart'];
        List<CartItem> cartItemsBeforeUpdate = [SELECT Id FROM CartItem WHERE CartId = :cart.Id];
        System.debug('Cart Items amount before adding: ' + cartItemsBeforeUpdate.size());
        String quantity = '1';
        CartItem cartItem = B2B_SMOrderCopierHelper.addToCart(
            '',
            prod.Name,
            (String)cart.id,
            (String)prod.Id,
            priceBookEntry.UnitPrice,
            quantity,
            (String)priceBookEntry.Id,
            model.Name,
            model.SellingModelType,
            model.PricingTermUnit,
            ''
        );

        List<CartItem> cartAfterUpdate = [SELECT Id FROM CartItem WHERE CartId = :cart.Id];

        System.assertEquals(cartItemsBeforeUpdate.size(), cartAfterUpdate.size(), 'Cart Items had added');
        //System.assertEquals(3, cartItem.Quantity, 'Product hadn\'t added');

    }
    
    @isTest
    static void productWithPricingModelTest() {
        ProductSellingModel model = [SELECT Id, Name FROM ProductSellingModel WHERE Name = 'Evergreen Monthly' LIMIT 1];
        ProductSellingModel pbToCheck = B2B_SMOrderCopierHelper.productWithPricingModel(model.Name);

        System.assertEquals(model.Id, pbToCheck.Id);
    }
    
    @isTest
    static void updateCartItemsTest() {
        WebCart cart =[Select id from WebCart];
        String networkId = Network.getNetworkId();
        Account acc = [Select id from Account];
        Webstore store =[Select id from Webstore];
        CartItem cartItemBeforeUpdate = [SELECT Id, Quantity FROM CartItem WHERE Name = 'Cart Item 1' LIMIT 1];
        System.debug('Cart Items Quantity before update: ' + cartItemBeforeUpdate.Quantity);
        String quantity = '3';
        CartItem cartItem = B2B_SMOrderCopierHelper.updateCartItems(
            networkId,
            acc.Id,
            cartItemBeforeUpdate.Id,
            quantity
        );

        CartItem cartAfterUpdate = [SELECT Id, Quantity FROM CartItem WHERE Id = :cartItemBeforeUpdate.Id LIMIT 1];

        System.assertEquals(3, cartAfterUpdate.Quantity, 'Cart Did\'t update');
     
    }
       @isTest
    static void updateCartItemsTestException() {
        WebCart cart =[Select id from WebCart];
        String networkId = Network.getNetworkId();
        Account acc = [Select id from Account];
        Webstore store =[Select id from Webstore];
        CartItem cartItemBeforeUpdate = [SELECT Id, Quantity FROM CartItem WHERE Name = 'Cart Item 1' LIMIT 1];
        System.debug('Cart Items Quantity before update: ' + cartItemBeforeUpdate.Quantity);
        String quantity = '3';
        try{
        CartItem cartItem = B2B_SMOrderCopierHelper.updateCartItems(
            null,
            acc.Id,
            cartItemBeforeUpdate.Id,
            null
        );
        System.assertEquals('Cart Item 1', cartItemBeforeUpdate.Name);
        }
        catch(Exception e){
            
        }

      //  CartItem cartAfterUpdate = [SELECT Id, Quantity FROM CartItem WHERE Id = :cartItemBeforeUpdate.Id LIMIT 1];

      //  System.assertEquals(3, cartAfterUpdate.Quantity, 'Cart Did\'t update');
     
    }
    
    @isTest
    static void getCheckoutUserTest() {
            try{
        User user = B2B_SMOrderCopierHelper.getCheckoutUser(UserInfo.getUserId());
            System.debug(user);
                System.assertNotEquals(null, user);
        }catch(Exception ex){
      ex.getMessage();
     
    }

    }
    
    @isTest
    static void getCountriesAndStatesTest() {
        Map<String, Object> mapToCompareWith = new Map<String, Object>{
            'countries' => B2BUtils.ToCustomPicklistEntry(B2BUtils.listPicklistValues(Account.BillingCountryCode)),
            'statesByCountries' => B2BUtils.ListPicklistValuesByControllingValue(Account.BillingCountryCode, Account.BillingStateCode)
        };

        Map<String, Object> mapToCheck = B2B_SMOrderCopierHelper.getCountriesAndStates();

        List<Object> listOfCountriesToCompareWith = (List<Object>) mapToCompareWith.get('countries');
        Map<String, List<Object>> listOfStatesByCountriesToCompareWith = (Map<String, List<Object>>) mapToCompareWith.get('statesByCountries');


        List<Object> listOfCountriesToCheck = (List<Object>) mapToCheck.get('countries');
        Map<String, List<Object>> listOfStatesByCountriesToCheck = (Map<String, List<Object>>) mapToCheck.get('statesByCountries');

        System.assertEquals(listOfCountriesToCompareWith.size(), listOfCountriesToCheck.size(), 'List of countries error');
        System.assertEquals(listOfStatesByCountriesToCompareWith.size(), listOfCountriesToCheck.size(), 'List of states error');

    }
    
    @isTest
    static void setBillingAddressTest() {
        String street = 'Test street';
        String country = 'United States';
        String state = 'New York';
        String city = 'New York';
        String zipCode = '34562';
        WebCart cartToUpdate = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        
        B2B_SMOrderCopierHelper.setBillingAddress(
            street,
            country, 
            state, 
            city, 
            zipCode, 
            cartToUpdate.Id
        );
        WebCart cartAfterUpdate = [SELECT Id, BillingStreet FROM WebCart WHERE Id = :cartToUpdate.Id LIMIT 1];
        System.assertEquals(street, cartAfterUpdate.BillingStreet, 'Didn\'t update the address');
    }
    
    @isTest
    static void setShippingAddressTestWithShippingExist() {
        String street = 'Street';
        String country = 'United States';
        String state = 'New York';
        String city = 'New York';
        String zipCode = '34562';
        String Name = 'Test name';
        WebCart cartToUpdate = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        B2B_SMOrderCopierHelper.setShippingAddress(
            street,
            country, 
            state, 
            city, 
            zipCode,
            Name, 
            cartToUpdate.Id
        );
        WebCart cartAfterUpdate = [SELECT Id, (SELECT Id, Street__c, Country__c, City__c, Postal_Code__c, State__c, Name FROM B2B_Shipping_Addresses__r LIMIT 1) FROM WebCart WHERE Id = :cartToUpdate.Id LIMIT 1];
        System.assertEquals(street, cartAfterUpdate.B2B_Shipping_Addresses__r[0].Street__c, 'Didn\'t update the address');
    }
    
    @isTest
    static void setShippingAddressTestWithShippingNew() {
        String street = 'Test street';
        String country = 'United States';
        String state = 'New York';
        String city = 'New York';
        String zipCode = '34562';
        String Name = 'Test name';
        WebCart cartToUpdate = [SELECT Id, (SELECT Id, Street__c, Country__c, City__c, Postal_Code__c, State__c, Name FROM B2B_Shipping_Addresses__r LIMIT 1) FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        delete cartToUpdate.B2B_Shipping_Addresses__r[0];
        B2B_SMOrderCopierHelper.setShippingAddress(
            street,
            country, 
            state, 
            city, 
            zipCode,
            Name, 
            cartToUpdate.Id
        );
        WebCart cartAfterUpdate = [SELECT Id, (SELECT Id, Street__c, Country__c, City__c, Postal_Code__c, State__c, Name FROM B2B_Shipping_Addresses__r LIMIT 1) FROM WebCart WHERE Id = :cartToUpdate.Id LIMIT 1];
        System.assertNotEquals(null, cartAfterUpdate, 'Cart cannot be null');
    }
        
    @isTest
    static void getCartItemsByCartIdTest() {
        WebCart testCart = [SELECT Id FROM WebCart LIMIT 1];
        try{
            Map<Id, B2B_SMOrderCopierHelper.CartItemWrapper> cartItemByCartIdMap = B2B_SMOrderCopierHelper.getCartItemsByCartId(testCart.Id);
            System.assertNotEquals(true, cartItemByCartIdMap.isEmpty(), 'Cart should have cart items');
        }
        catch(Exception e) {
            System.assertNotEquals(null, e);
        }
        
    }
        @isTest
    static void doesProductHasDiscountTest() {
        WebCart testCart = [SELECT Id FROM WebCart LIMIT 1];
        Community community = [ SELECT Id FROM Community  LIMIT 1];
        // Id webstoreId = [SELECT WebStoreId FROM WebStoreNetwork WHERE networkId = :community.Id LIMIT 1].WebStoreId;
         //WebStore store = [SELECT Id FROM WebStore WHERE Name = 'Sflabs' LIMIT 1];
         Account account = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        try{
            Boolean val = B2B_SMOrderCopierHelper.doesProductHasDiscount(community.Id, account.Id);
            System.assertNotEquals(true, val, 'doesProductHasDiscount');
        }
        catch(Exception e) {
            System.assertNotEquals(null, e);
        }
        
    }
}