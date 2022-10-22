@isTest
global class B2B_BuyNowCalloutMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{requestBody}');   
        response.setStatusCode(200);
        return response; 
    }
}