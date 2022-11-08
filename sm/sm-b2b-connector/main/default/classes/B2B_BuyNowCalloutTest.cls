@IsTest
public class B2B_BuyNowCalloutTest {
    public class B2B_BuyNowCalloutRequest {
        @InvocableVariable(required=true)
        public ID b2bOrderId;
        @InvocableVariable(required=true)
        public ID paymentGatewayId;
        @InvocableVariable(required=true)
        public ID paymentMethodId;
    }
    @TestSetup static void buynow(){
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            B2BTestFactory.addNewUser();
            Account a =[Select Id,name from Account];
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
   
    @isTest static void B2B_BuyNowCalloutRequest(){
        list<B2B_BuyNowCalloutRequest> bcrList = new List<B2B_BuyNowCalloutRequest>();
        List<ID> orderIds = new List<ID>();
         List<ID> expected = new List<ID>();
        order order =[Select Id from Order LIMIT 1];
        //PaymentGateway paymentgateway = [Select Id from PaymentGateway WHERE PaymentGatewayName = 'Test Gateway'];
        CardPaymentMethod cardpayment =[Select id from  CardPaymentMethod WHERE CompanyName ='Abc Company' LIMIT 1];
        B2B_BuyNowCallout request = new B2B_BuyNowCallout();
        Map<String,String> repeat = new Map<String,String>();
        repeat.put('authorization','authorizationToken');
        repeat.put('endPoint','endPoint');
        repeat.put('method','method');
        repeat.put('contentType','contentType');
        repeat.put('requestBody','requestBody');
        Test.startTest();
        
        //B2B_BuyNowCallout.B2B_BuyNowCallouttestMethod(order.Id, paymentgateway.Id, cardpayment.Id);
        B2B_BuyNowCallout.B2B_BuyNowCallouttestMethod(order.Id, null, cardpayment.Id);
        Test.setMock(HttpCalloutMock.class, new B2B_BuyNowCalloutMock());
         System.assertEquals(expected, orderIds);
        Test.stopTest();
    }
   
         
}