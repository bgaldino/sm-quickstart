@isTest
global class B2B_CartControllerTestMock implements HttpCalloutMock {
 global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('success');  
        response.setStatusCode(200);
        return response; 
    }
}