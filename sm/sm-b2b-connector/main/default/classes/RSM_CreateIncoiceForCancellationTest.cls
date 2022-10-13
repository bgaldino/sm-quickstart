@isTest
public class RSM_CreateIncoiceForCancellationTest {
    
    @testSetup
    static void testSetup(){
        TestDataFactory.createData();
    }
    
    @isTest 
    Static void generateInvoiceTest(){
        Account acc = [Select ID,Name from Account where Name = 'Test Account'];
        List<string> expectedOrderIds = new List<string>();
        List<RSM_createIncoiceForCancellation.rsm_billingSechData> requestData = new List<RSM_createIncoiceForCancellation.rsm_billingSechData>();
        RSM_createIncoiceForCancellation.rsm_billingSechData obj = new RSM_createIncoiceForCancellation.rsm_billingSechData();
        obj.cancelBillingId = acc.Id;	//ID.valueOf('cancelBillingId');
        obj.nextBillingDates = Date.today();
        obj.originalBillingId = acc.Id;	//ID.valueOf('originalBillingId');
        requestData.add(obj);
        
        // Because test methods do not support Web service callouts, we create a mock response based on a static resource.
        // To create the static resource from the Developer Console, select File | New | Static Resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('RSM_createIncoiceForCancellationTest1');
        // The web service call returns an error code.
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Test.startTest();
        // Associate the callout with a mock response.
        test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);

        List<string> returnOrderIds = RSM_createIncoiceForCancellation.generateInvoice(requestData);
        System.assertEquals(expectedOrderIds, returnOrderIds);
        test.stopTest();
    }
}