public class UnapplyPaymentAction {

    public static final String UNAPPLY_PAYMENT_ENDPOINT = '/services/data/v54.0/commerce/billing/paymentlines/{{paymentLineId}}/actions/unapply';

    @InvocableMethod(label = 'Unapply Payment' callout = true)
    public static List<UnapplyPaymentResponse> unapplyPayment (List<UnapplyPaymentRequest> unapplyPaymentRequestList) {
        List<UnapplyPaymentResponse> unapplyPaymentResponseList = new List<UnapplyPaymentResponse>();
        for(UnapplyPaymentRequest unapplyPaymentRequest: unapplyPaymentRequestList) {
            String body = json.serialize(unapplyPaymentRequest);
            String endpoint = 'callout:MySalesforce' + UNAPPLY_PAYMENT_ENDPOINT.replace('{{paymentLineId}}', unapplyPaymentRequest.paymentLineId);
            HttpResponse response = UnapplyPaymentAction.post(endpoint, body);
            UnapplyPaymentResponse unapplyPaymentResponse = (UnapplyPaymentResponse) JSON.deserialize(response.getBody(), UnapplyPaymentResponse.class);
            unapplyPaymentResponseList.add(unapplyPaymentResponse);
        }
        return unapplyPaymentResponseList;
    }

    public static HttpResponse post(String endpoint, String body) {

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody(body);
        HttpResponse response = http.send(request);
        return response;
    }

    public class UnapplyPaymentRequest {
        @InvocableVariable(label='Payment Invoice Line Id' required=true)
        public transient String paymentLineId;

        @InvocableVariable(label='Effective Date' required=true)
        public Datetime effectiveDate;

        @InvocableVariable(label='Comments' required=true)
        public String comments;
    }

    public class UnapplyPaymentResponse {
        @InvocableVariable
        public String id;
        @InvocableVariable
        public Datetime unappliedDate;
    }
}