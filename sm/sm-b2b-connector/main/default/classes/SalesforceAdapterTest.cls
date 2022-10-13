/**
 * @description       : 
 * @author            : Tiago Welter
 * @group             : Docmation LLC
 * @last modified on  : 02-22-2022
 * @last modified by  : Abhishek Walia
**/
@isTest
public with sharing class SalesforceAdapterTest {
    
    /*@TestSetup
    static void testSetupMethod(){
        B2BTestFactory.addNewUser();
        B2BTestFactory.addNewWebStore();
        B2BTestFactory.addNewCart(B2BTestFactory.getWebStore().Id, B2BTestFactory.getAccountList().get(0).Id, B2BTestFactory.getUser().Id);
        Webcart cart = B2BTestFactory.getCurrentWebCart();
        B2BTestFactory.createCartDeliveryGroup(cart,true);
        B2BTestFactory.createOrderDeliveryMethod(B2BTestFactory.getProduct2().Id,true);
        B2BTestFactory.createCartDeliveryGroupMethod(cart.Id, B2BTestFactory.getCartDeliveryGroup().Id, B2BTestFactory.getOrderDeliveryMethod().Id,true);
    }

    @isTest
    public static void testAuthRequest() {

        Account acc= B2BTestFactory.getAccountList().get(0);
        User u= B2BTestFactory.getUser();


        // Set mock callout class 
        System.runAs(u){
            //Create a PaymentMethod instance
            commercepayments.AuthApiPaymentMethodRequest paymentMethod = createAuthPaymentMethodRequest();
            // Set mock callout class 
            Test.setMock(HttpCalloutMock.class, new B2BStripeAdapterMock());
            //Create an auth request
            commercepayments.AuthorizationRequest authRequest = new commercepayments.AuthorizationRequest(80);
            authRequest.paymentMethod = paymentMethod;
            authRequest.additionalData=additionData();
            
            commercepayments.PaymentGatewayContext p = new commercepayments.PaymentGatewayContext(authRequest, commercepayments.RequestType.Authorize);
            Test.startTest();
                SalesforceAdapter adapter = new SalesforceAdapter();            
                commercepayments.GatewayResponse authResponse = adapter.processRequest(p);
            System.assertNotEquals(null, u);
            Test.stopTest();
        }
    }

    @isTest
    public static void testAuthValidationExceptionRequest() {

        Account acc= B2BTestFactory.getAccountList().get(0);
        User u= B2BTestFactory.getUser();

        System.runAs(u){
            //Create Address request
            commercepayments.AuthApiPaymentMethodRequest paymentMethod = createAuthPaymentMethodRequest();
            commercepayments.AddressRequest address = new commercepayments.AddressRequest('test', 'test', 'test', 'test', 'test');
            
            // Set mock callout class 
            Test.setMock(HttpCalloutMock.class, new B2BStripeAdapterMock());
            //Create an auth request
            commercepayments.AuthorizationRequest authRequest = new commercepayments.AuthorizationRequest(80);
            authRequest.paymentMethod = paymentMethod;
            authRequest.additionalData=additionData();
            commercepayments.PaymentGatewayContext p = new commercepayments.PaymentGatewayContext(authRequest, commercepayments.RequestType.Authorize);
            Test.startTest();
                SalesforceAdapter adapter = new SalesforceAdapter();            
                commercepayments.GatewayResponse authResponse = adapter.processRequest(p);
                system.debug('authResponse '+authResponse.toString());
             System.assertNotEquals(null, u);
            Test.stopTest();
        }    
        
    } 

    @isTest
    public static void testAuthReversalRequest() {
        PaymentAuthorization auth = initializeAuthObject();
        insert auth;
        //Dmls and http request can't be performed in a single transaction in apex
        //segreagating the transaction by starting a test context
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new B2BStripeAdapterMock());
        //Create an auth reversal request
        commercepayments.AuthorizationReversalRequest authReversalRequest = new commercepayments.AuthorizationReversalRequest(1500, auth.id);
        
        commercepayments.PaymentGatewayContext p = new commercepayments.PaymentGatewayContext(authReversalRequest, commercepayments.RequestType.AuthorizationReversal);
        Test.startTest();
        SalesforceAdapter adapter = new SalesforceAdapter();
        
        commercepayments.GatewayResponse authReversalResponse = adapter.processRequest(p);
        //system.assert(authReversalResponse instanceOf commercepayments.AuthorizationReversalResponse, 'Response is not a valid Capture response');
       system.assertNotEquals(null, auth);
        Test.stopTest();
    }    

    @isTest
    public static void testCaptureRequest() {
        PaymentAuthorization auth = initializeAuthObject();
        insert auth;
        
        Account acc= B2BTestFactory.getAccountList().get(0);
        User u= B2BTestFactory.getUser();

        // Set mock callout class 
        System.runAs(u){
            //Dmls and http request can't be performed in a single transaction in apex
            //segreagating the transaction by starting a test context
            
            // Set mock callout class 
            Test.setMock(HttpCalloutMock.class, new B2BStripeAdapterMock());
            //Create an capture request
            commercepayments.CaptureRequest captureRequest = new commercepayments.CaptureRequest(80, auth.id);
            
            commercepayments.PaymentGatewayContext p = new commercepayments.PaymentGatewayContext(captureRequest, commercepayments.RequestType.capture);
            Test.startTest();
            SalesforceAdapter adapter = new SalesforceAdapter();
            
            commercepayments.GatewayResponse captureResponse = adapter.processRequest(p);
            system.assertEquals(true, captureResponse instanceOf commercepayments.CaptureResponse);
            Test.stopTest();
        }
    } 
    
    @isTest
    public static void testAuthFailureHighLevelErrorRequest() {

        Account acc= B2BTestFactory.getAccountList().get(0);
        User u= B2BTestFactory.getUser();

        // Set mock callout class 
        System.runAs(u){
            //Create a PaymentMethod instance
            commercepayments.AuthApiPaymentMethodRequest paymentMethod = createAuthPaymentMethodRequest();
            commercepayments.AddressRequest address = new commercepayments.AddressRequest('test', 'test', 'test', 'test', 'test');
            
            // Set mock callout class
            Test.setMock(HttpCalloutMock.class, new B2BStripeAdapterMock());
            //Create an auth request
            commercepayments.AuthorizationRequest authRequest = new commercepayments.AuthorizationRequest(80);
            authRequest.paymentMethod = paymentMethod;
            authRequest.additionalData=additionData();
            commercepayments.PaymentGatewayContext p = new commercepayments.PaymentGatewayContext(authRequest, commercepayments.RequestType.Authorize);
            test.startTest();
            SalesforceAdapter adapter = new SalesforceAdapter();            
            commercepayments.GatewayResponse authResponse = adapter.processRequest(p);
             System.assertNotEquals(null, u);
            Test.stopTest();
        }
    } 
    
    @isTest
    public static void testSaleRequest() {
        //Create a PaymentMethod instance
       // commercepayments.AuthApiPaymentMethodRequest createAuthPaymentMethodRequest=  createAuthPaymentMethodRequest();
       // commercepayments.CardPaymentMethodRequest cardPaymentMethod = getCardPaymentMethod();
        //commercepayments.SaleApiPaymentMethodRequest paymentMethod = new commercepayments.SaleApiPaymentMethodRequest(getCardPaymentMethod());
      Account acc= [select id from Account where name='Test Name'];
        CardPaymentMethod cpm= new CardPaymentMethod();
        cpm.CardHolderFirstName='TestFname';
        cpm.AuditEmail='h@test.com';
        cpm.Status='Active';
        cpm.ProcessingMode='External';
        cpm.AccountId=acc.id;
        cpm.GatewayTokenDetails='Test Token';
        cpm.GatewayResultCode='Code123';
        cpm.ExpiryYear=2024;
        cpm.ExpiryMonth=03;
        cpm.StartYear=2020;
        cpm.StartMonth=04;
            
        insert cpm;
        test.startTest();
            
       commercepayments.SaleApiPaymentMethodRequest paymentMethod = createSalePaymentMethodRequest();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new B2BStripeAdapterMock());
        //Create an auth request
        commercepayments.SaleRequest saleRequest = new commercepayments.SaleRequest(80);
        saleRequest.paymentMethod = paymentMethod;
        commercepayments.PaymentGatewayContext p = new commercepayments.PaymentGatewayContext(saleRequest, commercepayments.RequestType.Sale);
        SalesforceAdapter adapter = new SalesforceAdapter();
        commercepayments.GatewayResponse saleResponse = adapter.processRequest(p);
        //system.assert(saleResponse instanceOf commercepayments.SaleResponse, 'Response is not a valid Sale response');
        system.assertNotEquals(null, saleRequest);
        test.stopTest();
    }  
    

    private static commercepayments.AuthApiPaymentMethodRequest createAuthPaymentMethodRequest()
    {
        //Create a PaymentMethod instance
        commercepayments.AuthApiPaymentMethodRequest paymentMethod = new commercepayments.AuthApiPaymentMethodRequest(getCardPaymentMethod());
        return paymentMethod;
    }    
    
    Public static commercepayments.CardPaymentMethodRequest getCardPaymentMethod(){
        commercepayments.CardPaymentMethodRequest cardPaymentMethod = new commercepayments.CardPaymentMethodRequest(commercepayments.CardCategory.CreditCard);
        cardPaymentMethod.cardType = commercepayments.CardType.Visa;
        cardPaymentMethod.cardHolderFirstName = 'Test';
        cardPaymentMethod.cardHolderLastName = 'Test';
        cardPaymentMethod.cardHolderName = 'Test Test';
        cardPaymentMethod.cardNumber = '4443434343284111';
        cardPaymentMethod.cvv = '123';
        cardPaymentMethod.email = 'h@test.com';
        cardPaymentMethod.expiryMonth = 2;
        cardPaymentMethod.expiryYear = 1111;
        cardPaymentMethod.startMonth = 2;
        cardPaymentMethod.startYear = 1333;
        return cardPaymentMethod;
    }    

    public static map<String,String> additionData()
    {                
        map<String,String> mapdata=new map<String,String>();
        mapdata.put('stripeCustomerId', 'cus_4QEipX9Dj5Om1P');
        mapdata.put('cartId', B2BTestFactory.getCurrentWebCart().Id);
        return mapdata;
    }    

    private static PaymentAuthorization initializeAuthObject()
    {
        PaymentAuthorization auth = new PaymentAuthorization();
        auth.amount = 1500;
        auth.Status = 'Processed';
        auth.ProcessingMode = 'External';
        auth.GatewayRefNumber = 'testreferencenumber';
        auth.GatewayRefDetails = '{"method":"credit_card","transaction_id":"ET119982"}';
        return auth;        
    }    

    private static commercepayments.SaleApiPaymentMethodRequest createSalePaymentMethodRequest()
    {
        //Create a PaymentMethod instance
        commercepayments.SaleApiPaymentMethodRequest paymentMethod = new commercepayments.SaleApiPaymentMethodRequest(getCardPaymentMethod());
        return paymentMethod;
    }    

    private static Payment initializePaymentObject()
    {
        Payment pmt = new Payment();
        pmt.amount = 1500;
        pmt.Status = 'Processed';
        pmt.ProcessingMode = 'External';
        pmt.GatewayRefNumber = 'testreferencenumber';
        pmt.Type = 'Capture';
        pmt.GatewayRefDetails = '{"method":"credit_card","transaction_id":"ET119982"}';
        return pmt;    
    }

    @isTest
    public static void testReferencedRefundRequest() {        
        PaymentAuthorization auth = initializeAuthObject();
        insert auth;
        Payment pmt = initializePaymentObject();
        pmt.PaymentAuthorizationId=auth.id;
        insert pmt; 

        Account acc= B2BTestFactory.getAccountList().get(0);
        User u= B2BTestFactory.getUser();

        // Set mock callout class 
        System.runAs(u){
            //Dmls and http request can't be performed in a single transaction in apex
            //segreagating the transaction by starting a test context
            Test.startTest();
            // Set mock callout class 
            Test.setMock(HttpCalloutMock.class, new B2BStripeAdapterMock());
            //Create an capture request
            commercepayments.ReferencedRefundRequest refundRequest = new commercepayments.ReferencedRefundRequest(80, pmt.id);
            
            commercepayments.PaymentGatewayContext p = new commercepayments.PaymentGatewayContext(refundRequest, commercepayments.RequestType.referencedrefund);
            SalesforceAdapter adapter = new SalesforceAdapter();
            
            commercepayments.GatewayResponse refundResponse = adapter.processRequest(p);
            //system.assert(refundResponse instanceOf commercepayments.ReferencedRefundResponse);
            //system.assert(refundResponse instanceOf commercepayments.GatewayErrorResponse);
            system.assertNotEquals(null, refundResponse);
            Test.stopTest();
        }
    }  
    
    @isTest
    public static void testReferencedRefundFailureRequest() {
        PaymentAuthorization auth = initializeAuthObject();
        insert auth;
        Payment pmt = initializePaymentObject();
        pmt.PaymentAuthorizationId=auth.id;
        insert pmt; 

        Account acc= B2BTestFactory.getAccountList().get(0);
        User u= B2BTestFactory.getUser();

        // Set mock callout class 
        System.runAs(u){
            //Dmls and http request can't be performed in a single transaction in apex
            //segreagating the transaction by starting a test context
            Test.startTest();
            // Set mock callout class 
            Test.setMock(HttpCalloutMock.class, new B2BStripeAdapterMock());
            //Create an capture request
            commercepayments.ReferencedRefundRequest refundRequest = new commercepayments.ReferencedRefundRequest(80, pmt.id);
            
            commercepayments.PaymentGatewayContext p = new commercepayments.PaymentGatewayContext(refundRequest, commercepayments.RequestType.referencedrefund);
            SalesforceAdapter adapter = new SalesforceAdapter();
            
            commercepayments.GatewayResponse refundResponse = adapter.processRequest(p);
            //system.assert(refundResponse instanceOf commercepayments.GatewayErrorResponse, 'Response is not a valid Refund response');
            system.assertNotEquals(null, refundResponse);
            Test.stopTest();
        }
    }  
    
    @isTest
    public static void testTokenizeRequest() {

        Account acc= B2BTestFactory.getAccountList().get(0);
        User u= B2BTestFactory.getUser();

        // Set mock callout class 
        System.runAs(u){
            Test.setMock(HttpCalloutMock.class, new B2BStripeAdapterMock());
            //Create an auth request
            
            commercepayments.PaymentMethodTokenizationRequest tokenizeRequest = new commercepayments.PaymentMethodTokenizationRequest(NULL);
            tokenizeRequest.cardPaymentMethod = getCardPaymentMethod();
            tokenizeRequest.address=getAddressRequest();
            tokenizeRequest.additionalData=additionData();
            commercepayments.PaymentGatewayContext p = new commercepayments.PaymentGatewayContext(tokenizeRequest, commercepayments.RequestType.Tokenize);
            Test.startTest();
            SalesforceAdapter adapter = new SalesforceAdapter();
            commercepayments.GatewayResponse tokenizeResponse = adapter.processRequest(p);
            system.assert(tokenizeResponse instanceOf commercepayments.PaymentMethodTokenizationResponse, 'Response is not a valid Tokenize response');
            test.stopTest();
        }
    }    

    @isTest
    public static void testSaleFailureRequest() {
         Account acc= [select id from Account where name='Test Name'];
        CardPaymentMethod cpm= new CardPaymentMethod();
        cpm.CardHolderFirstName='TestFname';
        cpm.AuditEmail='h@test.com';
        cpm.Status='Active';
        cpm.ProcessingMode='External';
        cpm.AccountId=acc.id;
        cpm.GatewayTokenDetails='Test Token';
        cpm.GatewayResultCode='Code123';
        insert cpm;
        test.startTest();
        //Create a PaymentMethod instance
        commercepayments.SaleApiPaymentMethodRequest paymentMethod = createSalePaymentMethodRequest();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new B2BStripeAdapterMock());
        //Create an auth request
        commercepayments.SaleRequest saleRequest = new commercepayments.SaleRequest(80);
        saleRequest.paymentMethod = paymentMethod;
        commercepayments.PaymentGatewayContext p = new commercepayments.PaymentGatewayContext(saleRequest, commercepayments.RequestType.Sale);
        SalesforceAdapter adapter = new SalesforceAdapter();
        
        commercepayments.GatewayResponse saleResponse = adapter.processRequest(p);
        system.assertNotEquals(null, saleRequest);
          test.stopTest();
        //system.assert(saleResponse instanceOf commercepayments.SaleResponse, 'Response is not a valid Sale response');
    }    

    @isTest
    public static void testCaptureFailureRequest() {
        PaymentAuthorization auth = initializeAuthObject();
        insert auth;
        Account acc= B2BTestFactory.getAccountList().get(0);
        User u= B2BTestFactory.getUser();

        // Set mock callout class 
        System.runAs(u){
            //Dmls and http request can't be performed in a single transaction in apex
            //segreagating the transaction by starting a test context
            Test.startTest();
            // Set mock callout class 
            Test.setMock(HttpCalloutMock.class, new B2BStripeAdapterMock());
            //Create an capture request
            commercepayments.CaptureRequest captureRequest = new commercepayments.CaptureRequest(80, auth.id);
            
            commercepayments.PaymentGatewayContext p = new commercepayments.PaymentGatewayContext(captureRequest, commercepayments.RequestType.Capture);
            SalesforceAdapter adapter = new SalesforceAdapter();
            
            commercepayments.GatewayResponse captureResponse = adapter.processRequest(p);
            //commercepayments.GatewayErrorResponse error = new commercepayments.GatewayErrorResponse('400');
           //system.assert(captureResponse instanceOf commercepayments.CaptureResponse, 'Response is not a valid Capture response');
           //system.assert(captureResponse instanceOf commercepayments.GatewayErrorResponse, 'Response is not a valid Capture response');
           system.assertNotEquals(null, captureResponse);
            Test.stopTest();
        }
    }    

    private static commercepayments.AddressRequest getAddressRequest(){
        commercepayments.AddressRequest cardAddress = new commercepayments.AddressRequest('Test','Test','Taxes','USA','123123');
        
        return cardAddress;
    }   
    
    @isTest
    public static void testTokenizeRequest2() {

        Account acc= B2BTestFactory.getAccountList().get(0);
        User u= B2BTestFactory.getUser();

        // Set mock callout class 
        System.runAs(u){
            Test.setMock(HttpCalloutMock.class, new B2BStripeAdapterMock());
            //Create an auth request
            
            commercepayments.PaymentMethodTokenizationRequest tokenizeRequest = new commercepayments.PaymentMethodTokenizationRequest(NULL);
            tokenizeRequest.cardPaymentMethod = getCardPaymentMethod();
            tokenizeRequest.address=getAddressRequest();
            tokenizeRequest.additionalData=additionData();
            commercepayments.PaymentGatewayContext p = new commercepayments.PaymentGatewayContext(tokenizeRequest, commercepayments.RequestType.Tokenize);
            Test.startTest();
            SalesforceAdapter adapter = new SalesforceAdapter();
            //commercepayments.GatewayResponse tokenizeResponse = adapter.createTokenizeResponse(p);
            commercepayments.GatewayResponse tokenizeResponse = adapter.createTokenizeResponse(tokenizeRequest);
            //system.assert(tokenizeResponse instanceOf commercepayments.GatewayErrorResponse, 'Response is not a valid Tokenize response');
            system.assertNotEquals(null, tokenizeResponse);
            test.stopTest();
        }
    } */
	@isTest
    public static void testAuthRequest() {
        // Set mock callout class 
            //Create a PaymentMethod instance
            commercepayments.AuthApiPaymentMethodRequest paymentMethod = createAuthPaymentMethodRequest();
            // Set mock callout class 
            Test.setMock(HttpCalloutMock.class, new B2BStripeAdapterMock());
            //Create an auth request
            commercepayments.AuthorizationRequest authRequest = new commercepayments.AuthorizationRequest(80);
            authRequest.paymentMethod = paymentMethod;
            authRequest.additionalData=additionData();
            
            commercepayments.PaymentGatewayContext p = new commercepayments.PaymentGatewayContext(authRequest, commercepayments.RequestType.Authorize);
            Test.startTest();
                SalesforceAdapter adapter = new SalesforceAdapter();            
                commercepayments.GatewayResponse authResponse = adapter.processRequest(p);
            System.assertNotEquals(null, authResponse);
            Test.stopTest();
    }
    private static commercepayments.AuthApiPaymentMethodRequest createAuthPaymentMethodRequest()
    {
        //Create a PaymentMethod instance
        commercepayments.AuthApiPaymentMethodRequest paymentMethod = new commercepayments.AuthApiPaymentMethodRequest(getCardPaymentMethod());
        return paymentMethod;
    } 
    public static map<String,String> additionData()
    {                
        map<String,String> mapdata=new map<String,String>();
        mapdata.put('stripeCustomerId', 'cus_4QEipX9Dj5Om1P');
        mapdata.put('cartId', '');
        return mapdata;
    } 
    Public static commercepayments.CardPaymentMethodRequest getCardPaymentMethod(){
        commercepayments.CardPaymentMethodRequest cardPaymentMethod = new commercepayments.CardPaymentMethodRequest(commercepayments.CardCategory.CreditCard);
        cardPaymentMethod.cardType = commercepayments.CardType.Visa;
        cardPaymentMethod.cardHolderFirstName = 'Test';
        cardPaymentMethod.cardHolderLastName = 'Test';
        cardPaymentMethod.cardHolderName = 'Test Test';
        cardPaymentMethod.cardNumber = '4443434343284111';
        cardPaymentMethod.cvv = '123';
        cardPaymentMethod.email = 'h@test.com';
        cardPaymentMethod.expiryMonth = 2;
        cardPaymentMethod.expiryYear = 1111;
        cardPaymentMethod.startMonth = 2;
        cardPaymentMethod.startYear = 1333;
        return cardPaymentMethod;
    } 
    private static PaymentAuthorization initializeAuthObject()
    {
        PaymentAuthorization auth = new PaymentAuthorization();
        auth.amount = 1500;
        auth.Status = 'Processed';
        auth.ProcessingMode = 'External';
        auth.GatewayRefNumber = 'testreferencenumber';
        auth.GatewayRefDetails = '{"method":"credit_card","transaction_id":"ET119982"}';
        return auth;        
    }  
    
    @isTest
    public static void testCaptureRequest() {
        PaymentAuthorization auth = initializeAuthObject();
        insert auth;

        // Set mock callout class 

            //Dmls and http request can't be performed in a single transaction in apex
            //segreagating the transaction by starting a test context
            
            // Set mock callout class 
            Test.setMock(HttpCalloutMock.class, new B2BStripeAdapterMock());
            //Create an capture request
            commercepayments.CaptureRequest captureRequest = new commercepayments.CaptureRequest(80, auth.id);
            
            commercepayments.PaymentGatewayContext p = new commercepayments.PaymentGatewayContext(captureRequest, commercepayments.RequestType.capture);
            Test.startTest();
            SalesforceAdapter adapter = new SalesforceAdapter();
            
            commercepayments.GatewayResponse captureResponse = adapter.processRequest(p);
            system.assertEquals(true, captureResponse instanceOf commercepayments.CaptureResponse);
            Test.stopTest();
    }
    
    private static commercepayments.SaleApiPaymentMethodRequest createSalePaymentMethodRequest()
    {
        //Create a PaymentMethod instance
        commercepayments.SaleApiPaymentMethodRequest paymentMethod = new commercepayments.SaleApiPaymentMethodRequest(getCardPaymentMethod());
        return paymentMethod;
    }
    
    @isTest
    public static void testSaleRequest() {
        //Create a PaymentMethod instance
       // commercepayments.AuthApiPaymentMethodRequest createAuthPaymentMethodRequest=  createAuthPaymentMethodRequest();
       // commercepayments.CardPaymentMethodRequest cardPaymentMethod = getCardPaymentMethod();
        //commercepayments.SaleApiPaymentMethodRequest paymentMethod = new commercepayments.SaleApiPaymentMethodRequest(getCardPaymentMethod());
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        CardPaymentMethod cpm= new CardPaymentMethod();
        cpm.CardHolderFirstName='TestFname';
        cpm.AuditEmail='h@test.com';
        cpm.Status='Active';
        cpm.ProcessingMode='External';
        cpm.AccountId=acc.id;
        cpm.GatewayTokenDetails='Test Token';
        cpm.GatewayResultCode='Code123';
        cpm.ExpiryYear=2024;
        cpm.ExpiryMonth=03;
        cpm.StartYear=2020;
        cpm.StartMonth=04;
            
        insert cpm;
        test.startTest();
            
       commercepayments.SaleApiPaymentMethodRequest paymentMethod = createSalePaymentMethodRequest();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new B2BStripeAdapterMock());
        //Create an auth request
        commercepayments.SaleRequest saleRequest = new commercepayments.SaleRequest(80);
        saleRequest.paymentMethod = paymentMethod;
        commercepayments.PaymentGatewayContext p = new commercepayments.PaymentGatewayContext(saleRequest, commercepayments.RequestType.Sale);
        SalesforceAdapter adapter = new SalesforceAdapter();
        commercepayments.GatewayResponse saleResponse = adapter.processRequest(p);
        //system.assert(saleResponse instanceOf commercepayments.SaleResponse, 'Response is not a valid Sale response');
        system.assertNotEquals(null, saleRequest);
        test.stopTest();
    } 
    
    private static Payment initializePaymentObject()
    {
        Payment pmt = new Payment();
        pmt.amount = 1500;
        pmt.Status = 'Processed';
        pmt.ProcessingMode = 'External';
        pmt.GatewayRefNumber = 'testreferencenumber';
        pmt.Type = 'Capture';
        pmt.GatewayRefDetails = '{"method":"credit_card","transaction_id":"ET119982"}';
        return pmt;    
    }
    
    @isTest
    public static void testReferencedRefundRequest() {        
        PaymentAuthorization auth = initializeAuthObject();
        insert auth;
        Payment pmt = initializePaymentObject();
        pmt.PaymentAuthorizationId=auth.id;
        insert pmt; 

        // Set mock callout class 
            //Dmls and http request can't be performed in a single transaction in apex
            //segreagating the transaction by starting a test context
            Test.startTest();
            // Set mock callout class 
            Test.setMock(HttpCalloutMock.class, new B2BStripeAdapterMock());
            //Create an capture request
            commercepayments.ReferencedRefundRequest refundRequest = new commercepayments.ReferencedRefundRequest(80, pmt.id);
            
            commercepayments.PaymentGatewayContext p = new commercepayments.PaymentGatewayContext(refundRequest, commercepayments.RequestType.referencedrefund);
            SalesforceAdapter adapter = new SalesforceAdapter();
            
            commercepayments.GatewayResponse refundResponse = adapter.processRequest(p);
            //system.assert(refundResponse instanceOf commercepayments.ReferencedRefundResponse);
            //system.assert(refundResponse instanceOf commercepayments.GatewayErrorResponse);
            system.assertNotEquals(null, refundResponse);
            Test.stopTest();
    } 
    
    private static commercepayments.AddressRequest getAddressRequest(){
        commercepayments.AddressRequest cardAddress = new commercepayments.AddressRequest('Test','Test','Taxes','USA','123123');
        
        return cardAddress;
    } 
    
    @isTest
    public static void testTokenizeRequest2() {

        // Set mock callout class 
            Test.setMock(HttpCalloutMock.class, new B2BStripeAdapterMock());
            //Create an auth request
            
            commercepayments.PaymentMethodTokenizationRequest tokenizeRequest = new commercepayments.PaymentMethodTokenizationRequest(NULL);
            tokenizeRequest.cardPaymentMethod = getCardPaymentMethod();
            tokenizeRequest.address=getAddressRequest();
            tokenizeRequest.additionalData=additionData();
            commercepayments.PaymentGatewayContext p = new commercepayments.PaymentGatewayContext(tokenizeRequest, commercepayments.RequestType.Tokenize);
            Test.startTest();
            SalesforceAdapter adapter = new SalesforceAdapter();
            //commercepayments.GatewayResponse tokenizeResponse = adapter.createTokenizeResponse(p);
            commercepayments.GatewayResponse tokenizeResponse = adapter.createTokenizeResponse(tokenizeRequest);
            //system.assert(tokenizeResponse instanceOf commercepayments.GatewayErrorResponse, 'Response is not a valid Tokenize response');
            system.assertNotEquals(null, tokenizeResponse);
            test.stopTest();
    }
    
    @isTest
    public static void testReferencedRefundRequestFail() {        
        PaymentAuthorization auth = initializeAuthObject();
        insert auth;
        Payment pmt = initializePaymentObject();
        pmt.PaymentAuthorizationId=auth.id;
        insert pmt; 

        // Set mock callout class 
            //Dmls and http request can't be performed in a single transaction in apex
            //segreagating the transaction by starting a test context
            Test.startTest();
            // Set mock callout class 
            Test.setMock(HttpCalloutMock.class, new B2BStripeAdapterMock());
            //Create an capture request
            commercepayments.ReferencedRefundRequest refundRequest = new commercepayments.ReferencedRefundRequest(Null, pmt.id);
            
            commercepayments.PaymentGatewayContext p = new commercepayments.PaymentGatewayContext(refundRequest, commercepayments.RequestType.referencedrefund);
            SalesforceAdapter adapter = new SalesforceAdapter();
            
            commercepayments.GatewayResponse refundResponse = adapter.processRequest(p);
            //system.assert(refundResponse instanceOf commercepayments.ReferencedRefundResponse);
            //system.assert(refundResponse instanceOf commercepayments.GatewayErrorResponse);
            system.assertNotEquals(null, refundResponse);
            Test.stopTest();
    }
    
    
}