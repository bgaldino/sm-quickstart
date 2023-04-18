@isTest
global class B2BGetInfoTestMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{'+
            '"inStock": true'+
        '}');
        if(req.getEndpoint() == 'https://inventorymanagerdemo.herokuapp.com/api/inventory/'){
            res.setStatusCode(400);
            return res;
        }
        res.setStatusCode(200);
        return res;
    }
}