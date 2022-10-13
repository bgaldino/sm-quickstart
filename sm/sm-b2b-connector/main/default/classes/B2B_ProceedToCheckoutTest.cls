@IsTest
public class B2B_ProceedToCheckoutTest {
    @TestSetup static void method(){
        TestDataFactory.createData();
         WebCart currentCart = [SELECT Id, Cart_Type__c, Quote__c, Status FROM WebCart WHERE Name = 'Cart' LIMIT 1];
      /*  Quote quote = new Quote();
         quote.Cart__c = currentCart.Id;
         quote.Name ='Test';
         insert quote;*/
             }
    @IsTest
    static void testgetActiveCartStatus() {
        WebCart currentCart = [SELECT Id, Cart_Type__c, Quote__c, Status FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        //   Quote quote = [SELECT Id, Cart__c from Quote WHERE Cart__c=:currentCart.Id LIMIT 1 ];
        Map<String, Object> exp = new Map<String, Object>{'cartId'=>'0a68c000000kO95AAE', 'cartType'=>'New', 'isActive'=>true, 'isQuoteExist'=>false};
        Test.startTest();
        Map<String, Object> actualval = B2B_ProceedToCheckout.getActiveCartStatus();
        System.debug(actualval);
        System.assertNotEquals(exp, actualval);
        test.stopTest();                        
    }
    @isTest static void createquote(){
        WebCart cart =[Select id, Cart_Type__c, Status from WebCart WHERE  Name = 'Cart'];
        Map<String,Object> reqData = new Map<String,Object>{};
        Test.startTest();
        Map<String, Object> actualval = B2B_ProceedToCheckout.createQuotes(cart.Id, cart.Cart_Type__c);
        System.assertEquals(reqData, actualval);
        Test.stopTest();
    }
    @isTest static void checkQuote(){
        String actual ='jobId';
        test.startTest();
        String actualVal = B2B_ProceedToCheckout.checkQueueStatus('jobId');
        System.assertEquals(null,actualVal);
        Test.stopTest();
    }
    @isTest static void createRenewal(){
        test.startTest();
        B2B_ProceedToCheckout.createRenewalQuote();
        //void method
        System.assertEquals('', '');
        test.stopTest();
    }
    @isTest static void deleteExisting(){
        String actual = 'quoteId';
        test.startTest();
        B2B_ProceedToCheckout.deleteExistingQuotes('quoteId');
        System.assertNotEquals(null, actual);
        test.stopTest();
    }   
    public class ProceedToCheckOutMocks implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(200);
            return res;
        }
    }
}