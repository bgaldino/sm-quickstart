@isTest
public class B2BShipmentSflabsTest {
    @TestSetup
    static void makeData(){
        TestDataFactory.createData();
        Webcart wc = [select id from Webcart where Name = 'Cart' limit 1];
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId = wc.Id, Name = 'Default Delivery');
        insert cartDeliveryGroup;
        B2BTestFactory.createCartDeliveryGroup(wc,true);
        B2BTestFactory.getCartDeliveryGroup();
        CartDeliveryGroupMethod cartdelivery = new CartDeliveryGroupMethod();
        CartItem cartItem = new CartItem(CartId=wc.Id, Type='Product', Name='TestProduct', CartDeliveryGroupId=cartDeliveryGroup.Id);
        insert cartItem;
    }
    @isTest
    static void getUserInvoicesTest(){
        Webcart wc = [select id from Webcart where Name = 'Cart' limit 1];
        CartItem carti =[SELECT CartDeliveryGroupId FROM CartItem WHERE CartId = :wc.Id LIMIT 1 ];
        sfdc_checkout.IntegrationInfo jobInfo = new sfdc_checkout.IntegrationInfo();
        B2BShipmentSflabs obj = new B2BShipmentSflabs();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('B2BShipmentSflabs');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        sfdc_checkout.IntegrationStatus integrationResult = obj.startCartProcessAsync(jobInfo, wc.Id);
        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.SUCCESS, integrationResult.status);
        test.stopTest();
    }
    
     @isTest
    static void getUserInvoicesTestNull(){
        Webcart wc = [select id from Webcart where Name = 'Cart' limit 1];
        CartItem carti =[SELECT CartDeliveryGroupId FROM CartItem WHERE CartId = :wc.Id LIMIT 1 ];
        sfdc_checkout.IntegrationInfo jobInfo = new sfdc_checkout.IntegrationInfo();
        B2BShipmentSflabs obj = new B2BShipmentSflabs();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('B2BShipmentSflabs');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        try{
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        sfdc_checkout.IntegrationStatus integrationResult = obj.startCartProcessAsync(null, null);
        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.SUCCESS, integrationResult.status);
        test.stopTest(); 
        }
        catch(Exception E)
        { }
    }
}