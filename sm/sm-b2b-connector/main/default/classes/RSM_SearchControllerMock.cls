@isTest
global class RSM_SearchControllerMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type','application/json');
        response.setBody('{"TestPrinter1":1.00, "SKU_Test2":2.00}');  
        response.setStatusCode(200);
        return response; 
    }
}