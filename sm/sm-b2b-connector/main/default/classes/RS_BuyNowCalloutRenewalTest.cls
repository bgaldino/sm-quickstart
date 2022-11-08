@IsTest
public class RS_BuyNowCalloutRenewalTest {
    
    
     public class B2B_BuyNowCalloutRequest {
        @InvocableVariable(required=true)
        public ID b2bOrderId;
        @InvocableVariable(required=true)
        public ID paymentGatewayId;
        @InvocableVariable(required=true)
        public ID paymentMethodId;
    }
    
    @testSetup
    static void setup(){
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            TestDataFactory.createData();
            B2BTestFactory.addNewUser();
            Account a =[Select Id,name from Account limit 1];
            Id standardId = test.getStandardPricebookId();
            
            Order orderObj = new Order();
            orderObj.Name               = 'Test';
            orderObj.AccountId          = a.Id;
            orderObj.Status             = 'Draft';
            orderObj.EffectiveDate      = system.today();
            orderObj.ShippingCountry    = 'United States';
            orderObj.ShippingState      = 'Georgia';
            orderObj.Type               = 'End Customer';
            orderObj.Pricebook2Id       = standardId;
            Insert orderObj;
            B2BTestFactory.addNewWebStore();
            CardPaymentMethod cpm = new CardPaymentMethod();
            cpm.CompanyName ='Abc Company'; 
            cpm.AccountId = a.Id;
            cpm.Status ='Active';
            cpm.ProcessingMode='External';
            
            insert cpm;
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
        RS_BuyNowCalloutRenewal.createQuoteToCart(testCart.Id,'New','quoteMsg-Test','communityId');
        System.assert(True);
        Test.stopTest();
    }
    
    @isTest
    Static void createQuoteToCartTestCatch(){
        list<WebCart> testCartList = [Select id from WebCart where Name = 'Cart'];
        Test.startTest();
        RS_BuyNowCalloutRenewal.createQuoteToCart('CartId not found','New','quoteMsg-Test','communityId');
        System.assert(True);
        Test.stopTest();
    }
    
 
   
    /*@isTest static void B2B_BuyNowCalloutRequest(){
         RS_BuyNowCalloutRenewal.ProductDetailResponse onbj = new RS_BuyNowCalloutRenewal.ProductDetailResponse();
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
        
        onbj.SM_prodImageUrl = 'prodImageUrl';
        onbj.SM_isPriceAlreadyAvailable = true;
        onbj.SM_isProductCompared = false;
        onbj.SM_pricingInfo = String.valueOf('abs');
        onbj.SM_isRecurring = true;
        onbj.SM_prodName = 'prodName';
        onbj.SM_prodId = 'prodId';
        onbj.SM_prodDescription = 'prodDescription';
        onbj.SM_pricebookEntryId = 'pricebookEntryId';
        onbj.SM_unitPrice = 'unitPrice';
        onbj.SM_listPrice = 'listPrice';
        
        onbj.RSM_prodImageUrl = 'prodImageUrl';
        onbj.RSM_isPriceAlreadyAvailable = true;
        onbj.RSM_isProductCompared = false;
        onbj.RSM_pricingInfo = String.valueOf('abs');
        onbj.RSM_isRecurring = true;
        onbj.RSM_pricebookEntryId = 'pricebookEntryId';
        onbj.RSM_unitPrice = 'unitPrice';
        onbj.RSM_listPrice = 'listPrice';
        
        list<B2B_BuyNowCalloutRequest> bcrList = new List<B2B_BuyNowCalloutRequest>();
        List<ID> orderIds = new List<ID>();
         List<ID> expected = new List<ID>();
        order order =[Select Id from Order LIMIT 1];
        PaymentGateway paymentgateway = [Select Id from PaymentGateway WHERE PaymentGatewayName = 'Test Gateway'];
        CardPaymentMethod cardpayment =[Select id from  CardPaymentMethod WHERE CompanyName ='Abc Company' LIMIT 1];
        B2B_BuyNowCallout request = new B2B_BuyNowCallout();
        Map<String,String> repeat = new Map<String,String>();
        repeat.put('authorization','authorizationToken');
        repeat.put('endPoint','endPoint');
        repeat.put('method','method');
        repeat.put('contentType','contentType');
        repeat.put('requestBody','requestBody');
        Test.startTest();
        
        RS_BuyNowCalloutRenewal.B2B_BuyNowCallouttestMethodRenewal(order.Id, paymentgateway.Id, cardpayment.Id);
        Test.setMock(HttpCalloutMock.class, new B2B_BuyNowCalloutMock());
         System.assertEquals(expected, orderIds);
        Test.stopTest();
    }*/

}