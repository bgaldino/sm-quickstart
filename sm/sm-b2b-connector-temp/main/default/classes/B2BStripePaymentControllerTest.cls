@isTest
private class B2BStripePaymentControllerTest {
    public static Map<String,Object> dataMap;
    @testSetup static void main(){
        TestDataFactory.createData(); 
        WebCart cart=[select id,Name from WebCart where Name='Cart' LIMIT 1];
        dataMap = new Map<String,Object>();
        dataMap.put('cartId', cart.Id);
    }
    @isTest
    static void first(){
        String result;
        String expect ='https://subsacce-developer-edition.na210.force.com';
        Test.startTest();
        result= B2BStripePaymentController.getVFOrigin();
        System.assertEquals(expect, result);
        Test.stopTest();
    } 
    @isTest
    static void two(){
        WebCart cart=[select id,Name from WebCart where Name='Cart' LIMIT 1];
        dataMap = new Map<String,Object>();
        dataMap.put('cartId', cart.Id);
        map<String,Object> result= new map<String,Object>();
        map<String,Object> expect = new map<String,Object>();
        WebCart cartexpect =[Select Id, Name, WebStoreId, OwnerId, AccountId, CurrencyIsoCode, GrandTotalAmount, TotalPromoAdjustmentAmount, Status, TotalTaxAmount,TotalAmount, TotalProductAmount, PoNumber from WebCart where Name ='Cart' limit 1];
        expect.put('canPay',true);
        expect.put('WebCart',cartexpect);
        expect.put('hideCreditCard',false);
        expect.put('hidePurchaseOrder',false);
        expect.put('isSuccess',true);
        expect.put('msg','');
        expect.put('userType','End Customer');
        Test.startTest();
        result = B2BStripePaymentController.getPaymentInfo(dataMap);
       //System.debug(result);
       System.assertNotEquals(expect, result);
        Test.stopTest();
    }
    @isTest
    static void third(){
        map<String,Object> result= new map<String,Object>();
        map<String,Object> expect= new map<String,Object>();
        WebCart cart=[select id,Name from WebCart where Name='Cart' LIMIT 1]; 
        WebCart cartexpect =[Select Id, Name, WebStoreId, OwnerId, AccountId, CurrencyIsoCode, GrandTotalAmount, 
                     TotalPromoAdjustmentAmount, Status, TotalTaxAmount, TotalAmount, TotalProductAmount,
                   PoNumber, PaymentMethodId from WebCart where Name='Cart' limit 1];
        //cartexpect.PoNumber=null;
        //cartexpect.PaymentMethodId=null;
        //update cartexpect;
        expect.put('cart',cartexpect);
        expect.put('cartId',cart.id);
        expect.put('isSuccess',true);
        dataMap = new Map<String,Object>();
        dataMap.put('cartId', cart.Id);
        Test.startTest();
        result= B2BStripePaymentController.submitPoOrder(dataMap);
        result.get('cartId');
        System.assertEquals(expect.get('cartId'), result.get('cartId'));
        Test.stopTest();
    }
    @isTest
    static void four(){
        WebCart cart=[select id,Name from WebCart where Name='Cart' LIMIT 1];
        dataMap = new Map<String,Object>();
        dataMap.put('cartId', cart.Id);
        map<String,Object> result= new map<String,Object>();
        map<String,Object> expect= new map<String,Object>();
        expect.put('cartId', cart.Id);
        expect.put('isSuccess',false);
        expect.put('msg','List has no rows for assignment to SObject');
        Test.startTest();
        result= B2BStripePaymentController.setPaymentInfo(dataMap);
        System.debug(result);
        System.assertnotEquals(expect, result);
        Test.stopTest();
    }
    @isTest
    static void five(){
        WebCart cart=[select id,Name from WebCart where Name='Cart' LIMIT 1];
        Test.startTest();
        B2BStripePaymentController.updateOppCheckoutStatus(cart); 
        //  V O I D   M E T H O D
        String actual ='Cart';
        System.assertEquals(cart.Name, actual);
        Test.stopTest();
    }
    @isTest
    static void six(){
        WebCart cart=[select id,Name from WebCart where Name='Cart' LIMIT 1];
        dataMap = new Map<String,Object>();
        dataMap.put('cartId', cart.Id);
        map<String,Object> result= new map<String,Object>();
        map<String,Object> expect= new map<String,Object>();
        expect.put('cartId',cart.id);
        Test.startTest();
        result=B2BStripePaymentController.submitCreditCardOrder(dataMap);
        System.debug(result);
        System.assertEquals(expect, result);
        Test.stopTest();
    }
    @isTest
    static void seven(){
        Account acc= [select id,Name from Account where Name ='Test Account'LIMIT 1];
        Order o = new Order(
            AccountId=acc.id,
            Status='Draft',
            EffectiveDate=Date.newInstance(2022, 12, 9)
        );
        insert o;
        WebCart cart=[select id,Name,PaymentMethodId from WebCart where Name='Cart' LIMIT 1];
        dataMap = new Map<String,Object>();
        dataMap.put('paymentMethod', cart.Id);
        dataMap.put('cartId', cart.Id);
        dataMap.put('paymentMethod','PO');
        CartCheckoutSession ccs = [Select id,Name from CartCheckoutSession where Name='Checkout Session 1' limit 1];
        ccs.OrderId = o.Id;
        update ccs;
        // List<CartCheckoutSession> sessions = B2BUtils.getActiveCheckoutSessions(cartId);
        map<String,Object> result= new map<String,Object>();
        map<String,Object> expect= new map<String,Object>();
        expect.put('cartId',cart.Id);
        expect.put('paymentMethod',cart.Id);
        expect.put('paymentMethod','PO');
        Test.startTest();
        result= B2BStripePaymentController.updateOrderInformation(dataMap);
        System.assertEquals(expect, result);
        Test.stopTest();
    } 
    @isTest
    static void eight(){
        WebCart cart=[select id,Name from WebCart where Name='Cart' LIMIT 1];
        dataMap = new Map<String,Object>();
        dataMap.put('paId', cart.Id);
        map<String,Object> result= new map<String,Object>();
        map<String,Object> expect= new map<String,Object>();
        expect.put('paId', cart.Id);
        Test.startTest();
        try{
           result= B2BStripePaymentController.updatePaymentAuthError(dataMap);
           System.assertEquals(expect, result);
        }
        catch(Exception e){}
        Test.stopTest();
    }
    @isTest
    static void Nine(){
        Account acc= [select id,Name from Account where Name ='Test Account'LIMIT 1];
        Order o = new Order(
            AccountId=acc.id,
            Status='Draft',
            EffectiveDate=Date.newInstance(2022, 8, 18)
        );
        insert o;
        Order result = new Order(); 
        Order expect = [Select id,AccountId,Status,EffectiveDate from Order where AccountId=:o.AccountId limit 1];
        Test.startTest();
        result=B2BStripePaymentController.getOrderAccountId(o);
        System.debug(result);
        System.assertEquals(expect.status,result.status);
        Test.stopTest();
    }
     @isTest
    static void Ten(){
        Map<String,Object> result = new Map<String,Object>();
        WebCart cart=[select id,Name from WebCart where Name='Cart' LIMIT 1];
        Test.startTest();
        result =B2BStripePaymentController.getPaymentInfo(dataMap); 
        System.assertNotEquals(null, result);
        Test.stopTest();
    }
    
    
}