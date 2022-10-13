public class StripeAdapterMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        List<String> jsonResponse;
        if(req.getEndpoint().contains('tokens')){
          jsonResponse = new List<String> {
        '"correlation_id": "124.9765829358068"',
        '"status": "success"',
        '"type": "FDToken"',
            '"token": {"type": "VISA","cardholder_name": "JohnSmith","exp_date": "1030","value": "2537446225198291"}'
      };
        }
        else{
          jsonResponse = new List<String> {
                '"method": "credit_card"',
                '"amount": 15000',
                '"currency": "USD"',
                '"cvv2": "111"',
                '"card": {"type": "VISA","cardholder_name": "Test Name","card_number": "1111","exp_date": "1122"}',
                '"token": {"token_type": "FDToken","token_data": {"value": "9916904738371111"}}',
                '"transaction_status": "approved"',
                '"validation_status": "success"',
                '"transaction_type": "authorize"',
                '"transaction_id": "ET119982"',
                '"transaction_tag": "2316284066"',
                '"bank_resp_code": "100"',
                '"bank_message": "Approved"',
                '"gateway_resp_code": "00"',
                '"gateway_message": "Transaction Normal"'                  
            };
        }
        res.setBody('{' + String.join(jsonResponse, ',') + '}');
        return res;
    }
}