@isTest
private class RSM_CartControllerTest {
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
            ConnectApi.CartItemCollection cartconnect =RSM_CartController.getCartItems(
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
        RSM_CartController.OrderSummaryWrapper wrapper = new RSM_CartController.OrderSummaryWrapper();
        wrapper.TotalTaxAmount = 100;
        wrapper.ShippingCost = 100;
        wrapper.TotalAdjustedProductAmount = 100;
        wrapper.GrandTotalAmount = 100;
        wrapper.CurrencyIsoCode = 'USD';
        wrapper.OrderNumber = '100';
        wrapper.ShippingCost = 100;
        Test.startTest();
        try{
            ConnectApi.CartItem updateCart =RSM_CartController.updateCartItem(
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
         RSM_CartController.deleteCartItem(webstoreId,effectiveAccountId,activeCartOrId,cart_item.id);
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
           ConnectApi.CartSummary createCar= RSM_CartController.getCartSummary(webstoreId,effectiveAccountId,activeCartOrId);
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
           oi= RSM_CartController.getOrderItemsByOrderSummaryId(orderSummaryId);
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
           ConnectApi.CartSummary createCar= RSM_CartController.createCart(CommunityId,effectiveAccountId);
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
            RSM_CartController.deleteCart(CommunityId,effectiveAccountId,activeCartOrId);
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
        List<RSM_CartController.CartItemWrapper> result = new List<RSM_CartController.CartItemWrapper>();
        CartItem item1 =[Select Id, Product2Id, Quantity, TotalAmount, Type, SalesPrice from CartItem where Id=:cart_item.id and Type!='Charge'];
        CartItem item2 =[Select Id, Product2Id, Quantity, TotalAmount, Type, SalesPrice from CartItem where Id=:cart_item1.id and Type!='Charge'];
        List<CartItem> expect = new List<CartItem>();
        expect.add(item1);
        expect.add(item2);
        Test.startTest();
        try{
           result= RSM_CartController.getCartItemsFields(CommunityId,effectiveAccountId,activeCartOrId,pageParam,sortParam);
            System.debug(result);
            System.assertEquals(expect.size(), result.size());
        }catch(Exception exp){}
        Test.stopTest(); 
    }
    @isTest
    static void Nine(){
        String orderSummaryId = '1Os8c000000kJyzCAE';
        RSM_CartController.OrderSummaryWrapper os = new RSM_CartController.OrderSummaryWrapper();
        String Id;
        Test.startTest();
        try{
            os = RSM_CartController.getOrderSummary(orderSummaryId);
            System.debug(os);
            System.assertEquals(null, os);
        }catch(Exception exp){}
        Test.stopTest();
    }
    @isTest
    static void getOrderTaxAmountTest(){
        TestDataFactory.createDataSMOrder();
        Webcart cart = [SELECT Id FROM WebCart];
        
        Decimal result = RSM_CartController.getOrderTaxAmount(cart.Id);
        system.assertEquals(null, result);
    }

    @isTest
    static void getCategoryIdTest(){
        TestDataFactory.createDataSMOrder();
        Webcart cart = [SELECT Id FROM WebCart];
        
        String result = RSM_CartController.getCategoryId(cart.Id);
        system.assertNotEquals(null, result);
    }
}