global class CalculateTaxAmountMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
    	HttpResponse res = new HttpResponse();
    	res.setHeader('Content-Type', 'application/json');
    	res.setBody('{"example":"test"}');
    	res.setStatusCode(200);
    	return res;
    }
}