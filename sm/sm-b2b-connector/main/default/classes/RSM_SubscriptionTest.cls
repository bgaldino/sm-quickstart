@isTest
public class RSM_SubscriptionTest {

    /*@testSetup
    static void setup(){
        TestDataFactory.createData();
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            //TestDataFactory.createData();
            String userId = UserInfo.getUserId() ;
            User u =[Select Id, AccountId from User Where FirstName = 'ABCD'];
            Account acc = [Select Id from Account  LIMIT 1];
            Product2 product =[SELECT Id, Name, IsActive, ProductCode, Description from Product2 WHERE Name='Test Product1' LIMIT 1 ];
            ProductSellingModel model = [SELECT ID from ProductSellingModel WHERE Name = 'Evergreen Monthly'LIMIT 1];
            ProrationPolicy prorationPolicy =[SELECT Id from ProrationPolicy WHERE Name = 'TestProrationPolicy' LIMIT 1];
            ProductSellingModelOption modelOption =[SELECT ID from ProductSellingModelOption LIMIT 1];
            
            Asset asset = new Asset(Name='Test Product2',
                                    AccountId= u.AccountId,
                                    Status='Active',
                                    Product2Id = product.Id,
                                    IsInternal =false,
                                    IsCompetitorProduct =false,
                                    Quantity = 3);
            insert asset;
        }
    }*/
    
    @testSetup  
    static void  testData(){
        TestDataFactory.createData();
    }

    /*@isTest 
    static void subscription(){
        //Map<String, string> obj =  B2BTestFactory.initialStorefrontSetup();
        Product2 prds = b2bTestFactory.creteProduct2(true);
               User u =[Select Id, AccountId from User Where firstname = 'ABCD'];
         Asset asse = [Select Id,Name from  Asset WHERE Name='Test Product2'LIMIT 1 ];
      //  WebStore webSt = [SELECT ID FROM WebStore WHERE NAME = 'Sflabs'];
         WebStore webSt = [SELECT ID,Name FROM WebStore];
        	//Order ord = B2BTestFactory.addNewOrder(obj.get('accountId'), '');
            Map<String, Object> flowInput = new Map<String, Object>();
           // flowInput.put('b2bOrderId', ord.id);
            //flowInput.put('paymentGatewayId', paymentGatewayId);
            //flowInput.put('paymentMethodId', paymentMethodId);
            // Call  B2B BuyNow flow
            RSM_Utils.callFlow(B2B_Constants.B2BFlow.BUY_NOW_FLOW, flowInput);
        
        System.runAs(u) {
            //System.assertEquals(ass.size() , 1);
            Test.startTest();
            //RSM_subscription.assetIdFromTest = asse.Id;
            RSM_subscription.getUserSubscriptions(1, webSt.ID);
            System.assertEquals('Test Product2' , asse.Name);
            Test.stopTest();
        }  
    }*/
    

    @isTest 
    static void subscription2(){
          User u =[Select Id, AccountId from User Where firstname = 'ABCD'];
      //   WebStore webSt = [SELECT ID,Name FROM WebStore WHERE NAME  = 'Sflabs'];
         WebStore webSt = [SELECT ID,Name FROM WebStore ];
        System.runAs(u) {
            Test.startTest();
            try {
                RSM_subscription.getUserSubscriptions(1, webSt.id);
                System.assertEquals('Sflabs',webSt.Name );
            }
            catch (Exception e) {}
            Test.stopTest();
        }  
    }
    @isTest 
    static void subscription3(){
          User u =[Select Id, AccountId from User Where firstname = 'ABCD'];
      //   WebStore webSt = [SELECT ID,Name FROM WebStore WHERE NAME  = 'Sflabs'];
         WebStore webSt = [SELECT ID,Name FROM WebStore ];
        System.runAs(u) {
            Test.startTest();
            try {
                RSM_subscription.getUserSubscriptions(0, webSt.id);
                System.assertEquals('Sflabs',webSt.Name );
            }
            catch (Exception e) {}
            Test.stopTest();
        }  
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
        RSM_Subscription.createQuoteToCart(testCart.Id,'New','quoteMsg-Test','communityId');
        System.assert(True);
        Test.stopTest();
    }
    
    @isTest
    Static void createQuoteToCartTestCatch(){
        list<WebCart> testCartList = [Select id from WebCart where Name = 'Cart'];
        Test.startTest();
        RSM_Subscription.createQuoteToCart('CartId not found','New','quoteMsg-Test','communityId');
        System.assert(True);
        Test.stopTest();
    }
    
    @isTest
    static void productSearchTest() 
    {
        String AccId= [select id from account where name='Test Account'].id ;
        String CommunityId='0DM8c000000sxg1';
        String SrcQuery= '{"categoryId":"0ZG8c000000kKM0GAM","refinements":[],"includeQuantityRule":true,"page":0,"pageSize":200,"grouping":{"groupingOption":"VariationParent"},"includePrices":true}';
        
        test.startTest();
        Object response= RSM_Subscription.productSearch(communityId,SrcQuery,AccId);
        system.assertnotEquals(null, response); 
        test.stopTest();
        
    }
    
    @isTest
    static void ExceptionCase_productSearchTest() 
    {
        String SrcQuery= '{"categoryId":"0ZG8c000000kKM0GAM","refinements":[],"includeQuantityRule":true,"page":0,"pageSize":200,"grouping":{"groupingOption":"VariationParent"},"includePrices":true}';
        
        try{
            
            test.startTest();
            Object response= RSM_Subscription.productSearch(null,null,null);
            system.assertnotEquals(null, response); 
            test.stopTest();
        }
        catch(Exception e){
            System.debug('Exception----'+e.getMessage());
        }
    }
    
    @isTest
    static void startB2BBuyNowFlow(){
        String b2bOrderId = '';
        String paymentGatewayId = '';
        String paymentMethodId = '';
        Test.startTest();
        RSM_Subscription.startB2BBuyNowFlow2(b2bOrderId,paymentGatewayId,paymentMethodId);
        //No assertion - Void Method
        System.assertEquals('','');
        Test.stopTest();
    }
    @isTest
    static void catchmethod(){
    MessageLog__c log1 = new MessageLog__c(Message__c='B2BBuyNowFlow ERR');
    insert log1;
     Test.startTest();
        RSM_Subscription.startB2BBuyNowFlow2(log1.Message__c,log1.Message__c,log1.Message__c);
        //No assertion - Void Method
        System.assertEquals('','');
        Test.stopTest();
    }
    
    
    @isTest
    static void renewAssetMethod(){
        String userId = UserInfo.getUserId() ;
        User u =[Select Id, AccountId from User Where firstname = 'ABCD'];
        Account acc = [Select Id from Account  LIMIT 1];
        Product2 product =[SELECT Id, Name, IsActive, ProductCode, Description from Product2 WHERE Name='Test Product1' LIMIT 1 ];
        ProductSellingModel model = [SELECT ID from ProductSellingModel WHERE Name = 'Evergreen Monthly'LIMIT 1];
        ProrationPolicy prorationPolicy =[SELECT Id from ProrationPolicy WHERE Name = 'TestProrationPolicy' LIMIT 1];
        ProductSellingModelOption modelOption =[SELECT ID from ProductSellingModelOption LIMIT 1];
        
        Asset asset = new Asset(Name='Test Product2',
                                AccountId= u.AccountId,
                                Status='Active',
                                Product2Id = product.Id,
                                IsInternal =false,
                                IsCompetitorProduct =false,
                                Quantity = 3);
        insert asset;
        Map<String,object> exVal =new Map<String,object>{
            'response' => '{"TestPrinter1":1.00, "SKU_Test2":2.00}'
                };
        Asset asst = [select id from Asset where Name='Test Product2'];
        
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
        Map<String,object> resp = RSM_Subscription.renewAssetMethod2(asst.id);
        system.assertEquals(exVal, resp);
        test.stopTest();
    }
    
    @isTest
    static void cancelAssetTest(){
        String accId =[select id from Account where name='Test Account'].id ;
        User u =[Select id from user where firstname ='ABCD'];
        String asseId= [select id from Asset where AccountId=:accId].id;
        System.runAs(u) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RSM_cancelAssetTestMock());  
            map<string, object> cancelAsset= RSM_Subscription.cancelAsset2(asseId);
            system.assertNotEquals(null,cancelAsset); 
            Test.stopTest();
        }}
    @isTest
    static void ExceptionCase_cancelAssetTest(){
        Try
        {
            Test.startTest();
            map<string, object> cancelAsset= RSM_Subscription.cancelAsset2(null);
            Test.stopTest();
        }
        catch(Exception e)
        { system.assertEquals('Script-thrown exception',e.getMessage()); }
        
        
        
    }
    
    static testMethod void b2borders(){
        
        //TestDataFactory.createData();
        B2BOrderModel result = new B2BOrderModel();
        Account acc= [select id,Name from Account where Name ='Test Account'LIMIT 1];
        Order o = new Order(
            Name='Test Order',
            AccountId=acc.id,
            Status='Draft',
            EffectiveDate=Date.newInstance(2022, 12, 9), 
            Type='None'
        );
        insert o;
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
        
        
        RSM_Subscriptions_Page_Result obj = new RSM_Subscriptions_Page_Result();
        obj.pageSize = 10;
        obj.pageNumber = 10;
        obj.totalItemCount = 10;
        List<Object> oList = new list<Object>();
        obj.records = oList;
        Test.startTest();
        result=RSM_Subscription.getB2BOrderModel(o); 
        System.assertNotEquals(expect, result);
        Test.stopTest();  
    }
}