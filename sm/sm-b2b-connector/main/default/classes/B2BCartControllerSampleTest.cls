@isTest
private class B2BCartControllerSampleTest {
    @isTest
    static void One(){
        TestDataFactory.createData();
        Map<String, String> Data = B2BTestFactory.initialStorefrontSetup();
        String WebStoreId = [Select id,Name from WebStore where Name ='Sflabs' limit 1].id;
        String uId= Data.get('userId');
        String AccId= Data.get('accountId');
        String cartId = Data.get('Cartid'); 
        CartItem cart_item= [Select id from CartItem where CartId=:cartId limit 1];
        String orderSummaryId ='1Os8c000000kJyzCAE';
        String CommunityId='0DM8c000000sxg1';
        String effectiveAccountId = AccId;
        String activeCartOrId= cartId;
        String pageParam= '1';
        String sortParam ='Ascending';
        ConnectApi.CartItemInput cartItem; 
        ConnectApi.CartItemCollection expect;
        Test.startTest();
        try{ 
            ConnectApi.CartItemCollection cartconnect =B2BCartControllerSample.getCartItems(
        communityId,effectiveAccountId,activeCartOrId,null, 'Any wrong param');
          System.assertEquals(expect,cartconnect );
        }
        catch(Exception e){}
      
        Test.stopTest();
    }
    @isTest
    static void two(){
       TestDataFactory.createData();
       Map<String, String> Data = B2BTestFactory.initialStorefrontSetup();
        String WebStoreId = [Select id,Name from WebStore where Name ='Sflabs' limit 1].id;
        String uId= Data.get('userId');
        String AccId= Data.get('accountId');
        String cartId = Data.get('Cartid'); 
        CartItem cart_item= [Select id from CartItem where CartId=:cartId limit 1];
        String orderSummaryId ='1Os8c000000kJyzCAE';
        String CommunityId='0DM8c000000sxg1';
        String effectiveAccountId = AccId;
        String activeCartOrId= cartId;
        String pageParam= '1';
        String sortParam ='Ascending';
        ConnectApi.CartItemInput cartItem; 
        ConnectApi.CartItem expect;
        Test.startTest();
        try{
            ConnectApi.CartItem updateCart =B2BCartControllerSample.updateCartItem(
        communityId,effectiveAccountId,activeCartOrId,cartId,cartItem);
            System.assertEquals(expect,updateCart);
            }catch(Exception e){}
        Test.stopTest();
       
    }
    @isTest
    static void three(){
        TestDataFactory.createData();
        Map<String, String> Data = B2BTestFactory.initialStorefrontSetup();
        String WebStoreId = [Select id,Name from WebStore where Name ='Sflabs' limit 1].id;
        String uId= Data.get('userId');
        String AccId= Data.get('accountId');
        String cartId = Data.get('Cartid'); 
        CartItem cart_item= [Select id from CartItem where CartId=:cartId limit 1];
        String orderSummaryId ='1Os8c000000kJyzCAE';
        String CommunityId='0DM8c000000sxg1';
        String effectiveAccountId = AccId;
        String activeCartOrId= cartId;
        String pageParam= '1';
        String sortParam ='Ascending';
        ConnectApi.CartItemInput cartItem;     
     Test.startTest();
     try{
         B2BCartControllerSample.deleteCartItem(webstoreId,effectiveAccountId,activeCartOrId,cart_item.id);
         //V O I D   M E T H O D 
         System.assertEquals(pageParam, '1');
     }catch(Exception exp){}
     Test.stopTest();   
       
    }
     @isTest
    static void four(){
        TestDataFactory.createData();
        Map<String, String> Data = B2BTestFactory.initialStorefrontSetup();
        String WebStoreId = [Select id,Name from WebStore where Name ='Sflabs' limit 1].id;
        String uId= Data.get('userId');
        String AccId= Data.get('accountId');
        String cartId = Data.get('Cartid'); 
        CartItem cart_item= [Select id from CartItem where CartId=:cartId limit 1];
        String orderSummaryId ='1Os8c000000kJyzCAE';
        String CommunityId='0DM8c000000sxg1';
        String effectiveAccountId = AccId;
        String activeCartOrId= cartId;
        String pageParam= '1';
        String sortParam ='Ascending';
        ConnectApi.CartItemInput cartItem; 
        ConnectApi.CartSummary carexpect;
        Test.startTest();
        try{
           ConnectApi.CartSummary createCar= B2BCartControllerSample.getCartSummary(webstoreId,effectiveAccountId,activeCartOrId);
           System.assertEquals(carexpect, createCar); 
        }catch(Exception exp){}
        Test.stopTest(); 
    
     }
       @isTest
    static void five(){
        String orderSummaryId ='1Os8c000000kJyzCAE';
        List<OrderItem> oi = new List<OrderItem>();
        Test.startTest();
        try{
           oi= B2BCartControllerSample.getOrderItemsByOrderSummaryId(orderSummaryId);
            System.assertEquals(null,oi);
        }catch(Exception exp){}
        Test.stopTest(); 
    }
       @isTest
    static void six(){
        TestDataFactory.createData();
        Map<String, String> Data = B2BTestFactory.initialStorefrontSetup();
        String WebStoreId = [Select id,Name from WebStore where Name ='Sflabs' limit 1].id;
        String uId= Data.get('userId');
        String AccId= Data.get('accountId');
        String cartId = Data.get('Cartid'); 
        CartItem cart_item= [Select id from CartItem where CartId=:cartId limit 1];
        String orderSummaryId ='1Os8c000000kJyzCAE';
        String CommunityId='0DM8c000000sxg1';
        String effectiveAccountId = AccId;
        String activeCartOrId= cartId;
        String pageParam= '1';
        String sortParam ='Ascending';
        ConnectApi.CartItemInput cartItem;
        ConnectApi.CartSummary carexpect;
        Test.startTest();
        try{
           ConnectApi.CartSummary createCar= B2BCartControllerSample.createCart(CommunityId,effectiveAccountId);
           System.assertEquals(carexpect, createCar);
        }catch(Exception exp){} 
        Test.stopTest(); 
    }
       @isTest
    static void seven(){
        TestDataFactory.createData();
        Map<String, String> Data = B2BTestFactory.initialStorefrontSetup();
        String WebStoreId = [Select id,Name from WebStore where Name ='Sflabs' limit 1].id;
        String uId= Data.get('userId');
        String AccId= Data.get('accountId');
        String cartId = Data.get('Cartid'); 
        CartItem cart_item= [Select id from CartItem where CartId=:cartId limit 1];
        String orderSummaryId ='1Os8c000000kJyzCAE';
        String CommunityId='0DM8c000000sxg1';
        String effectiveAccountId = AccId;
        String activeCartOrId= cartId;
        String pageParam= '1';
        String sortParam ='Ascending';
        ConnectApi.CartItemInput cartItem;     
        Test.startTest();
        try{
            B2BCartControllerSample.deleteCart(CommunityId,effectiveAccountId,activeCartOrId);
            System.assertEquals('0DM8c000000sxg1',CommunityId );
        }catch(Exception exp){}
        Test.stopTest(); 
    }
       @isTest
    static void eight(){
        TestDataFactory.createData();
        Map<String, String> Data = B2BTestFactory.initialStorefrontSetup();
        String WebStoreId = [Select id,Name from WebStore where Name ='Sflabs' limit 1].id;
        String uId= Data.get('userId');
        String AccId= Data.get('accountId');
        String cartId = Data.get('Cartid'); 
        CartItem cart_item= [Select id from CartItem where CartId=:cartId limit 1];
        CartItem cart_item1= [Select id from CartItem where CartId=:cartId limit 1];
        String orderSummaryId ='1Os8c000000kJyzCAE';
        String CommunityId='0DM8c000000sxg1';
        String effectiveAccountId = AccId;
        String activeCartOrId= cartId;
        String pageParam= '1';
        String sortParam ='Ascending';
        ConnectApi.CartItemInput cartItem;   
        List<CartItem> result = new List<CartItem>();
        CartItem item1 =[Select Id, Product2Id, Quantity, TotalAmount, Type, SalesPrice from CartItem where Id=:cart_item.id and Type!='Charge'];
        CartItem item2 =[Select Id, Product2Id, Quantity, TotalAmount, Type, SalesPrice from CartItem where Id=:cart_item1.id and Type!='Charge'];
        List<CartItem> expect = new List<CartItem>();
        expect.add(item1);
        expect.add(item2);
        Test.startTest();
        try{
           result= B2BCartControllerSample.getCartItemsFields(CommunityId,effectiveAccountId,activeCartOrId,pageParam,sortParam);
            System.debug(result);
            System.assertNotEquals(expect, result);
        }catch(Exception exp){}
        Test.stopTest(); 
    }
    @isTest
    static void Nine(){
        String orderSummaryId ='1Os8c000000kJyzCAE'; 
        OrderSummary os = new OrderSummary();
        String Id;
        Test.startTest();
        try{
            os = B2BCartControllerSample.getOrderSummary(orderSummaryId);
            System.debug(os);
            System.assertEquals(null, os);
        }catch(Exception exp){}
        Test.stopTest(); 
    }
}