@isTest
global class RSM_CancelAssetTestMock implements HttpCalloutMock {

 
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json; charset=UTF-8');
         request.setMethod('POST'); 
        String baseUrl = String.valueOf(Url.getOrgDomainUrl().toExternalForm());
       request.setEndpoint('baseUrl'+'cancelAssets');
     

        response.setBody('success');  
        response.setStatusCode(200);
        
        return response; 
       
    }
}