@isTest
private class B2BInventorySflabsTest {
    @TestSetup static void main(){
        TestDataFactory.createData();
        
    }
   @isTest
    static void b2binvent(){
     StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('B2BInventorySflab');
        // The web service call returns an error code.
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Test.startTest();
        // Associate the callout with a mock response.
        Test.setMock(HttpCalloutMock.class, mock);

        // Test: execute the integration for the test cart ID and integration info.
       // B2BTaxSflabs apexSample = new B2BTaxSflabs();
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        integInfo.jobId = null;
        sfdc_checkout.IntegrationStatus intstatus = new sfdc_checkout.IntegrationStatus();
         sfdc_checkout.IntegrationStatus integStatus = new sfdc_checkout.IntegrationStatus();
        integStatus.status = sfdc_checkout.IntegrationStatus.Status.FAILED;
        String errorMessage ='Error';
     WebCart cart =[Select id,Name from WebCart where Name='Cart' limit 1];
     CartItem citem =[Select id,Sku, Name from CartItem where Name='Cart Item 1' and CartId=:cart.id limit 1];
     //citem.sku='';
    // update citem;
   
     Test.startTest();
     B2BInventorySflabs b2 = new B2BInventorySflabs();
    intstatus= b2.startCartProcessAsync(integInfo, cart.id);
    System.assertEquals(integStatus.status,intstatus.status);
     Test.stopTest();
    }
    @isTest
    static void second(){
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('B2BInventorySflab');
        // The web service call returns an error code.
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Test.startTest();
        // Associate the callout with a mock response.
        Test.setMock(HttpCalloutMock.class, mock);

        // Test: execute the integration for the test cart ID and integration info.
       // B2BTaxSflabs apexSample = new B2BTaxSflabs();
        sfdc_checkout.IntegrationInfo integInf = new sfdc_checkout.IntegrationInfo();
        integInf.jobId = null;
        sfdc_checkout.IntegrationStatus intstatus = new sfdc_checkout.IntegrationStatus();
        sfdc_checkout.IntegrationStatus integStatus = new sfdc_checkout.IntegrationStatus();
        integStatus.status = sfdc_checkout.IntegrationStatus.Status.FAILED;
        String errorMessage ='Error';
     WebCart cart2 =[Select id,Name from WebCart where Name='Cart' limit 1];
     CartItem citems =[Select id,Sku, Name from CartItem where Name='Cart Item 1' and CartId=:cart2.id limit 1];
     citems.Sku='';
     delete citems;
     Test.startTest();
     B2BInventorySflabs bis = new B2BInventorySflabs();
     intstatus= bis.startCartProcessAsync(integInf,cart2.id);
     System.assertEquals(integStatus.status, intstatus.status);
     Test.stopTest();
    }
    @isTest
    static void third(){
     StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('B2BInventorySflab');
        // The web service call returns an error code.
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Test.startTest();
        // Associate the callout with a mock response.
        Test.setMock(HttpCalloutMock.class, mock);

        // Test: execute the integration for the test cart ID and integration info.
        B2BTaxSflabs apexSample = new B2BTaxSflabs();
     sfdc_checkout.IntegrationStatus integStatus = new sfdc_checkout.IntegrationStatus();
     integStatus.status = sfdc_checkout.IntegrationStatus.Status.FAILED;
     sfdc_checkout.IntegrationInfo integIn = new sfdc_checkout.IntegrationInfo();
     sfdc_checkout.IntegrationStatus intstatus = new sfdc_checkout.IntegrationStatus();
     integIn.jobId = null;
     WebCart cart3 =[Select id,Name from WebCart where Name='Cart' limit 1];
     CartItem citems2 =[Select id,Sku,Quantity,Name from CartItem where Name='Cart Item 1' and CartId=:cart3.id limit 1];
      citems2.Sku='new';
      citems2.Quantity=2;
     update citems2;
     String sk=citems2.Sku;
     Set<String> skus = new Set<String>();
     skus.add(sk);
     Test.startTest();
     B2BInventorySflabs blis = new B2BInventorySflabs();
     intstatus= blis.startCartProcessAsync(integIn,cart3.id);
     System.assertEquals(integStatus.status,intstatus.status);
     Test.stopTest();
    }
     @isTest
    static void fourth(){
    
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('B2BInventorySflab');
        // The web service call returns an error code.
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Test.startTest();
        // Associate the callout with a mock response.
        Test.setMock(HttpCalloutMock.class, mock);

        // Test: execute the integration for the test cart ID and integration info.
       // B2BTaxSflabs apexSample = new B2BTaxSflabs();
        sfdc_checkout.IntegrationInfo integInf = new sfdc_checkout.IntegrationInfo();
        integInf.jobId = null;
        sfdc_checkout.IntegrationStatus intstatus = new sfdc_checkout.IntegrationStatus();
        sfdc_checkout.IntegrationStatus integStatus = new sfdc_checkout.IntegrationStatus();
        integStatus.status = sfdc_checkout.IntegrationStatus.Status.FAILED;
        String errorMessage ='Error';
     WebCart cart2 =[Select id,Name from WebCart where Name='Cart' limit 1];
     CartItem citems =[Select id,Sku, Name from CartItem where Name='Cart Item 1' and CartId=:cart2.id limit 1];
     citems.Sku='';
     update citems;
     Test.startTest();
     B2BInventorySflabs bis = new B2BInventorySflabs();
     intstatus=bis.startCartProcessAsync(integInf,cart2.id);
     System.assertEquals(integStatus.status,intstatus.status);
     Test.stopTest();
    }
}