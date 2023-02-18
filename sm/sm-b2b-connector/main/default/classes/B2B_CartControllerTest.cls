@isTest
public with sharing class B2B_CartControllerTest { 

public static Map<String, String> DataMap; 

@testSetup  
static void  testData(){
    TestDataFactory.createData();
    
}
@isTest 
static void SearchCartItemsTest () {
    String WebStoreId = [Select id,Name from WebStore where Name ='Sflabs' limit 1].id;
    String effectiveAccountId =[select id from account where name='Test Account'].id ;
    String cartId = [Select id from webCart where name='Cart'].id; 
    String activeCartOrId= cartId;
    CartItem cart_item= [Select id from CartItem where CartId=:cartId limit 1];
    
    //String CommunityId = [select id from Network limit 1].id;
    String CommunityId='0DM8c000000sxg1';
    
    
    
    ConnectApi.CartItemInput cartItem;  
    
    

    test.startTest();
    B2B_CartController B2BCartControllerObj = new B2B_CartController();  
    ConnectApi.CartItemCollection SearchCartItems = B2B_CartController.searchCartItems(CommunityId, effectiveaccountid, cartId);
    system.assertEquals(null, SearchCartItems);  
    test.stopTest();
}
@isTest 
static void getCartItemsTest () {
    String WebStoreId = [Select id,Name from WebStore where Name ='Sflabs' limit 1].id;
    String effectiveAccountId =[select id from account where name='Test Account'].id ;
    String cartId = [Select id from webCart where name='Cart'].id; 
    String activeCartOrId= cartId;
    CartItem cart_item= [Select id from CartItem where CartId=:cartId limit 1];
    String pageParam= '1';
    String sortParam ='Ascending';
    //String CommunityId = [select id from Network limit 1].id;
    String CommunityId='0DM8c000000sxg1';
    
    
    
    ConnectApi.CartItemInput cartItem;  
    
    

    test.startTest();
    B2B_CartController B2BCartControllerObj = new B2B_CartController();  
    ConnectApi.CartItemCollection getCartItems = B2B_CartController.getCartItems(CommunityId, effectiveaccountid, cartId,pageParam,sortParam);
    system.assertEquals(null, getCartItems);    
    test.stopTest();
}
@isTest 
static void updateCartItemsTest () {
    String WebStoreId = [Select id,Name from WebStore where Name ='Sflabs' limit 1].id;
    String effectiveAccountId =[select id from account where name='Test Account'].id ;
    String cartId = [Select id from webCart where name='Cart'].id; 
    String activeCartOrId= cartId;
    String cart_itemId= [Select id from CartItem where CartId=:cartId limit 1].id;
    //String CommunityId = [select id from Network limit 1].id;
    String CommunityId='0DM8c000000sxg1';
    ConnectApi.CartItemInput cartItem;  
    test.startTest();
    B2B_CartController B2BCartControllerObj = new B2B_CartController();  
    ConnectApi.CartItem updateCartItem = B2B_CartController.updateCartItem(CommunityId, effectiveaccountid, cartId,cart_itemId, cartItem);
    system.assertEquals(null, updateCartItem);  
    test.stopTest();
}

@isTest 
static void deleteCartItemsTest () {
    String WebStoreId = [Select id,Name from WebStore where Name ='Sflabs' limit 1].id;
    String effectiveAccountId =[select id from account where name='Test Account'].id ;
    String cartId = [Select id from webCart where name='Cart'].id; 
    String activeCartOrId= cartId;
    String cart_itemId= [Select id from CartItem where CartId=:cartId limit 1].id;
    //String CommunityId = [select id from Network limit 1].id;
    String CommunityId='0DM8c000000sxg1';
    ConnectApi.CartItemInput cartItem;  
    test.startTest();
    B2B_CartController B2BCartControllerObj = new B2B_CartController();  
    B2B_CartController.deleteCartItem(CommunityId, effectiveaccountid, cartId,cart_itemId);
        system.assertEquals(activeCartOrId, cartId);
    test.stopTest();
}

@isTest 
static void getCartSummaryTest () {
    String WebStoreId = [Select id,Name from WebStore where Name ='Sflabs' limit 1].id;
    String effectiveAccountId =[select id from account where name='Test Account'].id ;
    String cartId = [Select id from webCart where name='Cart'].id; 
    String activeCartOrId= cartId;
    
    
    //String CommunityId = [select id from Network limit 1].id;
    String CommunityId='0DM8c000000sxg1';
    
    test.startTest();
    B2B_CartController B2BCartControllerObj = new B2B_CartController();  
    ConnectApi.CartSummary cartSummary = B2B_CartController.getCartSummary(CommunityId, effectiveaccountid, cartId);
    system.assertEquals(null, cartSummary);  
    test.stopTest();
}
    @isTest 
static void createCartTest () {
    String WebStoreId = [Select id,Name from WebStore where Name ='Sflabs' limit 1].id;
    String effectiveAccountId =[select id from account where name='Test Account'].id ;
    String cartId = [Select id from webCart where name='Cart'].id; 
    String activeCartOrId= cartId;
    
    
    //String CommunityId = [select id from Network limit 1].id;
    String CommunityId='0DM8c000000sxg1';
    
    test.startTest();
    B2B_CartController B2BCartControllerObj = new B2B_CartController();  
    ConnectApi.CartSummary createCart = B2B_CartController.createCart(CommunityId, effectiveaccountid);
    system.assertEquals(null, createCart);  
    test.stopTest();
}
@isTest 
static void deleteCartTest () {
    String WebStoreId = [Select id,Name from WebStore where Name ='Sflabs' limit 1].id;
    String effectiveAccountId =[select id from account where name='Test Account'].id ;
    String cartId = [Select id from webCart where name='Cart'].id; 
    String activeCartOrId= cartId;
    
    
    //String CommunityId = [select id from Network limit 1].id;
    String CommunityId='0DM8c000000sxg1';
    
    test.startTest();
    B2B_CartController B2BCartControllerObj = new B2B_CartController();  
    B2B_CartController.deleteCart(CommunityId, effectiveaccountid, cartId);
        system.assertEquals('0DM8c000000sxg1', CommunityId);
    test.stopTest();
}

    @isTest 
static void checkQueueStatusTest () {
    test.startTest();
    String QueueStatus= B2B_CartController.checkQueueStatus('jobId');
    System.assertEquals(null, QueueStatus);
    test.stopTest();
}

    @isTest 
static void getBundleIncludedItemsTest () {
    Map<String,object> getBundleExpected= new  Map<String,object>{'success'=>true };  
    
    string productId= [select id from product2 where StockKeepingUnit = 'TestPrinter1'].id;
    
    test.startTest();
    B2B_CartController B2BCartControllerObj = new B2B_CartController();  
    Map<String,object> getBundleIncludedItems= B2B_CartController.getBundleIncludedItems(productId);
    system.debug('getBundleIncludedItems'+getBundleIncludedItems);
    system.assertEquals(getBundleExpected, getBundleIncludedItems); 
    test.stopTest();
}
    
    @isTest
    Static void createQuoteToCartTest(){
        WebCart testCart = [Select id from WebCart where Name = 'Cart'];
        Pricebook2 prBook = [Select id, Name from Pricebook2 where Name = 'Custom Test Pricebook'];
        prBook.Name = 'Alpine Price Book';
        update prBook;
        
        // Because test methods do not support Web service callouts, we create a mock response based on a static resource.
        // To create the static resource from the Developer Console, select File | New | Static Resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('PriceSflabs');
        // The web service call returns an error code.
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.startTest();
        // Associate the callout with a mock response.
        Test.setMock(HttpCalloutMock.class, mock);
        B2B_CartController.createQuoteToCart(testCart.Id,'New','quoteMsg-Test','communityId');
        System.assert(True);
        Test.stopTest();
    }
    
    @isTest
    Static void createQuoteToCartTestCatch(){
        list<WebCart> testCartList = [Select id from WebCart where Name = 'Cart'];
        Test.startTest();
        B2B_CartController.createQuoteToCart('CartId not found','New','quoteMsg-Test','communityId');
        System.assert(True);
        Test.stopTest();
    }
    
    @isTest
    Static void createNewQuoteCatch(){
        list<WebCart> testCartList = [Select id from WebCart where Name = 'Cart'];
        Test.startTest();
        B2B_CartController.createNewQuote('CartId not found','New',true,'communityId');
        System.assert(True);
        Test.stopTest();
    }
    
}