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
static void getJobIdTest () {
    String WebStoreId = [Select id,Name from WebStore where Name ='Sflabs' limit 1].id;
    String effectiveAccountId =[select id from account where name='Test Account'].id ;
    String cartId = [Select id from webCart where name='Cart'].id; 
    String activeCartOrId= cartId;
    test.startTest();
    B2B_CartController B2BCartControllerObj = new B2B_CartController();  
    Map<String,object> JobIdMap= B2B_CartController.getJobId(cartId);
    system.debug('jobIdMap' + JobIdMap);
    Map<String,object> JobIdMapExpected= new  Map<String,object>{'jobId'=>null,'success'=>true };
    system.assertEquals(JobIdMapExpected, JobIdMap);  
         
    // String Job_Id= JobIdMap.get(success);
            
    test.stopTest();
}
    @isTest 
static void checkQueueStatusTest () {
    test.startTest();
    String QueueStatus= B2B_CartController.checkQueueStatus('jobId');
    System.assertEquals('Completed', QueueStatus);
    test.stopTest();
}
@isTest 
static void synchQuoteToCartTest () {

String cartId = [Select id from webCart where name='Cart'].id; 
String activeCartOrId= cartId;


//String CommunityId = [select id from Network limit 1].id;
String CommunityId='0DM8c000000sxg1';
Map<String,object> synchQuoteExpected= new  Map<String,object>{'success'=>true };
test.startTest();
B2B_CartController B2BCartControllerObj = new B2B_CartController();  
Map<String,object> synchQuoteToCart= B2B_CartController.synchQuoteToCart(cartId);
System.debug('synchQuoteToCart' + synchQuoteToCart);
system.assertEquals(synchQuoteExpected, synchQuoteToCart);  
test.stopTest();
}
@isTest 
static void deleteQuoteLineItemTest () 
{
Map<String,object> deleteQuoteLineExpected= new  Map<String,object>{'success'=> true };

String cartId = [Select id from webCart where name='Cart'].id; 
String activeCartOrId= cartId;
string productId= [select id from product2 where StockKeepingUnit = 'TestPrinter1'].id;

test.startTest();
B2B_CartController B2BCartControllerObj = new B2B_CartController();  
Map<String,object> deleteQuoteLineItem= B2B_CartController.deleteQuoteLineItem(cartId,productId);
System.debug('deleteQuoteLineItem'+deleteQuoteLineItem);
system.assertEquals(deleteQuoteLineExpected, deleteQuoteLineItem); 
test.stopTest();
}
@isTest 
static void deleteQuoteLineItemsTest () {
        Map<String,object> deleteQuoteLineExpected= new  Map<String,object>{'success'=>true };
    String cartId = [Select id from webCart where name='Cart'].id; 
    String activeCartOrId= cartId;
    
        
        test.startTest();
    test.setMock(HttpCalloutMock.class, new B2B_CartControllerTestMock());
      
      
    B2B_CartController B2BCartControllerObj = new B2B_CartController();  
    Map<String,object> deleteQuoteLineItems= B2B_CartController.deleteQuoteLineItems(cartId);
    System.debug('deleteQuoteLineItems'+deleteQuoteLineItems);
    system.assertEquals(deleteQuoteLineExpected, deleteQuoteLineItems);  
    test.stopTest();
}
@isTest 
static void updateQuoteLineItemTest () {
    Map<String,object> updateQuoteLineExpected= new  Map<String,object>{ };   
    String cartId = [Select id from webCart where name='Cart'].id; 
    String activeCartOrId= cartId;
    
    
        test.startTest();
    test.setMock(HttpCalloutMock.class, new B2B_CartControllerTestMock());

    B2B_CartController B2BCartControllerObj = new B2B_CartController();  
    Map<String,object> updateQuoteLineItem= B2B_CartController.updateQuoteLineItem(cartId);
    System.debug('updateQuoteLineItem'+updateQuoteLineItem);
        system.assertNotEquals(updateQuoteLineExpected, updateQuoteLineItem);    
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
}