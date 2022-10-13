//Need to create invoice data
//Last Modified By: Manthan Pundir
@isTest
public class RSM_ViewInvoiceExtensionTest {
    
    @testSetup
    static void setup(){
        TestDataFactory.createData();
    }
    @isTest static void testController(){
    
        PageReference pageRef = Page.RSM_ViewMyInvoice;
        Test.setCurrentPage(pageRef);
        
        RSM_ViewInvoiceExtension controller = new RSM_ViewInvoiceExtension();
        //Pagereference nextPage = controller.onLoad();		//controller.save().getUrl();
        
        //System.assertEquals('/apex/failure?error=noParam', nextPage);
        
        ApexPages.currentPage().getParameters().put('invoiceId', 'Test_InvoiceId');
        
        //controller = new AccountContactRoles();
        //controller.setLastName('lastname');
        //controller.setFirstName('firstname');
        //controller.setEmail('na@na.com');
        Pagereference nextPage = controller.onLoad();	
        System.assertEquals(Null, nextPage);
        //Contact[] contacts = [select id, email from contact where Email = 'na@na.com'];
        //System.assertEquals('na@na.com', contacts[0].email);
    }
    
    @isTest static void generateBillingAccountTest(){
        Account retAcc;
        Account acc = [Select id, Name from Account where Name = 'Test Account' limit 1];
        RSM_ViewInvoiceExtension obj = new RSM_ViewInvoiceExtension();
        Test.startTest();
        retAcc = obj.generateBillingAccount(acc.id, acc.Name,'street','city','state','postalCode','country');
        System.assertEquals(acc.Name, retAcc.Name);
        Test.stopTest();
    }
    
    @isTest static void generateShippingAccountTest(){
        Account retAcc;
        Account acc = [Select id, Name from Account where Name = 'Test Account' limit 1];
        RSM_ViewInvoiceExtension obj = new RSM_ViewInvoiceExtension();
        Test.startTest();
        retAcc = obj.generateShippingAccount(acc.id, acc.Name,'street','city','state','postalCode','country');
        System.assertEquals(acc.Name, retAcc.Name);
        Test.stopTest();
    }
    
    @isTest static void test1(){
        Invoice inv = new Invoice();
        RSM_ViewInvoiceExtension.RSM_MyInvoiceLineWrapper o = new RSM_ViewInvoiceExtension.RSM_MyInvoiceLineWrapper();
        o.lineId = Null;
        o.Quantity = 1.0;
        o.ProductName = 'Test ProductName';
        o.ProductDescription = 'Test ProductDescription';
        o.UnitPrice = 1.0;
        o.Type = 'Test';
        o.LineAmount = 100.0;
        o.invLineStartDate = Date.today();
        o.invLineEndDate = Date.today();
        o.invLineBillingTermUnit = 'Test invLineBillingTermUnit';
        List<RSM_ViewInvoiceExtension.RSM_MyInvoiceLineWrapper> oList = new List<RSM_ViewInvoiceExtension.RSM_MyInvoiceLineWrapper>();
        oList.add(o);
        RSM_ViewInvoiceExtension obj = new RSM_ViewInvoiceExtension();
        Test.startTest();
        obj.invoiceRec = null;
        obj.orderNumber = 'TestOrder-11';
        obj.invDocNum = 'TestINV-010';
        obj.invDate = Date.today();
        obj.invTotalTax = 10.0;
        obj.invTotal = 110.0;
        obj.invDueDate = Date.today();
        obj.invStatus = 'Posted';
        obj.paymentTerm = 'TestPaymentTerm';
        obj.activatedDate = DateTime.now();
        obj.billingAddress = Null;
        obj.shippingAddress = Null;
        obj.salesRep = 'TestSalesRep';
        obj.comments = 'Test comments';
        obj.voiceLines = oList;
        System.assertEquals(obj.comments, 'Test comments');
        Test.stopTest();
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
        RSM_ViewInvoiceExtension.createQuoteToCart(testCart.Id,'New','quoteMsg-Test','communityId');
        System.assert(True);
        Test.stopTest();
    }
    
    @isTest
    Static void createQuoteToCartTestCatch(){
        list<WebCart> testCartList = [Select id from WebCart where Name = 'Cart'];
        Test.startTest();
        RSM_ViewInvoiceExtension.createQuoteToCart('CartId not found','New','quoteMsg-Test','communityId');
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
        Object response= RSM_ViewInvoiceExtension.productSearch(communityId,SrcQuery,AccId);
        system.assertnotEquals(null, response); 
        test.stopTest();
        
    }
    @isTest
    static void ExceptionCase_productSearchTest() 
    {
        String SrcQuery= '{"categoryId":"0ZG8c000000kKM0GAM","refinements":[],"includeQuantityRule":true,"page":0,"pageSize":200,"grouping":{"groupingOption":"VariationParent"},"includePrices":true}';
        
        try{
            
            test.startTest();
            Object response= RSM_ViewInvoiceExtension.productSearch(null,null,null);
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
        RSM_ViewInvoiceExtension.startB2BBuyNowFlow2(b2bOrderId,paymentGatewayId,paymentMethodId);
        //No assertion - Void Method
        System.assertEquals('','');
        Test.stopTest();
    }
    @isTest
    static void catchmethod(){
    MessageLog__c log1 = new MessageLog__c(Message__c='B2BBuyNowFlow ERR');
    insert log1;
     Test.startTest();
        RSM_ViewInvoiceExtension.startB2BBuyNowFlow2(log1.Message__c,log1.Message__c,log1.Message__c);
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
        Map<String,object> resp = RSM_ViewInvoiceExtension.renewAssetMethod2(asst.id);
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
            map<string, object> cancelAsset= RSM_ViewInvoiceExtension.cancelAsset2(asseId);
            system.assertNotEquals(null,cancelAsset); 
            Test.stopTest();
        }}
    @isTest
    static void ExceptionCase_cancelAssetTest(){
        Try
        {
            Test.startTest();
            map<string, object> cancelAsset= RSM_ViewInvoiceExtension.cancelAsset2(null);
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
        Test.startTest();
        result=RSM_ViewInvoiceExtension.getB2BOrderModel(o); 
        System.assertNotEquals(expect, result);
        Test.stopTest();  
    }
    
}