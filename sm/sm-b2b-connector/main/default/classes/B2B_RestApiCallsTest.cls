@isTest
public class B2B_RestApiCallsTest {
    static testMethod void testPostCallout() {
        Map<String,String> request = new Map<String,String>();
        request.put('authorization','authorizationToken');
        request.put('endPoint','endPoint');
        request.put('method','method');
        request.put('contentType','contentType');
        request.put('requestBody','requestBody');
        String expVal = '{requestBody}';
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new B2B_RestApiCallsMock());
        String returnval = B2B_RestApiCalls.httpCallOut(request);
        System.assertEquals(expVal, returnval);
        test.stopTest();
         
    }
}