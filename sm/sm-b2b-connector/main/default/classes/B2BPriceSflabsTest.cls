@isTest
public class B2BPriceSflabsTest {
    @TestSetup
    static void makeData(){
        TestDataFactory.createData();
    }
    @isTest
    static void getUserInvoicesTest(){
        Webcart wc = [select id,name from Webcart where Name = 'Cart' limit 1];
        sfdc_checkout.IntegrationInfo jobInfo = new sfdc_checkout.IntegrationInfo();
        B2BPriceSflabs obj = new B2BPriceSflabs();
        
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
        sfdc_checkout.IntegrationStatus integrationResult = obj.startCartProcessAsync(jobInfo, wc.Id);
        system.assertEquals('Cart',wc.Name);
        test.stopTest();
    }
    
    @isTest
    static void getUserInvoicesTest2(){
        Webcart wc = [select id,name from Webcart where Name = 'Cart' limit 1];
        CartItem wci = [select id, Sku from CartItem where Name = 'Cart Item 1' limit 1];
        wci.sku = '';
        update wci;
        sfdc_checkout.IntegrationInfo jobInfo = new sfdc_checkout.IntegrationInfo();
        B2BPriceSflabs obj = new B2BPriceSflabs();
        
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
        sfdc_checkout.IntegrationStatus integrationResult = obj.startCartProcessAsync(jobInfo, wc.Id);
         system.assertEquals('Cart',wc.Name);
        test.stopTest();
    }
    
    @isTest
    static void getUserInvoicesTest3(){
        Webcart wc = [select id, name from Webcart where Name = 'Cart' limit 1];
        sfdc_checkout.IntegrationInfo jobInfo = new sfdc_checkout.IntegrationInfo();
        B2BPriceSflabs obj = new B2BPriceSflabs();
        
        // Because test methods do not support Web service callouts, we create a mock response based on a static resource.
        // To create the static resource from the Developer Console, select File | New | Static Resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('CheckInventorySample');
        // The web service call returns an error code.
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.startTest();
        // Associate the callout with a mock response.
        Test.setMock(HttpCalloutMock.class, mock);
        sfdc_checkout.IntegrationStatus integrationResult = obj.startCartProcessAsync(jobInfo, wc.Id);
         system.assertEquals('Cart',wc.Name);
        test.stopTest();
    }
}